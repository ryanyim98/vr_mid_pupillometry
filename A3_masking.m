clear all; clc;

load('/Users/rh/Desktop/VRMID-analysis/data/physio_struct_filtered.mat');

%% create mask for weird pupil position
for p = 1:30
    disp(["...participant number "+ p + "..."])
    %---left

    % x position 0.1 ~ 0.9
    alldata.subjectdata(p).Physio.LeftPDil.valid_id(...
        (alldata.subjectdata(p).Physio.pupil_position.LeftPPos_x ~= -1 & ...
        alldata.subjectdata(p).Physio.pupil_position.LeftPPos_x < 0.1) |...
        (alldata.subjectdata(p).Physio.pupil_position.LeftPPos_x > 0.9)) = 0;
    
    % y position 0.1 ~ 0.9
    alldata.subjectdata(p).Physio.LeftPDil.valid_id(...
        (alldata.subjectdata(p).Physio.pupil_position.LeftPPos_y ~= -1 & ...
        alldata.subjectdata(p).Physio.pupil_position.LeftPPos_y < 0.1) |...
        (alldata.subjectdata(p).Physio.pupil_position.LeftPPos_y > 0.9)) = 0;

   disp(["left percentage included: "+mean(alldata.subjectdata(p).Physio.LeftPDil.valid_id)]);
   
   %---right
    
    % x position 0.1 ~ 0.9
    alldata.subjectdata(p).Physio.RightPDil.valid_id(...
        (alldata.subjectdata(p).Physio.pupil_position.RightPPos_x ~= -1 & ...
        alldata.subjectdata(p).Physio.pupil_position.RightPPos_x < 0.1) |...
        (alldata.subjectdata(p).Physio.pupil_position.RightPPos_x > 0.9)) = 0;
    
    % y position 0.1 ~ 0.9
    alldata.subjectdata(p).Physio.RightPDil.valid_id(...
        (alldata.subjectdata(p).Physio.pupil_position.RightPPos_y ~= -1 & ...
        alldata.subjectdata(p).Physio.pupil_position.RightPPos_y < 0.1) |...
        (alldata.subjectdata(p).Physio.pupil_position.RightPPos_y > 0.9)) = 0;
   
   disp(["right percentage included: "+ mean(alldata.subjectdata(p).Physio.RightPDil.valid_id)]);
   
end

%%
for p = 1:30
    a(p,1) = mean(alldata.subjectdata(p).Physio.LeftPDil.valid_id);
    a(p,2) = mean(alldata.subjectdata(p).Physio.RightPDil.valid_id);
end

1 - mean(a,1)
%% masking
for p = 1:30
    alldata.subjectdata(p).Physio.LeftPDil.data.out(...
        alldata.subjectdata(p).Physio.LeftPDil.valid_id == 0) = NaN;
    
    alldata.subjectdata(p).Physio.RightPDil.data.out(...
        alldata.subjectdata(p).Physio.RightPDil.valid_id == 0) = NaN;
end

%%
for p = 1:30
    p
    [max(alldata.subjectdata(p).Physio.LeftPDil.data.out), max(alldata.subjectdata(p).Physio.RightPDil.data.out)]
end

%% examplary figure
sr = 120;
cm = brewermap(6,'Set2'); %colour map

RAWl = alldata.subjectdata(1).Physio.pupil_size.LeftPDil;
RAWl(RAWl == -1) = NaN;

RAWr = alldata.subjectdata(1).Physio.pupil_size.RightPDil;
RAWr(RAWr == -1) = NaN;

vis_duration = 22; % seconds
ind = 1:(1+vis_duration*sr * 4);

RAW_visl = RAWl(ind);
RAW_visr = RAWr(ind);

RAW_vis2l = alldata.subjectdata(1).Physio.LeftPDil.data.gapExpand(ind);
RAW_vis2r = alldata.subjectdata(1).Physio.RightPDil.data.gapExpand(ind);

RAW_vis3l = alldata.subjectdata(1).Physio.LeftPDil.data.speedFilter(ind);
RAW_vis3r = alldata.subjectdata(1).Physio.RightPDil.data.speedFilter(ind);

