function [OUT, na_ind] = interpolate_data(RAW)

%% replace -1 with NaN
disp("...processing initiated...");

RAW(RAW == -1) = NaN;

if ~isempty(find(RAW <= 2))
    disp("There is number smaller than 2 in the data. Check again.");
return
end
%% find segments of missing data
na_seg = find(isnan(RAW));
na_ind = [];
c = 1;

for i = 1:length(na_seg)
    if na_seg(i) == 1 || i == 1
        na_ind(1,1) = na_seg(i);
    elseif na_seg(i) ~= na_seg(i-1) + 1 %increasing
            na_ind(c,2) = na_seg(i-1);
            c = c + 1;
            na_ind(c,1) = na_seg(i);
    end
    if i == length(na_seg)
        na_ind(c,2) = na_seg(i);
    end
end

na_ind(:,3) = (na_ind(:,2) - na_ind(:,1) + 1)/120;

disp(["Longest chunk of missing data is "+ max(na_ind(:,3))+ " s"]);

OUT = resample(RAW,1:length(RAW));
na_ind = array2table(na_ind,'VariableNames',{'start','end','time'});
end
