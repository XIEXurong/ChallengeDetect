function feat_emg = gen_feat_emg(data_emg,batch_time,time_shift,fs)

fs_emg_downsampling = 32;
downsampling_win = round(fs/fs_emg_downsampling);
fs_emg = round(fs/downsampling_win);

data_emg_down = downsample(data_emg,downsampling_win);
data_emg_down_zs = zscore(data_emg_down);

%     [coeff_emg, len_emg] = wavedec(data_emg_down_zs,6,'db5');
%     approx_emg = appcoef(coeff_emg,len_emg,'db5');
%     [cd1_emg,cd2_emg,cd3_emg,cd4_emg,cd5_emg,cd6_emg] = detcoef(coeff_emg,len_emg,[1 2 3 4 5 6]);
%     subplot(7,1,1)
%     plot(approx_emg)
%     title('Approximation Coefficients')
%     subplot(7,1,2)
%     plot(cd6_emg)
%     title('Level 6 Detail Coefficients')
%     subplot(7,1,3)
%     plot(cd5_emg)
%     title('Level 5 Detail Coefficients')
%     subplot(7,1,4)
%     plot(cd4_emg)
%     title('Level 4 Detail Coefficients')
%     subplot(7,1,5)
%     plot(cd3_emg)
%     title('Level 3 Detail Coefficients')
%     subplot(7,1,6)
%     plot(cd2_emg)
%     title('Level 2 Detail Coefficients')
%     subplot(7,1,7)
%     plot(cd1_emg)
%     title('Level 1 Detail Coefficients')

batch_size = batch_time*fs_emg; % 10 seconds
frame_shift = time_shift*fs_emg; % 5 seconds
[data_emg_down_batch, N] = batch_data(data_emg_down_zs, batch_size, frame_shift); % batching data

feat_emg.feat_lab = {'6 level (7) Eng', 'Total Eng', '6 level (7) Eng%', 'Entropy', 'RMS'};
feat_emg.feat_num = size(feat_emg.feat_lab,2) + 12;
feat_emg.feats = zeros(N,feat_emg.feat_num);
for i=1:N
    data_tmp = data_emg_down_batch{i};
    [coeff_emg, len_emg] = wavedec(data_tmp,6,'db5');
    %     approx_emg = appcoef(coeff_emg,len_emg,'db5');
    %     [cd1_emg,cd2_emg,cd3_emg,cd4_emg,cd5_emg,cd6_emg] = detcoef(coeff_emg,len_emg,[1 2 3 4 5 6]);
    %     subplot(7,1,1)
    %     plot(approx_emg)
    %     title('Approximation Coefficients')
    %     subplot(7,1,2)
    %     plot(cd6_emg)
    %     title('Level 6 Detail Coefficients')
    %     subplot(7,1,3)
    %     plot(cd5_emg)
    %     title('Level 5 Detail Coefficients')
    %     subplot(7,1,4)
    %     plot(cd4_emg)
    %     title('Level 4 Detail Coefficients')
    %     subplot(7,1,5)
    %     plot(cd3_emg)
    %     title('Level 3 Detail Coefficients')
    %     subplot(7,1,6)
    %     plot(cd2_emg)
    %     title('Level 2 Detail Coefficients')
    %     subplot(7,1,7)
    %     plot(cd1_emg)
    %     title('Level 1 Detail Coefficients')

    % 6 level (7) Eng
    c_s = 1;
    for l = 1:7
        c_e = len_emg(l) + c_s -1;
        coeff_emg_l = coeff_emg(c_s:c_e);
        c_s = c_e + 1;
        feat_emg.feats(i,l) = sum(abs(coeff_emg_l).^2); % \sum_t abs(coeff_t)^2
    end
    % Total Eng
    feat_emg.feats(i,8) = sum(feat_emg.feats(i,1:7));
    % 6 level (7) Eng%
    for l = 9:15
        feat_emg.feats(i,l) = feat_emg.feats(i,l-8)/feat_emg.feats(i,8);
    end
    % Entropy
    feat_emg.feats(i,16) = - sum(feat_emg.feats(i,9:15).*log(feat_emg.feats(i,9:15)));
    % RMS
    feat_emg.feats(i,17) = (feat_emg.feats(i,8)/7)^0.5;
end

feat_emg.fs_emg = fs_emg;
