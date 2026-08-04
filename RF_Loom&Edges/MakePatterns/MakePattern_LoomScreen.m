%% make_pattern_LoomScreen.m

% One LED covers approximately 1.2 deg at the fly eye equator under the
% AllOptical microscope in Frye Lab
LoomRadiusMax = 7;              % max number of LEDs
pattern.gs_bckgrnd = 10;        % choose the max level of brightness 

pattern.y_num = LoomRadiusMax*pattern.gs_bckgrnd;   % two frames of Y, at 2 different spatial frequencies
pattern.num_panels = 48; 	    % This is the number of unique Panel IDs required.
pattern.gs_val = 4; 	        % 3 = This pattern will use 8 intensity levels (4 = 16 intensity levels)
pattern.row_compression = 0;    % 0 = no compression (1 = compression of the 8 leds within a panel along y-axis)
LoomRadius = 1;                 % radius of the Loom at the start
% yCenter = 16;                 % y-Center: (from the bottom) set the center of your final pattern (1 = center of y-axis)
% xCenter = 57;                 % x-Center: (from the the left edge)
stepLoom = 5;                   % number of LEDs the center should shift

% where x=44 y=16 is in front of the fly

%1---96
%%%%%% 1
%%%%%% |
%%%0%% |
%%%%%% 32

% Confine the stimulation into a portion of the visual field 
leftedge    = 50;
rightedge   = 85;
topedge     = 3;
bottomedge  = 32;

% Shift position based on edges and stepLoom
xpos = repmat(leftedge:stepLoom:rightedge, 1, 6);
ypos = repelem(topedge:stepLoom:bottomedge, 8);
posLoom = [xpos',ypos'];

% Number of x_num depends on the presentation field of view (ie, edges) and
% position availbale in FlyNeMo (ie, 48)
pattern.x_num = length(posLoom); 	        % There are 96 pixel around the display (12x8) 


%% SPECIFIC PATTERN NAME
pattern.name = 'Pattern_ALoom_';    % define name of file for varying figure width
pattern.params.LoomRadius = LoomRadiusMax; % add the width to pattern name
pattern.name = strcat(pattern.name,...
    num2str(pattern.params.LoomRadius),'radius'); % concatenate strings to get the file name

%% PATTERN INITIALIZATION 'pattern.Pats'

Pats = ones(32, 96, pattern.x_num,pattern.y_num+1); % (L,M,N,O) L = # of pixel rows(8); M = # of pixel cols(96); N = frames in x dir(96); O = frames in y dir(96)
Pats(:,:,:,:) = Pats(:,:,:,:)*pattern.gs_bckgrnd;

%% DRAW THE PATTERN


jj = 2;
% the whole patch
for r = LoomRadius:LoomRadiusMax
for j =  fliplr(0:(pattern.gs_bckgrnd-1))
  for k = 1:pattern.x_num
    for i = 1:96
        for ii = 1:32
            if (i - posLoom(k,1))^2 + (ii - posLoom(k,2))^2 < r^2           
                Pats(ii, i, k, jj) = j;
            end
        end
    end
  end
if jj*(r-1)>(pattern.gs_bckgrnd+1)
temp = Pats(:, :, :, jj);
temp_bin = (Pats(:, :, :, (r-1).*(pattern.gs_bckgrnd)+1)>0);
Pats(:, :, :, jj) = temp.*temp_bin;
end
jj = jj+1;
end
end

%Pats(:,:,61,:) = Pats(:,:,1,:);



% for k=1:pattern.x_num
%     for z=1:pattern.y_num
%     Pats(:,:,k,z) = circshift(Pats(:,:,1,z),[posLoom(k,2) posLoom(k,1)]);
%     end
% end
% 
% Pats_temp = zeros(32, 96, pattern.x_num,pattern.y_num+1);
% for n = 1:pattern.x_num
%     if n > 96-60
%         x = (n+60)-96;
%     else 
%         x = n+60;
%     end
%     Pats_temp(:,:,x,:) = Pats(:,:,n,:);
% end
% 
% Pats = Pats_temp;


%% Draw a circle
% r = 10;
% x = (-r:0);
% y = zeros(1, length(x)); % prelocating array of zeros
% for i = 1:length(y)
% y(i) = sqrt(r^2-x(i)^2);
% end
% 
% y = round(y); % Round to nearest decimal or integer
% 
% y_val = [];
% x_val = [];
% for i = 1:length(y)-1
% if y(i+1)-y(i)>=2
%     y_val = [y_val, y(i):y(i+1)-1];
%     x_val = [x_val, repmat(x(i), 1, length(y(i):y(i+1)-1))];
% else
% y_val = [y_val, y(i)];
% x_val = [x_val, x(i)];
% end
% end
% y_val = [y_val, y(i+1)];
% x_val = [x_val, x(i+1)];
% 
% x_val = [x_val, sort(x_val*-1)];
% y_val = [y_val, fliplr(y_val)];
% 
% y_val2 = y_val*-1;
% x_val2 = x_val*-1;
% 
% plot(x_val,y_val)
% hold on
% plot(x_val2,y_val2)
% 
% x= [x_val,x_val2]+xCenter;
% y= [y_val,y_val2]+yCenter;
% plot(x,y)
% 
% % just the circle
% for i = 1:96
%     for ii = 1:32
%         for j = 1:length(x)
%         if i==x(j) && ii==y(j)
% Pats(ii, i, 1, 1) = 15;
%         end
%         end
%     end
% end
% 
% Pats(:, :, 1, 1)

%% Set Panel Map for RigidSetup panels:

% Pats:
pattern.Pats = Pats;

% Set Panel Map for 2p panels:
Panel_mat = zeros(4,12); % preallocate
for i = 1:12
    for j = 1:4
        Panel_mat(j,i) = mod((i-1)*4,12) + ceil(i/3) + (j-1)*12;
    end
end
mat = flipud(Panel_mat);
pattern.Panel_map = fliplr(mat);

pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

%% Save
[FileName,PathName] = uiputfile('*.mat');
str = [PathName pattern.name FileName];
save(str, 'pattern')

%end
