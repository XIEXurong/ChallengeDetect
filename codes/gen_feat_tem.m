function feat_tem = gen_feat_tem(data_tem,batch_time,time_shift,fs)

data_tem_zs = zscore(data_tem); % data normalize

batch_size = batch_time*fs; % 10 seconds
frame_shift = time_shift*fs; % 5 seconds
[data_tem_batch, N] = batch_data(data_tem_zs, batch_size, frame_shift); % batching data

feat_tem.feat_lab = {'mean', 'std', 'mad', ...
    'Diff mean', 'Diff std', 'Diff mad', 'Diff mas'};
feat_tem.feat_num = size(feat_tem.feat_lab,2);
feat_tem.feats = zeros(N,feat_tem.feat_num);
for i=1:N
    data_tmp = data_tem_batch{i};
    data_tmp_diff = data_tmp - [data_tmp(1), data_tmp(1:end-1)];

    % mean
    feat_tem.feats(i,1) = mean(data_tmp);
    % std
    if length(data_tmp) > 1
        feat_tem.feats(i,2) = std(data_tmp);
    end
    % mad
    feat_tem.feats(i,3) = mean(abs(data_tmp - feat_tem.feats(i,1))); % mean absolute deviation
    % Diff mean
    feat_tem.feats(i,4) = mean(data_tmp_diff);
    % Diff std
    if length(data_tmp_diff) > 1
        feat_tem.feats(i,5) = std(data_tmp_diff);
    end
    % Diff mad
    feat_tem.feats(i,6) = mean(abs(data_tmp_diff - feat_tem.feats(i,4))); % mean absolute deviation
    % Diff mas
    feat_tem.feats(i,7) = mean(abs(data_tmp_diff)); % mean absolute summation
end
