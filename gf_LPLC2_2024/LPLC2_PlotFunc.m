%open Slideb\okObj

%load('Y:\Giovanni\2P_Data\T3_SRF_2flies.mat')
load('Y:\Giovanni\2P_Data\T2a_TF_CentredROI9flies.mat')
load('Y:\Giovanni\2P_Data\T3_TF_CentredROI11flies.mat')

load('Y:\Giovanni\2P_Data\LPLC2_2024\params.mat')
% save('Y:\Giovanni\2P_Data\T3_TF_CentredROI11flies.mat', 'b


a = T2Nern;
%clear T2Nern
% 5, 6 to remove
% 1 and 4
n=3;
getFrames(obj)
getDaqData(obj) 
getFrametimes(obj) 
getTrialtimes(obj(2)) 
getParameters(obj)
play(b(n))

b = [a(3),a(6),a(7),a(10)];

for n = 1:2
    getFrames(obj(n))
    getDaqData(obj(n)) 
    getFrametimes(obj(n)) 
    getTrialtimes(obj(n)) 
    getParameters(obj(n))
end

unique([b.Fly])

obj(1,2).Daq(1:46000,:) = []

%% Automatic ROIs identification and plot
%open mbInputObj/getROIs
% % Based on:
% getROIs2(a(n),1,3) % moving bow_sweep
% %getROIs(a(n),1,3) % static flickering boa
% saveROIs(a(n))
% a(n).ROI


% figure
% c=1;
% for i=1:12 % Trials IDs to plot
% fields=[];
% fields.TrialPatNum = i;
% for ii=1:3 % No. of ROIs
% subplot(12,3,c); plotTrials(a(n),ii,fields,[],[],gcf); caption = [sprintf('ROI %d', ii) sprintf(' | ') sprintf('Trial %d',i)]; title(caption, 'FontSize',10);c=c+1;
% end
% end


%% Scan and plot the activity of a saved ROI during a specific time frame:

resp = a;

for n = 1:4  %length(obj)
x(n,:) = scanROI(resp(4),resp(4).ROI(n).mask);
%a = scanROI(a(n));
%figure,plot(x)

% Save the response of ROI selected:
%obj(n).ROI(1).response = x;
%obj(n).UseFixedResp = 1;
% %a(n).ROI(1).color = [0 0.4470 0.7410];

% Get and save a single ROI:
%  getFrames(obj(n))
%  obj(n).ROI = [];
%  obj(n).ROI(1).mask = ones(size(obj(n).Frames,1),size(obj(n).Frames,2));
%  obj(n).ROI(1).response = scanROI(obj(n),ones(size(obj(n).Frames,1),size(obj(n).Frames,2)));
%  obj(n).ROI(1).color = ROIcolor(1);
%  %obj(n).Frames = [];
%  obj(n).UseFixedResp = 1;
 
end

% a(n).ROI(1)
% a(n).Folder
% a(n).Link
% a(n).ROI = [];
% a(n).ROI
% loadROIs(a(n))

data = {};
for n = 1:length(obj)
    x = obj(n).ROI(1).response;
    data{n} = x;
end

%% Manual ROIs identification and plot
% Trials displaying boa_sweep ON/OFF down/up: 15, 18, 19, 22
figure();
fields = [];
fields.TrialPatNum = 7; %2
fields.TrialSeqNum = 25; %50
%a(n).ActivityFrame8 = getActivityFrame(a(n),fields);

ROIindex = 1; % ROI ID to plot
%plotTrials(obj,ROIindex,fields);
plotTrials(b,ROIindex,fields,1);
%plotTrials(a(n),ROIindex,fields,[],[],gcf)


%% Plot multiple figures

%d=[c(1),c(2),c(4)];
x=obj(2); %obj(6)

n=5;
figure(n)
fields = [];
fields.TrialPatNum = n; %2
stimnames = {'Fourier bar f2b' 'Fourier bar b2f'};
%stimnames = {'Grating 4px f2b' 'Grating 4px b2f'};
stimvelocities = [18 90 180];
xpatch = [];
xpatch(1,:) = [0.5 72/18+0.5 72/18+0.5 0.5];
xpatch(2,:) = [0.5 72/90+0.5 72/90+0.5 0.5];
xpatch(3,:) = [0.5 72/180+0.5 72/180+0.5 0.5];
% 4 leds: 18, 36, 90 -> 1, 2, 5 Hz
% 8 leds: 36, 71, 90 -> 1, 2, 2.5 Hz

% xpatch(1,:) = [0.5 72/18+0.5 72/18+0.5 0.5];
% xpatch(2,:) = [0.5 72/36+0.5 72/36+0.5 0.5];
% xpatch(3,:) = [0.5 72/90+0.5 72/90+0.5 0.5];


% trials_f2b = params{1,1}((mod(params{1,1}(:,1),2)==0),1);
% trilas_b2f = params{1,1}((mod(params{1,1}(:,1),2)~=0),1);
% trials = [trilas_b2f trials_f2b];

trials = params{1,1}(:,1);
cond = 0;

%for ii = 1:2
    
for i = 1:6
    

subplot(3,2,i);

%(fields.TrialPatNum-1)*6+1 : fields.TrialPatNum*6

fields.TrialSeqNum = trials((fields.TrialPatNum-1)*6+i);

ROIindex = 1; % ROI ID to plot

[~,ax(i)] = plotTrials(x,ROIindex,fields,0,ROIcolor(1),figure(n));

    pbaspect(ax(i),[1 1 1]) %  sets the plot box aspect ratio for the current axes
    ax(i).YLim = [-0.5 2];
    ax(i).XLim = [-0.5 6];
    
        if i >= 5
            ax(i).XAxis.Visible = 'on';
        else
            ax(i).XAxis.Visible = 'off';
        end
        
        if i <= 2
            t = title(ax(i),stimnames{i});
        end
        
        if any([1:2:30] == fields.TrialSeqNum)
             cond = cond+1;
             ax(i).YAxis.Label.String = [num2str(stimvelocities(cond)), ' ', 'deg/s']; %fields.TrialSeqNum
             ax(i).YAxis.Label.FontWeight = 'bold';
        else
             ax(i).YAxis.Label.String = '';
        end
        
        ax(i).FontSize = 10;
        t.FontSize = 8;
        
        xpatchtemp = xpatch(cond,:);
        ypatch = repelem(ax(i).YLim,2);
        stimpatch = patch(xpatchtemp,ypatch,[0.95 0.50 0.95], 'EdgeColor', 'none');
        uistack(stimpatch,'bottom')
        ax(i).Layer = 'Top';
        ax(i).YLimMode = 'auto';

 linkaxes
 %ylim([-1 4])
 %legend(r{i})

end

%end

%%



% d= findRespArray(a(1), 1, fields);
% [responseArray, timeVector, F0Array, respIdx] = findRespArray(a(1), 1, fields);
% figure;plot(responseArray(3,:)./F0Array(2)-1)
% plot(F0Array)
% 
% time=zeros(12,2000);
% resp=zeros(12,2000);
% 
%  figure;
% %for i = 1:length(b)
%     
%     %[timeVector, normFPS, trialDuration] = findStandardTrial(b);
%     [responseArray, timeVector, F0Array, respIdx] = findRespArray(b(i), 1, fields);
%     
%     for ii = 1:length(responseArray(:,1))
%         
%     [peak,frame]=max(responseArray(ii,:));
%     
%     resp(ii+((i-1)*length(responseArray(:,1)))).time    = [(1:length(responseArray(ii,:))) - frame];
% %     if length(resp(ii+((i-1)*length(responseArray(:,1)))).time)<3000 resp(ii+((i-1)*length(responseArray(:,1)))).time = [(1:length(responseArray(ii,:))) - frame length((1:length(responseArray(ii,:))) - frame):3000];
% %     end
%     
%     resp(ii+((i-1)*length(responseArray(:,1)))).DeltaF  = responseArray(ii,:) ./F0Array(ii)-1;
%     if length(resp(ii+((i-1)*length(responseArray(:,1)))).DeltaF)<3000 resp(ii+((i-1)*length(responseArray(:,1)))).DeltaF(length(resp(ii+((i-1)*length(responseArray(:,1)))).DeltaF)+1:(3000-length(resp(ii+((i-1)*length(responseArray(:,1)))).DeltaF))==0; end
%    
%     plot(resp(ii+((i-1)*length(responseArray(:,1)))).time, resp(ii+((i-1)*length(responseArray(:,1)))).DeltaF)
%     hold on 
%     
%     end
% 
% %end
% 
% %plot(resp(2).time, resp(2).DeltaF)
% 
%  [timeVector, normFPS, trialDuration] = findStandardTrial(b);
% 
% mean(resp.DeltaF)
% figure;plot(mean([resp.DeltaF],1))

%% Responses Alignment (trials for the function)

figure;
[responseArray, timeVector, F0Array, respIdx] = findRespArray(b, 1, fields);
% Remove outliers:
responseArray(10:11,:) = [];
F0Array(10:11,:)       = [];

% Initialize empty matrixes for responses alignment of peaks:
time = zeros(length(responseArray(:,1)),length(responseArray(1,:)));
resp = zeros(length(responseArray(:,1)),length(responseArray(1,:)));

    for i = 1:length(responseArray(:,1))
        
    [peak,frame]=max(responseArray(i,:));
    
    time(i,:) = [(1:length(responseArray(i,:))) - frame];
    
    resp(i,:) = responseArray(i,:) ./F0Array(i)-1;
    
    plot(time(i,:), resp(i,:))
    hold on
    
    end

% Initialize empty matrixes for data filling and structure uniformity:
time_norm = [];
resp_norm = [];

    for ii = 1:length(time(:,1))
    time_norm(ii,:) = [min(time(:,1)):(time(ii,1)-1) time(ii,:) (time(ii,length(time))+1):max(time(:,length(time)))];
    resp_norm(ii,:) = [zeros(1,abs(min(time(:,1))-(time(ii,1)))) resp(ii,:) zeros(1, abs(max(time(:,length(time)))-time(ii,length(time))))];
    end
    

% Mean
resp_mean = nanmean(resp_norm,1);
%figure;plot(mean_resp)

% Variance (=std^2 and sem=std/sqrt(n))
resp_std = nanstd(resp_norm,1);
n_flies = length(unique([b.Fly]));
resp_sem = resp_std ./ sqrt(n_flies);


linecolor = b(1).ROI(1).color;
lineprops.col = {linecolor};
lineprops.edgestyle = ':';
            
% Plot
mseb(time_norm(1,:), resp_mean , resp_sem);
mseb(time_norm(1,:) , resp_mean , resp_sem ,lineprops, 1);

%% Plot aligned response by using plotAligned function

fields = [];
fields.TrialPatNum = 1;
fields.TrialSeqNum = 1;
plotAligned(b, 2, fields, 1, [10 11])
%plotAligned(e(1), 1, fields, 1)
%plotAligned(obj, 1, fields,1)


%% Empty the obj properties in memory:

a(n).Frames = [];
a(n).Daq = [];

for n = 1:length(a)
a(n).Frames = [];
end

%size(a(n).Daq)
%size(a(n).Frames
%unique(a(n).TrialSeqNum)
%a(n).IFI
%{a.DateStr}

%% Get the raw data from recordings:

fields.TrialPatNum = 5; % 3 = Fourier Bar

Resp = [];
Time = [];
F0 = [];
ID = [];
%for n = 1:11 % number of flies
    for i = 25:30 % 18 (f2b, b2f), 90 (f2b, b2f), 180 (f2b, b2f)
    fields.TrialSeqNum = i;
    [responseArray, timeVector, F0Array, respIdx] = findRespArray(x, ROIindex, fields);
    Resp = [Resp; responseArray];
    Time = [Time; timeVector];
    F0 = [F0; F0Array];
    ID = [ID; respIdx];
    end
%end

Grating36 = {Resp, Time, F0, ID};
save( '57C10_Grating36.mat', 'Grating36')
