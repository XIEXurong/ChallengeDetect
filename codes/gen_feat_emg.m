function feat_emg = gen_feat_emg(data_emg,batch_time,time_shift,fs)

fs_emg_downsampling = 32;
downsampling_win = round(fs/fs_emg_downsampling);
fs_emg = round(fs/downsampling_win);

data_emg_down = downsample(data_emg,downsampling_win);
data_emg_down_zs = zscore(data_emg_down);

batch_size = batch_time*fs_emg;
frame_shift = time_shift*fs_emg;
[data_emg_down_batch, N] = batch_data(data_emg_down_zs, batch_size, frame_shift);

feat_emg.feat_lab = {'6 level (7) Eng', 'Total Eng', '6 level (7) Eng%', 'Entropy', 'RMS'};
feat_emg.feat_num = size(feat_emg.feat_lab,2) + 12;
feat_emg.feats = zeros(N,feat_emg.feat_num);
for i=1:N
    data_tmp = data_emg_down_batch{i};
    [coeff_emg, len_emg] = wavedec(data_tmp,6,'db5');

    c_s = 1;
    for l = 1:7
        c_e = len_emg(l) + c_s -1;
        coeff_emg_l = coeff_emg(c_s:c_e);
        c_s = c_e + 1;
        feat_emg.feats(i,l) = sum(abs(coeff_emg_l).^2);
    end

    feat_emg.feats(i,8) = sum(feat_emg.feats(i,1:7));

    for l = 9:15
        feat_emg.feats(i,l) = feat_emg.feats(i,l-8)/feat_emg.feats(i,8);
    end

    feat_emg.feats(i,16) = - sum(feat_emg.feats(i,9:15).*log(feat_emg.feats(i,9:15)));

    feat_emg.feats(i,17) = (feat_emg.feats(i,8)/7)^0.5;
end

feat_emg.fs_emg = fs_emg;
