
function [AngleComputed] = MFTfunction(fname, MaxEyesDist, MinEyesDist, threshold, ImagesPlot)

%clear, clc
%% FLY HEAD DETECTION

%% Open the file:

% [FileName,PathName] = uigetfile('*');
% cd(PathName)
[~,~,ext]=fileparts(fname);

if ext=='.avi'
    try
    v = VideoReader(fname);
    Video = read(v);
    %implay(Video);         % play the video
    %I = Video(:,:,:,1);    % open the first frame
    %imshow(I);             % show the image from one frame
    %I = getsnapshot(obj);  % get a snapshot from the camera
    catch
    uiwait(msgbox('Unable to load the .avi file.','Error','error'));
    end
elseif ext=='.mat'
    try 
    load(fname);
    Video = vidData; clear('vidData');
    catch
    uiwait(msgbox('Unable to load the .mat file.','Error','error'));
    end
else uiwait(msgbox('Unable to find type of file.','Error','error'));
end

%% Set parameters:

% imshow(imadjust(Video(:,:,1,1)));
% [xEyes, yEyes] = ginput(2);
% hold on
% plot(xEyes,yEyes,'b')
% distEyes = sqrt((xEyes(1)-xEyes(2))^2+(yEyes(1)-yEyes(2))^2);
% distEyes

if isempty(MaxEyesDist) || isempty(MinEyesDist) || isempty(threshold) || isempty(ImagesPlot)
MaxEyesDist = 85; % max distance between the centroid and the head % 85 for Martha's rig % 110 for Sara's rig
MinEyesDist = 70; % min distance between the centroid and the head % 70 for Martha's rig % 130 for Sara's rig
threshold = 0.5;   % threshold for the binarization of the images   % 0.5 for Martha's rig % 0.3 for Sara's rig
ImagesPlot = 0;
end

%% Loop for angles detection in each frame:

%figure;
NrFrames = length(Video(1,1,1,:));
[w,h] = size(Video(:,:,1,1));
tic
Track={};
for i = 1:NrFrames
    
I = Video(:,:,1,i); % extract a frame from the video
I = imadjust(I);    % adjust contrast of the image

%% Detection of 5 strongest feature points:

scenePoints = detectSURFFeatures(I);

%Show the 5 Strongest Feature Points:
% figure;
% imshow(I);
% title('5 Strongest Feature Points from Scenei Image');
% hold on;
% plot(selectStrongest(scenePoints, 5));

% Select the 5 Strongest Feature Points of which select in turn the ones
% with Scale > 10, generally corresponding to the fly eyes:
FPSelect = selectStrongest(scenePoints, 5);
if sum(FPSelect.Scale > 10)>=2
PointSelect = FPSelect(FPSelect.Scale > 10);
PointSelect=PointSelect(1:2);
Hcenter = [mean(PointSelect.Location(:,1)) mean(PointSelect.Location(:,2))];
%pdist(PointSelect.Location,'euclidean')
Edist = sqrt((PointSelect.Location(1,1)-PointSelect.Location(2,1))^2+(PointSelect.Location(1,2)-PointSelect.Location(2,2))^2);
EyesPos = 1;
elseif sum(FPSelect.Scale > 10)<2
[maxVal, indVal] = maxk(FPSelect.Scale(:),1);
PointSelect = FPSelect(indVal);
Hcenter = PointSelect.Location;
Edist = 0;
EyesPos = 1;
else
PointSelect.Location = 0;
PointSelect.Scale = 0;
Hcenter = 0;
Edist = 0;
EyesPos = 0;
end

if ~isempty(Hcenter)
VideoFrame = insertShape(I,'circle',[Hcenter 2],'LineWidth',10, 'Color', {'green'});
else
VideoFrame = I;
end
% imshow(VideoFrame)
% hold on;
% plot(PointSelect);

Track(i).location = PointSelect.Location;
Track(i).scale = PointSelect.Scale;
Track(i).Hcenter = Hcenter;

%% Get Body orientation from SURFFeatures()  and regionprops() detection:

% Compute the centroid from regionprops() or detect it manually:
%BW = imbinarize(I,'adaptive', 'ForegroundPolarity','bright','Sensitivity', threshold);
%BW = imbinarize(I,'global');
BW = imbinarize(I, threshold);
%imshow(BW);
BW_select = bwselect(BW,h/2,w/2,8);
% bwselect() in point x=200, y=200 might be excactly on pixel=0, therefore
% move the point to 210,210:
if sum(BW_select(:))==0
   BW_select = bwselect(BW,h/2+5,w/2+5,8);
