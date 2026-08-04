%% Make patterns

clear, clc
%% SPECIFIC PATTERN NAME

id = 0;
pattern.name = 'Pattern_BarSweep_';    % define name of file for varying figure width

% Dialog box
[FileName,PathName] = uiputfile('*.mat');

%% SET STIMULUS PARAMETERS

% The 2p arena cover ~210 deg of the fly visual field and each LED covers
% roughly 2.25 deg of it.

% Stim definition
stim(1).descriptor = ['3_width']; % name
stim(1).size = [3 3]; % width x height
%stim(1).descriptor = ['two_x_two']; % name
%stim(1).size = [2 2]; % width x height
% stim(2).descriptor = ['three_x_three']; % name
% stim(2).size = [3 3]; % width x height
% stim(3).descriptor = ['8_width']; % name
% stim(3).size = [8 32]; % width x height
%  stim(1).descriptor = ['4_width_gratings']; % name
%  stim(1).size = [4 32]; % width x height
%   stim(1).descriptor = ['8_width_gratings']; % name
%  stim(1).size = [8 32]; % width x height

% Confine the stimulation into a portion of the visual field 
leftedge    = 45;
rightedge   = 91;
topedge     = 1;
bottomedge  = 32;

% Quantity and Dynamic
continuity     = 'F';  % continutity 'T' of 'F'
hor_noBoxes    =  1;  % number of horizontal boxes
ver_noBoxes    =  1;  % number of vertical boxes
dist_Boxes     =  4;  % number of LEDs separating boxes

% Luminosity
box_brightness        = 0; % 0 LEDs off, 15 LEDs on (max)
mid_brightness        = 7; % with gs_val = 4(bit), 16 grayscale values (0:15)
background_brightness = 7; % background brightness outside the stimulation window

%% GENERAL PARAMETERS

pattern.gs_val      = 4;              % Use 16 grayscale values

pattern.x_panels    = 12;
pattern.y_panels    = 4;
pattern.num_panels  = 48;             % Number of unique panel IDs required; NOTE: this is a standard size for the 12*4 arena

pattern.x_size      = 8;
pattern.y_size      = 8;
pattern.row_compression = 0;


% Set Panel Map for 2p panels:
for i = 1:12
    for j = 1:4
        Panel_mat(j,i) = mod((i-1)*4,12) + ceil(i/3) + (j-1)*12;
    end
end
mat = flipud(Panel_mat);
pattern.Panel_map = fliplr(mat);

% Set Panel Map for RigidSetup panels:
% pattern.Panel_map = [4 8 12 16 20 24 28 32 36 40 44 48;...
%                      3 7 11 15 19 23 27 31 35 39 43 47;...
%                      2 6 10 14 18 22 26 30 34 38 42 46;...
%                      1 5  9 13 17 21 25 29 33 37 41 45];
% or
% A = 1:48;
%             pattern.Panel_map = flipud(reshape(A, 4, 12));


%% PATTERN INITIALIZATION 'pattern.Pats'

for i = 1:length(stim) % number of differents box dimensions

width = stim(i).size(1);  % width as define in SET STIMULUS PARAMETERS
height = stim(i).size(2); % height as define in SET STIMULUS PARAMETERS
  
hor_pos = (leftedge-width):1:(rightedge+1);  % horizontal axis origin position of the box (vector of numbers with steps)
ver_pos = (topedge-height):1:(bottomedge+1); % vertical axis origin position of the box (vector of numbers with steps)

pattern.x_num       = rightedge-leftedge+width+2;  % Positions of square as it moves horizontally (first frame is blank)
pattern.y_num       = bottomedge-topedge+height+2;  % Positions of square as it moves vertically (first frame is blank)

Pats = mid_brightness*ones(32, 96, pattern.x_num,pattern.y_num); % (L,M,N,O) L = # of pixel rows(8); M = # of pixel cols(96); N = frames in x dir(96); O = frames in y dir(96)

%% BOX SWEEP
%ver_pos = 1:round(boxwidth/2):pattern.x_num;    % vertical axis origin position of the box (vector of numbers with steps)

  
  for X = 1:pattern.x_num
     for Y = 1:pattern.y_num
        
        hor_px = [hor_pos(X):(hor_pos(X)+width-1)];  % horizontal positions of the box
        ver_px = [ver_pos(Y):(ver_pos(Y)+height-1)]; % vertical positions of the box
        
        % If more than 1 hor_noBoxes has been defined update hor_px
        if hor_noBoxes > 1; hor_px_i  = hor_px(1):(width+dist_Boxes):(hor_px(1)+(width+dist_Boxes)*(hor_noBoxes-1));
                            hor_px_ii =(hor_px(1):(width+dist_Boxes):(hor_px(1)+(width+dist_Boxes)*(hor_noBoxes-1)))+width-1;
           for j=2:length(hor_px_i); hor_px = [hor_px hor_px_i(j):hor_px_ii(j)]; end
        end
        
        % If more than 1 ver_noBoxes has been defined update ver_px
        if ver_noBoxes > 1; ver_px_i  = ver_px(1):(height+dist_Boxes):(ver_px(1)+(height+dist_Boxes)*(ver_noBoxes-1));
                            ver_px_ii =(ver_px(1):(height+dist_Boxes):(ver_px(1)+(height+dist_Boxes)*(ver_noBoxes-1)))+height-1;
           for j=2:length(ver_px_i); ver_px = [ver_px ver_px_i(j):ver_px_ii(j)]; end
        end
        
        % Maintain a loop if continuity='T'
        if continuity=='T'; hor_px(hor_px > rightedge) = [hor_px(hor_px > rightedge)-rightedge-1];
                            hor_px(hor_px < leftedge) = [hor_px(hor_px < leftedge)+leftedge];
                            ver_px(ver_px > bottomedge) = [ver_px(ver_px > bottomedge)-bottomedge];
                            %ver_px(ver_px < topedge) = [ver_px(ver_px < topedge)+topedge];
        end
        
        % Empty the position over the limits
        hor_px(hor_px < leftedge | hor_px > rightedge) = [];    % remove values < 1 or > 96 (ie, min and max values for ver LEDs position)
        ver_px(ver_px < topedge | ver_px > bottomedge) = [];    % remove values < 1 or > 32 (ie, min and max values for hor LEDs position)
        
        if ~isempty(ver_px) && ~isempty(hor_px)        % if ver and hor positions are not empty (&& means that hor_px is not evaluated if ver_px is false)
          Pats(ver_px, hor_px, X, Y) = box_brightness; % replace the bckgrnd values of ver and hor positions with off LEDs
        end
     end
  end

Pats(:, [1:leftedge-1 rightedge+1:96], :, :) = background_brightness;
pattern.Pats = Pats;


%% MAKE
 
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);
stimDescriptor = stim(i).descriptor;
if box_brightness < mid_brightness; brightness=['OFF']; else brightness=['ON']; end
            
%% SAVE

str = strcat([pattern.name num2str(id+i,'%02.f') '_' brightness '_' stimDescriptor]);
patname = strcat([PathName str FileName]);
save(patname,'pattern');

end

%%