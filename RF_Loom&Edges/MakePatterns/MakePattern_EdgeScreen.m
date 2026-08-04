%% make_pattern_EdgeScreen.m

angle = 180;                     % deg
dir=1;                          % 1=UPWARD 0=DOWNWARD

EdgeExtensionMax = 7;           % max number of LEDs
pattern.gs_bckgrnd = 10;        % choose the max level of brightness 

pattern.y_num = EdgeExtensionMax*pattern.gs_bckgrnd;   % two frames of Y, at 2 different spatial frequencies
pattern.num_panels = 48; 	    % This is the number of unique Panel IDs required.
pattern.gs_val = 4; 	        % 3 = This pattern will use 8 intensity levels (4 = 16 intensity levels)
pattern.row_compression = 0;    % 0 = no compression (1 = compression of the 8 leds within a panel along y-axis)
EdgeWidth = 5;                  % radius of the Loom at the start
% yCenter = 16;                 % y-Center: (from the bottom) set the center of your final pattern (1 = center of y-axis)
% xCenter = 57;                 % x-Center: (from the the left edge)
stepEdge = 5;                   % number of LEDs the center should shift

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

% Shift position based on edges and stepEdge
xpos = repmat(leftedge:stepEdge:rightedge, 1, 6);
ypos = repelem(topedge:stepEdge:bottomedge, 8);
posEdge = [xpos',ypos'];

% Number of x_num depends on the presentation field of view (ie, edges) and
% position availbale in FlyNeMo (ie, 48)
pattern.x_num = length(posEdge); 	        % There are 96 pixel around the display (12x8) 

%(((rad2deg(tan((3.75/2)/((127+115)/2)))*2) * 7)/20)/70;

%% SPECIFIC PATTERN NAME
pattern.name = 'Pattern_YEdge_';    % define name of file for varying figure width
pattern.params.EdgeWidth = EdgeWidth; % add the width to pattern name
pattern.name = strcat(pattern.name,...
    num2str(pattern.params.EdgeWidth),'width_',num2str(angle),'angle'); % concatenate strings to get the file name

%% PATTERN INITIALIZATION 'pattern.Pats'

Pats = ones(32, 96, pattern.x_num,pattern.y_num+1); % (L,M,N,O) L = # of pixel rows(8); M = # of pixel cols(96); N = frames in x dir(96); O = frames in y dir(96)
Pats(:,:,:,:) = Pats(:,:,:,:)*pattern.gs_bckgrnd;

%% DRAW THE PATTERN

%%%%%%%%%3%%%%%%%%
%%%%%%%%%%\%%%%%%%
%4%%%%%%%%%\%%%%%%
%%\%%%%%%%%%\%%%%%
%%%\%%%%%%%%%2%%%%
%%%%\%%%%0%%%%%%%%
%%%%%1%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%


jj = 2;
% the whole patch
for r = 1:EdgeExtensionMax
  for j =  fliplr(0:(pattern.gs_bckgrnd-1)) 
    for k = 1:pattern.x_num

        xvert1 = round(posEdge(k,1) + round(EdgeWidth/2) * cos(deg2rad(angle+180)));
        yvert1 = round(posEdge(k,2) - round(EdgeWidth/2) * sin(deg2rad(angle+180)));
        xvert2 = round(posEdge(k,1) + round(EdgeWidth/2) * cos(deg2rad(angle)));
        yvert2 = round(posEdge(k,2) - round(EdgeWidth/2) * sin(deg2rad(angle)));
        
        if dir==1 % UP=1, DOWN=0
        xvert3 = round(xvert2 - (r-1) * cos(deg2rad(90-angle)));
        yvert3 = round(yvert2 - (r-1) * sin(deg2rad(90-angle)));
        xvert4 = round(xvert1 - (r-1) * cos(deg2rad(90-angle)));
        yvert4 = round(yvert1 - (r-1) * sin(deg2rad(90-angle)));
        else
        xvert3 = round(xvert2 + (r-1) * cos(deg2rad(90-angle)));
        yvert3 = round(yvert2 + (r-1) * sin(deg2rad(90-angle)));
        xvert4 = round(xvert1 + (r-1) * cos(deg2rad(90-angle)));
        yvert4 = round(yvert1 + (r-1) * sin(deg2rad(90-angle)));
        end
            
        %plot(x,y,'.-')
        x=[xvert1,xvert2,xvert3,xvert4,xvert1];
        y=[yvert1,yvert2,yvert3,yvert4,yvert1];
    
        for i = 1:96
          for ii = 1:32
              if inpolygon(i,ii,x,y)
               Pats(ii, i, k, jj) = j;
             end
           end
        end
        % update the previous positions to get expansion 
        if jj*(r-1)>(pattern.gs_bckgrnd+1)
        temp = Pats(:, :, :, jj);
        temp_bin = (Pats(:, :, :, (r-1).*(pattern.gs_bckgrnd)+1)>0);
        Pats(:, :, :, jj) = temp.*temp_bin;
        end
    end
    jj = jj+1;
   end
end

%Pats(:,:,20,2)


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
