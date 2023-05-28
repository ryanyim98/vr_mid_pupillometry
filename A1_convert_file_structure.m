clear all; clc;

addpath('/Users/rh/Desktop/VRMID-analysis/');
physio_data = '/Users/rh/Desktop/VRMID-analysis/data/physio_120hz_20March.csv';
T = readtable(physio_data);
%%
fmt = "hh:mm:ss.SSSSS";
sr = 120; %sampling rate in Hz
sampling_duration = seconds(1/sr);

% make structure
subjects = unique(T.Subject);

check_columns = T(T.LeftPDil == 1 | T.RightPDil == 1 ,:);

check_columns2 = T(T.LeftPDil > 1 & T.LeftPDil <2 | T.RightPDil > 1 & T.RightPDil <2 ,:);
%%
subplot(2,2,1);
ndhist(T.RightPPos_x(T.RightPPos_x ~= -1 & T.RightPPos_y ~= -1),...
    T.RightPPos_y(T.RightPPos_x ~= -1 & T.RightPPos_y ~= -1));

subplot(2,2,2);
ndhist(T.LeftPPos_x(T.LeftPPos_x ~= -1 & T.LeftPPos_y ~= -1),...
    T.LeftPPos_y(T.LeftPPos_x ~= -1 & T.LeftPPos_y ~= -1));

subplot(2,2,3:4);
histogram(T.RightPPos_x(T.RightPPos_x ~= -1 & T.RightPPos_y ~= -1)); hold on;
histogram(T.LeftPPos_x(T.LeftPPos_x ~= -1 & T.LeftPPos_y ~= -1)); 
legend('Right','Left');
%% some rightPDil which should be -1 was written as 1. this also affect AvgPDil
T.RightPDil(T.RightPDil == 1) = -1;
T.LeftPDil(T.LeftPDil == 1) = -1;

% some PDils are smaller than 2. Impossible
T.RightPDil(T.RightPDil <2 & T.RightPDil > -1) = -1;
T.LeftPDil(T.LeftPDil <2 & T.LeftPDil > -1) = -1;
%%
subplot(1,2,1);
histogram(T.LeftPDil(T.LeftPDil ~= -1));
subplot(1,2,2);
histogram(T.RightPDil(T.RightPDil ~= -1));

%%
subplot(1,2,1);
histogram(T.LeftPPos_x(T.LeftPPos_x ~= -1));
subplot(1,2,2);
histogram(T.RightPPos_x(T.RightPPos_x ~= -1));
%%
clear alldata;

for s = 1:length(subjects)
    sub = subjects(s);
    temp = T(string(cell2mat(T.Subject)) == string(sub{1}),:);
    alldata.subjectdata(s).ID = sub{1};
    times = temp.Time;
    pupil_position = temp(:,["LeftPPos_x","LeftPPos_y","LeftPPos_c",...
        "RightPPos_x","RightPPos_y","RightPPos_c"]);
    pupil_size = temp(:,["LeftOpen","LeftOpen_c","LeftPDil",...
        "LeftPDil_c","RightOpen","RightOpen_c","RightPDil","RightPDil_c"]);
    % go through every seconds
    [times_conv, pupil_position_conv, pupil_size_conv] = convert_time(times,...
        fmt,sr,pupil_position,pupil_size);
    alldata.sampling_rate = sr;
    alldata.subjectdata(s).TimePoints_orig = length(times);
    alldata.subjectdata(s).Times = times_conv;
    alldata.subjectdata(s).total_time = seconds(length(times_conv)/120);
    alldata.subjectdata(s).Physio.pupil_position = pupil_position_conv;
    alldata.subjectdata(s).Physio.pupil_size = pupil_size_conv;
    alldata.subjectdata(s).Physio.ValidSample.L = sum(pupil_size_conv.LeftPDil ~= -1)/length(times);
    alldata.subjectdata(s).Physio.ValidSample.R = sum(pupil_size_conv.RightPDil ~= -1)/length(times);
%     [M I] = max(pupil_size_conv.LeftPDil_c) %weird...
end

%%
val = [];

for i = 1:30
    val(i,1) = alldata.subjectdata(i).Physio.ValidSample.L;
    val(i,2) = alldata.subjectdata(i).Physio.ValidSample.R;
end

alldata.bad_participants = subjects(val(:,1) < 0.7);
%%
save('/Users/rh/Desktop/VRMID-analysis/data/physio_struct.mat','alldata');