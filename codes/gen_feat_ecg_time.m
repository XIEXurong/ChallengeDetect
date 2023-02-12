function feat_ecg_time = gen_feat_ecg_time(data_ecg,data_rr,batch_time,time_shift,fs)

data_ecg_zs = zscore(data_ecg); % data normalize

% R batch
r_num = size(data_rr,1);
time_rr = zeros(r_num,1);
time_r = zeros(r_num,1);
data_r = zeros(r_num,1);
t=0;
last_time_rr = 1;
batch_id = 1;
batch_time_start = 0;
batch_time_range = [batch_time_start, batch_time];
batch_overlap_range = [time_shift, batch_time];
data_rtime_batch = {[]};
data_rtime_overlap = [];
for i = 1:r_num
    t = t + data_rr(i);
    time_rr(i) = round(t*fs);
    [data_r(i), peak_time] = max(data_ecg_zs(last_time_rr:time_rr(i))); % find peak
    time_r(i) = peak_time + last_time_rr;
    last_time_rr = time_rr(i);
    if t > batch_time_range(1) && t <= batch_time_range(2) % t \in batch_time_range
        data_rtime_batch{batch_id,1} = [data_rtime_batch{batch_id}, i]; % add to batch
    elseif t > batch_time_range(2)
        batch_id = batch_id + 1; % new batch
        batch_time_start = (batch_id-1)*time_shift;
        batch_time_range = [batch_time_start, batch_time_start + batch_time];
        batch_overlap_range = [batch_time_start + time_shift, batch_time_start + batch_time];
        data_rtime_batch{batch_id,1} = data_rtime_overlap; % initialize the batch
        data_rtime_overlap = [];
        data_rtime_batch{batch_id,1} = [data_rtime_batch{batch_id}, i]; % add to batch
    end
    if t > batch_overlap_range(1) && t <= batch_overlap_range(2) % t \in batch_overlap_range
        data_rtime_overlap = [data_rtime_overlap, i]; % add to overlap
    end
end

% plot(data_ecg_zs(1:10000))
% hold on
% plot(time_r(1:13),data_r(1:13),'ro')

data_diffr = data_r - [data_r(1);data_r(1:end-1)]; % 1st order diff of R with repeated padding
data_diffrr = data_rr - [data_rr(1);data_rr(1:end-1)]; % 1st order diff of RR with repeated padding

N = size(data_rtime_batch,1);

feat_ecg_time.feat_lab = {'bpm', 'R mean', 'R std', 'R mad', ...
    'RR mean', 'RR std', 'RR mad', ...
    'DiffR mean', 'DiffR std', 'DiffR mad', 'DiffR mas', ...
    'DiffRR mean', 'DiffRR std', 'DiffRR mad', 'DiffRR mas'};
feat_ecg_time.feat_num = size(feat_ecg_time.feat_lab,2);
feat_ecg_time.feats = zeros(N,feat_ecg_time.feat_num);
for i=1:N
    batch_tmp = data_rtime_batch{i}; % batch token
    data_r_tmp = data_r(batch_tmp); % batch R
    data_rr_tmp = data_rr(batch_tmp); % batch RR
    data_diffr_tmp = data_diffr(batch_tmp); % batch Diff RR
    data_diffrr_tmp = data_diffrr(batch_tmp); % batch Diff RR

    % bpm
    feat_ecg_time.feats(i,1) = length(batch_tmp)/(batch_time/60);
    % R mean
    feat_ecg_time.feats(i,2) = mean(data_r_tmp);
    % R std
    if length(batch_tmp) > 1
        feat_ecg_time.feats(i,3) = std(data_r_tmp);
    end
    % R mad
    feat_ecg_time.feats(i,4) = mean(abs(data_r_tmp - feat_ecg_time.feats(i,2))); % mean absolute deviation
    % RR mean
    feat_ecg_time.feats(i,5) = mean(data_rr_tmp);
    % RR std
    if length(batch_tmp) > 1
        feat_ecg_time.feats(i,6) = std(data_rr_tmp);
    end
    % RR mad
    feat_ecg_time.feats(i,7) = mean(abs(data_rr_tmp - feat_ecg_time.feats(i,5))); % mean absolute deviation
    % DiffR mean
    feat_ecg_time.feats(i,8) = mean(data_diffr_tmp);
    % DiffR std
    if length(batch_tmp) > 1
        feat_ecg_time.feats(i,9) = std(data_diffr_tmp);
    end
    % DiffR mad
    feat_ecg_time.feats(i,10) = mean(abs(data_diffr_tmp - feat_ecg_time.feats(i,8))); % mean absolute deviation
    % DiffR mas
    feat_ecg_time.feats(i,11) = mean(abs(data_diffr_tmp)); % mean absolute summation
    % DiffRR mean
    feat_ecg_time.feats(i,12) = mean(data_diffrr_tmp);
    % DiffRR std
    if length(batch_tmp) > 1
        feat_ecg_time.feats(i,13) = std(data_diffrr_tmp);
    end
    % DiffRR mad
    feat_ecg_time.feats(i,14) = mean(abs(data_diffrr_tmp - feat_ecg_time.feats(i,12))); % mean absolute deviation
    % DiffRR mas
    feat_ecg_time.feats(i,15) = mean(abs(data_diffrr_tmp)); % mean absolute summation
end
