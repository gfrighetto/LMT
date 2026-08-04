
% Dialog box
[FileName,PathName] = uiputfile('*.mat');

% send functions at 100 Hz

%% Loom Function

% (see Tammero and Dickinson 2002; Von Reyn et al. 2017; Ferris et al., 2018)
% k = l/v (k, costant; l, half-size of the object's side; v, velocity)

rad2deg(2*atan(80/8000)) % 50 = r/v (ms); 800 ms (0 ms = contact)

% See an example:

% frames = 69;     % number of frames of our pattern
% Radius = 7*2.22; % max radius reached by the pattern (LEDs*deg)
% step = Radius/frames; % step in deg every each frame
% %speed = 12.5;
% k = 0.02;
% r = (0:step:(frames*step));
% v = r/k;
% t = -(step./v); %(speed/step)
% plot(t,r); % (r/step)
% (r(frames)-r(frames-1))/(v(frames)-v(frames-1)); % constant

% COMPUTE THE LOOM FUNCTION SIMULATING AN OBJECT APPROACHING:

% Example:
l = 0.5; % 1 cm object side/2
v = 50/8000; % 50 cm in 800 ms (constant velocity of the object)
l/v % k (ms)

% As per Gabbiani et al., 1999
k = 8;
time = linspace(0,1600,d+1); % time (ms)
ExpAngle = rad2deg(2*atan(k./time)); % 50 = r/v (ms); 800 ms (0 ms = contact)
figure;plot(fliplr(time),ExpAngle)

% ---a--|--a---
%  \    |
%   i   d
%    \  |
%     \ |
%      Fly

duration = 80;    % duration of collision (0.8 s if we are gonna sample at 100 Hz) 
d = 50;           % distance of the object (cm)
a=0.5;            % dimension of the object/2 (cm)
v = d/(duration); % object's speed (cm/ms) with duration converted in ms
a/v % (k)

b=fliplr(0:d); % steps of the approaching object
i = sqrt(a.^2+b.^2); % hypotenuse
angles = 90-rad2deg(asin(b./i)); % steps of angular expansions of the approaching object
time = linspace(0,(duration),d+1); % time (ms) converted for the 100 Hz of the display
figure;plot(time,angles)

% Remove values greater than the max radius we have for our Pattern
frames = 69; % number of frames of our Pattern
maxRadius = 7*2.22; % radius in pixels (ie., leds) * angle subtended by a single led
angles = angles(angles<=maxRadius);
time = time(angles<=maxRadius);

figure
%angles = (angles)/0.25;  % convert to number of pattern's frames
plot(time,angles)
% angles(end)/(time(end)/100)
% time = time./100;
% v = angles./time;
% k = angles./v;
% plot(k)

timeInterP = round(linspace(0,duration,duration));
anglesInterP = interp1(time,angles,timeInterP);
anglesInterP = round(anglesInterP/(maxRadius/frames));
% plot(time,angles,'o',timeInterP,anglesInterP,':.');
% xlim([0 2*pi]);
% title('(Default) Linear Interpolation');

plot(timeInterP,anglesInterP);


% Add some values at the end of the anglesIterP vectors (will be just a
% slown down response of the object that hopefully has already triggered a
% behavioral response)
if maxRadius<90
[M,I] = max(anglesInterP); % max reached angle
miss_frames = round(linspace(M,frames, duration-I+1));
anglesInterP = [anglesInterP(anglesInterP<=M), miss_frames(2:end)];
plot(timeInterP,anglesInterP);
end

% We have our approaching object and now we can add some time before/after the
% loom:
func = [zeros(1,50) anglesInterP repmat(anglesInterP(end),1,10) zeros(1, 140-(length(anglesInterP)))];
%func = [zeros(1,50) anglesInterP repmat(anglesInterP(end),1,350-(length(anglesInterP)))];
% plot(func)

% Save the function (name it!)
funcname = 'position_04_function';
str = strcat([PathName funcname]);
save(str,'func');


%% Sinusoidal Function

time = 200; % ms
r = 10;
freq = 4;
a = linspace(-pi*freq,pi*freq,time);
y = sin(a)*r;
x = 1:time;
y = round(y);
plot(x,y)

func = [zeros(1,100) y zeros(1,100)];
%plot(func)

% Save the function (name it!)
funcname = 'position_02_function';
str = strcat([PathName funcname]);
save(str,'func');

%% Revolving Function

time = 240; % ms
x = 1:time;
y = linspace(1,96,time);
y = round(y);
plot(x,y)

func = [zeros(1,100) y zeros(1,300-length(y))];
%plot(func)

% Save the function (name it!)
funcname = 'position_03_function';
str = strcat([PathName funcname]);
save(str,'func');


func = [zeros(1,100) -y zeros(1,300-length(y))];
%plot(func)

% Save the function (name it!)
funcname = 'position_04_function';
str = strcat([PathName funcname]);
save(str,'func');

%% Static Function

func = zeros(1,200);
%plot(func)

% Save the function (name it!)
funcname = 'position_05_function';
str = strcat([PathName funcname]);
save(str,'func');

%% Static Function + Step

func = [zeros(1,1) ones(1,399)];
%plot(func)

% Save the function (name it!)
funcname = 'position_06_function';
str = strcat([PathName funcname]);
save(str,'func');

%% Moving Edges
% 20 deg/s
time = (((rad2deg(tan((3.75/2)/((127+115)/2)))*2) * 7)/20)*100; % 100 Hz 
x = 1:time;
y = linspace(1,69,time);
y = round(y);
plot(x,y)

func = [zeros(1,50) y repmat(y(end),1,350-length(y))]; % zeros(1,350-length(y))
%plot(func)

% Save the function (name it!)
funcname = 'position_03_function';
str = strcat([PathName funcname]);
save(str,'func');


func = [zeros(1,100) -y zeros(1,300-length(y))];
%plot(func)

% Save the function (name it!)
funcname = 'position_04_function';
str = strcat([PathName funcname]);
save(str,'func');