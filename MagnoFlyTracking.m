
clear; close all

%% Get the list of files to process from the master folder:

[FileName,PathName] = uigetfile('*', 'Select the video files (.mat or .avi)', 'MultiSelect', 'on'); % Pick multiple files from the group directory);
cd(PathName) % set the directory based on the gui selection

if ~exist([PathName(1:end-1) '_Angles'],'dir')
    %..make the folder for the Angles computation
    
    AngPath = [PathName(1:end-1) '_Angles'];
    mkdir(AngPath);
else
    AngPath = [PathName(1:end-1) '_Angles'];
end

% vidtemp = regexp(PathName, ['\\|' '\/|'],'split'); % split filename based on '.' or '_'
% vidtemp = vidtemp(length(vidtemp)-1);
% name = strjoin([vidtemp 'threshold'] , '_'); % combine strings


flist = cellstr(FileName); % list of files selected
No_files = length(flist);  % number of files selected


for n = 1:No_files % number of files/recordings selected
     
    fname = string(flist(n));
    [~,~,ext]=fileparts(string(fname)); % get the extension from the first FileName
    
    if n == 1
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
     
     imshow(imadjust(Video(:,:,1,1)));
     [xEyes, yEyes] = ginput(2);
     hold on
     plot(xEyes,yEyes,'b')
     distEyes = sqrt((xEyes(1)-xEyes(2))^2+(yEyes(1)-yEyes(2))^2);
     close all
    end
     
     MaxEyesDist = distEyes+(distEyes*9/100);
     MinEyesDist = distEyes-(distEyes*15/100);
     threshold   = 0.5;

        MaxEyesDist = 85;  % max distance between the centroid and the head % 85 for Martha's rig % 110 for Sara's rig
        MinEyesDist = 70;  % min distance between the centroid and the head % 70 for Martha's rig % 130 for Sara's rig
%         threshold   = 0.5; % threshold for the binarization of the images   % 0.5 for Martha's rig % 0.3 for Sara's rig

     ImagesPlot  = 0;
     try
     AngleComputed = MFTfunction(fname, MaxEyesDist, MinEyesDist, threshold, ImagesPlot);
     catch ME
         % nothing to do, move to the next
         fprintf('Error in orientation computation: %s\n', ME.message);
     end
     %fly(n) = str2double(regexpi(fname,'(?<=(fly)\D*)(\-?\d*)','once','Match'));
     %rep(n) = str2double(regexpi(fname,'(?<=(rep)\D*)(\-?\d*)','once','Match'));
     AngName = strjoin(['Angle' erase(fname,ext)] , '_'); % combine strings
     AngName = convertStringsToChars(AngName);
     AngPathName = fullfile(AngPath, AngName);
     save(AngPathName,'AngleComputed')
     disp(strjoin([fname ' : FLY ORIENTATION SAVED']))
     
end

% Find how many unique flies
% FlyID  = unique(fly);
% No_Fly = length(FlyID);
% fprintf('%d flies selected \n', No_Fly)
