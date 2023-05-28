clear all; clc;

load('/Users/rh/Desktop/VRMID-analysis/data/physio_struct.mat');

filter = 'low'; %'low'

val = [];

for i = 1:30
    val(i,1) = alldata.subjectdata(i).Physio.ValidSample.L;
    val(i,2) = alldata.subjectdata(i).Physio.ValidSample.R;
end

sr = 120; %sampling rate in Hz
sampling_duration = seconds(1/sr);

subjects = cell2mat({alldata.subjectdata.ID}');

low_qual_subj = subjects(val(:,1) < 0.7,:);
clear val;

% visualization of filters
filter_order = 3;

if filter == "low"
    filter_range = 4; %Hz
elseif filter == "bandpass"
    filter_range = [0.5 4];
end


% bandpass
[b,a] = butter(filter_order,filter_range/(sr/2), filter);
 
% Plot the frequency response
freqz(b, a, [], sr);
%% -1 into nan and gap expansion
for p = 1:30
    disp(["...participant number "+ p + "..."])
    %left
    alldata.subjectdata(p).Physio.LeftPDil.data.gapExpand = alldata.subjectdata(p).Physio.pupil_size.LeftPDil;
    alldata.subjectdata(p).Physio.LeftPDil.data.gapExpand(alldata.subjectdata(p).Physio.LeftPDil.data.gapExpand == -1) = NaN;
    [alldata.subjectdata(p).Physio.LeftPDil.data.gapExpand, ...
        alldata.subjectdata(p).Physio.LeftPDil.valid_id] = expandGaps(alldata.subjectdata(p).Physio.LeftPDil.data.gapExpand,...
            sr);
    %right
    alldata.subjectdata(p).Physio.RightPDil.data.gapExpand = alldata.subjectdata(p).Physio.pupil_size.RightPDil;
    alldata.subjectdata(p).Physio.RightPDil.data.gapExpand(alldata.subjectdata(p).Physio.RightPDil.data.gapExpand == -1) = NaN;
    [alldata.subjectdata(p).Physio.RightPDil.data.gapExpand, ...
        alldata.subjectdata(p).Physio.RightPDil.valid_id] = expandGaps(alldata.subjectdata(p).Physio.RightPDil.data.gapExpand,...
            sr);
end

%% pupil dilation speed filtering
clc;
for p = 1:30
    disp(["...participant number "+ p + "..."])
    %left
    RAW = alldata.subjectdata(p).Physio.LeftPDil.data.gapExpand;
    alldata.subjectdata(p).Physio.LeftPDil.valid_id = pupilSpeedfilter(RAW,sr,alldata.subjectdata(p).Physio.LeftPDil.valid_id);
    RAW(alldata.subjectdata(p).Physio.LeftPDil.valid_id == 0) = NaN;
    alldata.subjectdata(p).Physio.LeftPDil.data.speedFilter = RAW;

    
    %right
    RAW = alldata.subjectdata(p).Physio.RightPDil.data.gapExpand;
    alldata.subjectdata(p).Physio.RightPDil.valid_id = pupilSpeedfilter(RAW,sr,alldata.subjectdata(p).Physio.RightPDil.valid_id);
    RAW(alldata.subjectdata(p).Physio.RightPDil.valid_id == 0) = NaN;
    alldata.subjectdata(p).Physio.RightPDil.data.speedFilter = RAW;
end

clear RAW
%% interpolation
% data has to be fully interpolated to be filtered.
% fully interpolate while noting where should be later excluded in long_blink_masked
% note the start and end; they are not supposed to be interpolated; 

for p = 1:30
    disp(["...participant number "+ p + "..."])
    %left
    RAW = alldata.subjectdata(p).Physio.LeftPDil.data.speedFilter;
    
    [alldata.subjectdata(p).Physio.LeftPDil.data.interpolation, ...
        alldata.subjectdata(p).Physio.LeftPDil.data.missing_data] = interpolate_data(RAW);
    alldata.subjectdata(p).Physio.LeftPDil.valid_id = long_blink_mask(alldata.subjectdata(p).Physio.LeftPDil.valid_id,...
        alldata.subjectdata(p).Physio.LeftPDil.data.missing_data);

    %right
    RAW = alldata.subjectdata(p).Physio.RightPDil.data.speedFilter;
    
    [alldata.subjectdata(p).Physio.RightPDil.data.interpolation, ...
        alldata.subjectdata(p).Physio.RightPDil.data.missing_data] = interpolate_data(RAW);
    alldata.subjectdata(p).Physio.RightPDil.valid_id = long_blink_mask(alldata.subjectdata(p).Physio.RightPDil.valid_id,...
        alldata.subjectdata(p).Physio.RightPDil.data.missing_data);
    
end

clear RAW;
%% filtering
for p = 1:30
    RAW = alldata.subjectdata(p).Physio.LeftPDil.data.interpolation;
    alldata.subjectdata(p).Physio.LeftPDil.data.filter = filtfilt(b,a,double(RAW));
    
    RAW = alldata.subjectdata(p).Physio.RightPDil.data.interpolation;
    alldata.subjectdata(p).Physio.RightPDil.data.filter = filtfilt(b,a,double(RAW));
end

%% exclude data based on mask
for p = 1:30
    alldata.subjectdata(p).Physio.LeftPDil.data.out = alldata.subjectdata(p).Physio.LeftPDil.data.filter;
     alldata.subjectdata(p).Physio.LeftPDil.data.out(...
         alldata.subjectdata(p).Physio.LeftPDil.valid_id == 0) = NaN;
     
     alldata.subjectdata(p).Physio.RightPDil.data.out = alldata.subjectdata(p).Physio.RightPDil.data.filter;
     alldata.subjectdata(p).Physio.RightPDil.data.out(...
         alldata.subjectdata(p).Physio.RightPDil.valid_id == 0) = NaN;
end

%% save
save('/Users/rh/Desktop/VRMID-analysis/data/physio_struct_filtered.mat','alldata');