end
if sum(BW_select(:))==0
   BW_select = bwselect(BW,h/2+10,w/2+10,8);
end
%imshow(BW_select);

blob = regionprops(BW_select,'Centroid',...
    'MajorAxisLength','MinorAxisLength', 'Orientation');
centroid = [blob.Centroid(1),blob.Centroid(2)];
BlobAng = blob.Orientation;

%centroid = [187,190]; % if you want a fixed centroid

% Comupute the body angle based on the head detected with SURFFeatures():
if ~isempty(Hcenter)
Xa = Hcenter(1)-centroid(1);
Yb = Hcenter(2)-centroid(2);
dC = (sqrt((Hcenter(1)-centroid(1))^2+(Hcenter(2)-centroid(2))^2));
SURFAng = rad2deg(atan(Yb/Xa));

% Correct orientation based on what quadrant is the head relative to the
% centroid (note: image axes increase from the top-left corner to the
% bottom-right one):
Xdiff = Hcenter(1)-centroid(1);
Ydiff = Hcenter(2)-centroid(2);

% Starting from bottom-right (1) to bottom-left (4) CCW, transform SURFAng
% to 0:360 deg:
if     Xdiff>=0 && Ydiff>=0
        SURFAng = 360-SURFAng;
elseif Xdiff>=0 && Ydiff<0
        SURFAng = abs(SURFAng);
elseif Xdiff<0 && Ydiff<=0
        SURFAng = 180-SURFAng;
elseif Xdiff<=0 && Ydiff>0
        SURFAng = abs(SURFAng)+180;            
end
end

Track(i).SURFAng = SURFAng;

% Adjust the blob.Orientation angle based on the head direction:
if BlobAng<0 && BlobAng>=-90
    if (SURFAng>260 || SURFAng<10) && EyesPos==1 && Edist <= MaxEyesDist && Edist >= MinEyesDist
        BlobAng = 360+BlobAng;
    elseif SURFAng>80 && SURFAng<190 && EyesPos==1 && Edist <= MaxEyesDist && Edist >= MinEyesDist
        BlobAng = 180+BlobAng;
    else
        try 
         BlobAng=BlobAngPrevComputation(BlobAng, Track(i-1).Bangle)
        catch BlobAng=BlobAngPrevComputation(BlobAng, SURFAng)
        end
     end
elseif BlobAng>=0 && BlobAng<=90
    if (SURFAng>350 || SURFAng<100) && EyesPos==1 && Edist <= MaxEyesDist && Edist >= MinEyesDist
        %BlobAng = BlobAng;
    elseif SURFAng>170 && SURFAng<280 && EyesPos==1 && Edist <= MaxEyesDist && Edist >= MinEyesDist
        BlobAng = 180+BlobAng;
    else
       try 
         BlobAng=BlobAngPrevComputation(BlobAng, Track(i-1).Bangle)
        catch BlobAng=BlobAngPrevComputation(BlobAng, SURFAng)
        end
    end
elseif BlobAng>90 && BlobAng<=180
    if SURFAng>80 && SURFAng<190 && EyesPos==1 && Edist <= MaxEyesDist && Edist >= MinEyesDist
        %BlobAng = BlobAng;
    elseif (SURFAng>260 || SURFAng<10) && EyesPos==1 && Edist <= MaxEyesDist && Edist >= MinEyesDist
        BlobAng = 180+BlobAng;
    else
      try 
         BlobAng=BlobAngPrevComputation(BlobAng, Track(i-1).Bangle)
        catch BlobAng=BlobAngPrevComputation(BlobAng, SURFAng)
        end
    end
elseif BlobAng<-90 && BlobAng>=-180
    if SURFAng>170 && SURFAng<280 && EyesPos==1 && Edist <= MaxEyesDist && Edist >= MinEyesDist
        BlobAng = 360+BlobAng;
    elseif (SURFAng>350 || SURFAng<100) && EyesPos==1 && Edist <= MaxEyesDist && Edist >= MinEyesDist
        BlobAng = 180+BlobAng;
    else
        try 
         BlobAng=BlobAngPrevComputation(BlobAng, Track(i-1).Bangle)
        catch BlobAng=BlobAngPrevComputation(BlobAng, SURFAng)
        end
    end
end

% Assign the body angle:
% If the two eyes are detected correctly, use SURFAng, otherwise use BlobAng:
if EyesPos==1 && Edist <= MaxEyesDist && Edist >= MinEyesDist && (abs(SURFAng-BlobAng) < 5 || abs(SURFAng-BlobAng) > 355)
        Bangle = SURFAng; % use the angle determined by the center of the two eyes