RAW_vis4l = alldata.subjectdata(1).Physio.LeftPDil.data.interpolation(ind);
RAW_vis4r = alldata.subjectdata(1).Physio.RightPDil.data.interpolation(ind);

RAW_vis5l = alldata.subjectdata(1).Physio.LeftPDil.data.filter(ind);
RAW_vis5r = alldata.subjectdata(1).Physio.RightPDil.data.filter(ind);

RAW_vis6l = alldata.subjectdata(1).Physio.LeftPDil.data.out(ind);
RAW_vis6r = alldata.subjectdata(1).Physio.RightPDil.data.out(ind);

makefigure(18,18);

subplot(4,2,1);
plot(ind/120,RAW_visl,'lineWidth',3); hold on; 
plot(ind/120,RAW_vis2l,'lineWidth',3); hold on;
legend({'raw','gapExpand'},'Location','southeast');
ax = gca;
colororder(ax,cm([1 2],:)); 
title("left eye");
ylim([3,7]);
xlim([0 88]);

subplot(4,2,2);
plot(ind/120,RAW_visr,'lineWidth',3); hold on; 
plot(ind/120,RAW_vis2r,'lineWidth',3); hold on; 
legend({'raw','gapExpand'},'Location','southeast');
title("right eye");
ax = gca;
colororder(ax,cm([1 2],:)); 
ylim([3,7]);
xlim([0 88]);

subplot(4,2,3);
plot(ind/120,RAW_vis2l,'lineWidth',3); hold on;
plot(ind/120,RAW_vis3l,'lineWidth',3); hold on; 
legend({'gapExpand','speedfilter'},'Location','southeast');
ax = gca;
colororder(ax,cm([2 3],:)); 
ylim([3,7]);
xlim([0 88]);

subplot(4,2,4);
plot(ind/120,RAW_vis2r,'lineWidth',3); hold on;
plot(ind/120,RAW_vis3r, 'lineWidth',3); hold on; 
legend({'gapExpand','speedfilter'},'Location','southeast');
ax = gca;
colororder(ax,cm([2 3],:)); 
ylim([3,7]);
xlim([0 88]);

subplot(4,2,5);
% plot(ind/120,RAW_vis3,'k', 'lineWidth',3); hold on;
plot(ind/120,RAW_vis4l,'lineWidth',3); hold on;
plot(ind/120,RAW_vis5l,'lineWidth',3); hold on;
legend({'interpolation','filtering'},'Location','southeast');
ax = gca;
colororder(ax,cm([4 5],:)); 
ylim([3,7]);
xlim([0 88]);

subplot(4,2,6);
% plot(ind/120,RAW_vis3,'k', 'lineWidth',3); hold on;
plot(ind/120,RAW_vis4r,'lineWidth',3); hold on;
plot(ind/120,RAW_vis5r,'lineWidth',3); hold on;
legend({'interpolation','filtering'},'Location','southeast');
ax = gca;
colororder(ax,cm([4 5],:)); 
ylim([3,7]);
xlim([0 88]);

subplot(4,2,7:8);
% plot(ind/120,RAW_vis3,'k', 'lineWidth',3); hold on;
plot(ind/120,RAW_vis6l,'k', 'lineWidth',1); hold on;
plot(ind/120,RAW_vis6r,'k', 'lineWidth',2); hold on;
legend({'used data left','used data right'},'Location','southeast');
ylim([3,7]);
xlim([0 88]);

print('/Users/rh/Desktop/VRMID-analysis/write/example_pupil.tiff','-dtiff','-r600');
%% get avg pupil size for where both eyes were available
for p = 1:30
    disp(["...participant number "+ p + "..."])
    
    alldata.subjectdata(p).Physio.AvgPDil.data.out = (alldata.subjectdata(p).Physio.LeftPDil.data.out + ...
        alldata.subjectdata(p).Physio.RightPDil.data.out)/2;
    
        
    alldata.subjectdata(p).Physio.AvgPDil.data.out(isnan(alldata.subjectdata(p).Physio.LeftPDil.data.out) & ...
        isnan(alldata.subjectdata(p).Physio.RightPDil.data.out)) = NaN;
    
end
%% save
save('/Users/rh/Desktop/VRMID-analysis/data/physio_struct_masked.mat','alldata', '-v7.3');