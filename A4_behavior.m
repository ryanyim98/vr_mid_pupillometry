clc; clear all;
load('/Users/rh/Desktop/VRMID-analysis/data/physio_struct_masked.mat');

% read in behavioral data
beh_data = '/Users/rh/Desktop/VRMID-analysis/data/per_second_data.csv';
T = readtable(beh_data);

% get only useful info
clear dataOut;

%%
dataOut.bad_participants = alldata.bad_participants;

for p = 1:30
    dataOut.subject(p).ID = alldata.subjectdata(p).ID;
    dataOut.subject(p).original_time_points = alldata.subjectdata(p).TimePoints_orig;
    dataOut.subject(p).total_time_in_sec = alldata.subjectdata(p).total_time(1);
    dataOut.subject(p).pupil_L = alldata.subjectdata(p).Physio.LeftPDil.data.out;
    dataOut.subject(p).pupil_R = alldata.subjectdata(p).Physio.RightPDil.data.out;
    dataOut.subject(p).pupil_Avg = alldata.subjectdata(p).Physio.AvgPDil.data.out;
    dataOut.subject(p).Times_ms = alldata.subjectdata(p).Times.timess;
    dataOut.subject(p).Times_s = alldata.subjectdata(p).Times.time;
end

% this takes a long time. ~15 min
for p = 1:30
    disp(["processing participant " + p]);
    
    beh_temp = T(string(T.Subject) == alldata.subjectdata(p).ID,:);

    for t = 1:length(beh_temp.Time) %needs to be Time not Time_str because of the 
                                    % 1pm 13pm issue
        current_sec = beh_temp.Time(t);
        beh_this_sec = beh_temp(t,:);
        ind = find(dataOut.subject(p).Times_s == current_sec);
    
        dataOut.subject(p).behavior(ind,:) = repmat(beh_this_sec,[length(ind) 1]);
    end
    
end


%% exclusion info
mean(~isnan(alldata.subjectdata(p).Physio.LeftPDil.data.out))
%% reshape to R shape
clc;
TdataOut = [];

for p = 1:30
    disp(["processing participant " + p]);
    temp_TdataOut = [dataOut.subject(p).behavior, ...
        array2table([dataOut.subject(p).pupil_L, dataOut.subject(p).pupil_R,...
        dataOut.subject(p).pupil_Avg],...
        'VariableNames',{'pupil_L','pupil_R','pupil_Avg'})];
    TdataOut = [TdataOut; temp_TdataOut];
end

plot(temp_TdataOut.pupil_L,temp_TdataOut.pupil_R,'k.');

%%
writetable(TdataOut, '/Users/rh/Desktop/VRMID-analysis/data/pupillometry.csv');
clear TdataOut;