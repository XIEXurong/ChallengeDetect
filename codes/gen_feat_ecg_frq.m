function feat_ecg_frq = gen_feat_ecg_frq(data_itrr,time_shift,delta_t)

frame_shift = round(time_shift/(delta_t*0.001));
feat_ecg_frq.pad_size = 2^ceil(log2(1/(delta_t*0.001*0.04)));
feat_ecg_frq.frq_rs = 1/(delta_t*0.001*feat_ecg_frq.pad_size);

[data_itrr_batch, N] = batch_data(data_itrr, feat_ecg_frq.pad_size, frame_shift);

feat_ecg_frq.feat_lab = {'pwr VLF', 'pwr LF', 'pwr HF', ...
    'pwr TP', 'pwr LF/HF', 'pwr LF norm', 'pwr HF norm', ...
    'psd VLF', 'psd LF', 'psd HF', ...
    'psd TP', 'psd LF/HF', 'psd LF norm', 'psd HF norm'};
feat_ecg_frq.feat_num = size(feat_ecg_frq.feat_lab,2);
feat_ecg_frq.feats = zeros(N,feat_ecg_frq.feat_num);
for i=1:N
    data_tmp = data_itrr_batch{i};
    N_tmp = length(data_tmp);

    window_vec = hamming(N_tmp,'periodic');
    feat_ecg_frq.win_type = 'Hamming';

    data_tmp_win = window_vec'.*data_tmp;
    data_tmp_fft = fft(data_tmp_win,feat_ecg_frq.pad_size);
    data_tmp_power2 = abs(data_tmp_fft).^2/feat_ecg_frq.pad_size;
    data_tmp_power = data_tmp_power2(1:feat_ecg_frq.pad_size/2+1);
    data_tmp_power(2:end-1) = 2*data_tmp_power(2:end-1);

    band_vlf = 2:(round(0.04/feat_ecg_frq.frq_rs)+1);
    band_lf = (band_vlf(end)+1):(round(0.15/feat_ecg_frq.frq_rs)+1);
    band_hf = (band_lf(end)+1):(round(0.4/feat_ecg_frq.frq_rs)+1);

    feat_ecg_frq.feats(i,1) = sum(data_tmp_power(band_vlf));

    feat_ecg_frq.feats(i,2) = sum(data_tmp_power(band_lf));

    feat_ecg_frq.feats(i,3) = sum(data_tmp_power(band_hf));

    feat_ecg_frq.feats(i,4) = sum(feat_ecg_frq.feats(i,1:3));

    feat_ecg_frq.feats(i,5) = feat_ecg_frq.feats(i,2)/feat_ecg_frq.feats(i,3);

    feat_ecg_frq.feats(i,6) = feat_ecg_frq.feats(i,2)/(feat_ecg_frq.feats(i,2)+feat_ecg_frq.feats(i,3));

    feat_ecg_frq.feats(i,7) = feat_ecg_frq.feats(i,3)/(feat_ecg_frq.feats(i,2)+feat_ecg_frq.feats(i,3));

    feat_ecg_frq.feats(i,8) = mean(data_tmp_power(band_vlf))/feat_ecg_frq.frq_rs;

    feat_ecg_frq.feats(i,9) = mean(data_tmp_power(band_lf))/feat_ecg_frq.frq_rs;

    feat_ecg_frq.feats(i,10) = mean(data_tmp_power(band_hf))/feat_ecg_frq.frq_rs;

    feat_ecg_frq.feats(i,11) = mean(data_tmp_power([band_vlf,band_lf,band_hf]))/feat_ecg_frq.frq_rs;

    feat_ecg_frq.feats(i,12) = feat_ecg_frq.feats(i,2)/feat_ecg_frq.feats(i,3);

    feat_ecg_frq.feats(i,13) = feat_ecg_frq.feats(i,2)/(mean(data_tmp_power([band_lf,band_hf]))/feat_ecg_frq.frq_rs);

    feat_ecg_frq.feats(i,14) = feat_ecg_frq.feats(i,3)/(mean(data_tmp_power([band_lf,band_hf]))/feat_ecg_frq.frq_rs);
end

feat_ecg_frq.rr_frq_bands = {band_vlf,band_lf,band_hf};