else
        Bangle = BlobAng; % use the angle determined by the ellipse
end


% Assign centroid, Body Angle and distance between centroid and head:
Track(i).centroid = centroid;
Track(i).Bangle = Bangle;
%Track(i).dist = dC;

if i == 3 % after 5 frames check where is Bangle compared to the Hcenter
  if abs(median(vertcat(Track(1:i).SURFAng)) - median(vertcat(Track(1:i).Bangle))) > 150 && ...
          abs(median(vertcat(Track(1:i).SURFAng)) - median(vertcat(Track(1:i).Bangle))) < 210
      if Track(i).Bangle<360 && Track(i).Bangle>=270
          Track(i).Bangle = Track(i).Bangle-180;
      elseif Track(i).Bangle>=0 && Track(i).Bangle<90
          Track(i).Bangle = Track(i).Bangle+180;
      elseif Track(i).Bangle>=90 && Track(i).Bangle<180
          Track(i).Bangle = Track(i).Bangle+180;
      elseif Track(i).Bangle>=180 && Track(i).Bangle<270
          Track(i).Bangle = Track(i).Bangle-180;
      end
  end
end
      

%% Get Head orientation from SURFFeatures() detection

if EyesPos == 1 && Edist <= MaxEyesDist && Edist >= MinEyesDist

% Comupute the angle:
Xa = PointSelect.Location(1,1)-PointSelect.Location(2,1);
Yb = PointSelect.Location(1,2)-PointSelect.Location(2,2);
%dC = (sqrt((Hcenter(1)-centroid(1))^2+(Hcenter(2)-centroid(2))^2));

% Compute the head angle relative to the body (+ CCW - CW):
if   Bangle > 270 && Bangle <= 360   % Q1
     Hangle = abs(rad2deg(atan(Yb/Xa))) - (Bangle-270);
elseif Bangle <= 90 && Bangle >= 0   % Q2
     Hangle = (90-rad2deg(atan(Yb/Xa))) - Bangle;
elseif Bangle <= 180 && Bangle > 90  % Q3
     Hangle = abs(rad2deg(atan(Yb/Xa))) - (Bangle-90);
elseif Bangle <= 270 && Bangle > 180 % Q4
     Hangle = (180-rad2deg(atan(Yb/Xa))) - (Bangle-90);
end

% Q1 Hangle --> abs(rad2deg(atan(Yb/Xa))) - (Bangle-270)
% Q2 Hangle --> rad2deg(atan(Yb/Xa)) - Bangle
% Q3 Hangle --> abs(rad2deg(atan(Yb/Xa))) - (Bangle-90)
% Q4 Hangle --> (180-rad2deg(atan(Yb/Xa))) - (Bangle-90)

% Add to Track() the head angle relative to the body:
Track(i).Hangle = Hangle;
else
Track(i).Hangle = NaN;
end


% Plot the process:
if ImagesPlot==1
if EyesPos == 1 && Edist <= MaxEyesDist && Edist >= MinEyesDist
imshow(VideoFrame)
hold on
L = dC;
x1 = centroid(1);
y1 = centroid(2);
x2=x1+(L*cosd(SURFAng));
y2=y1-(L*sind(SURFAng));
plot([x1 x2],[y1 y2],...
    'LineWidth',2,...
   'Color', 'g')
hold on
%L = 200;
x1 = centroid(1);
y1 = centroid(2);
x2=x1+(L*cosd(Bangle));
y2=y1-(L*sind(Bangle));
plot([x1 x2],[y1 y2],...
    'LineWidth',2,...
   'Color', 'b')
hold on
plot([PointSelect.Location(1,1) PointSelect.Location(2,1)],[PointSelect.Location(1,2) PointSelect.Location(2,2)],...
    'LineWidth',2,...
   'Color', 'g')
drawnow;

else
    
imshow(VideoFrame)
hold on
L = dC;
x1 = centroid(1);
y1 = centroid(2);
x2=x1+(L*cosd(Bangle));
y2=y1-(L*sind(Bangle));
plot([x1 x2],[y1 y2],...
    'LineWidth',2,...
   'Color', 'b')
drawnow;

end

end

end

toc

figure;
data1=vertcat(Track.Bangle);
data2=vertcat(Track.Hangle);
%max(data)
AngleComputed = [data1';data2'];
%AngleComputed = 360-AngleComputed;
plot(data1, 'b');
hold on
try
plot(data2, 'g');
catch
end

end

