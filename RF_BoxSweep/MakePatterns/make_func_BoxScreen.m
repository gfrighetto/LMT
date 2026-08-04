
% Dialog box
[FileName,PathName] = uiputfile('*.mat');

% send functions at 100 Hz

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

%% Moving Constant Velocity Function

time = 50; % 0.5 s * 100 Hz
motiontime = 10; % 0.1 s * 100 Hz
x = 1:motiontime;
y = linspace(1,4,motiontime);
y = round(y);
plot(x,y)

func = [zeros(1,10) y repmat(max(y),1,time-length(y)-10)];
%plot(func)

% Save the function (name it!)
funcname = 'position_02_function';
str = strcat([PathName funcname]);
save(str,'func');


%% Static Function

func = zeros(1,50);
%plot(func)

% Save the function (name it!)
funcname = 'position_01_function';
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