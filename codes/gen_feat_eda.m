function feat_eda = gen_feat_eda(data_eda,batch_time,time_shift,fs)

data_eda_zs = zscore(data_eda);
batch_size = batch_time*fs; % 10 seconds
frame_shift = time_shift*fs; % 5 seconds
[data_eda_batch, N] = batch_data(data_eda_zs, batch_size, frame_shift); % batching data

feat_eda.pad_size = 2^ceil(log2(batch_size)); % window
feat_eda.frq_rs = fs/feat_eda.pad_size; % frequency resolution

feat_eda.feat_lab = {'LF time sam', 'LF frq sam', 'LF frq pwr', 'LF frq std pwr', ...
    'HF time sam', 'HF frq sam', 'HF frq pwr', 'HF frq std pwr', ...
    'VHF time sam', 'VHF frq sam', 'VHF frq pwr', 'VHF frq std pwr'};
feat_eda.feat_num = size(feat_eda.feat_lab,2);
feat_eda.feats = zeros(N,feat_eda.feat_num);
for i=1:N
    data_tmp = data_eda_batch{i};
    
    N_tmp = length(data_tmp);

    % window_vec = hann(N_tmp,'periodic'); % Hanning
    % feat_eda.win_type = 'Hanning';
    % window_vec = blackman(N_tmp,'periodic'); % Blackman
    % feat_eda.win_type = 'Blackman';
    % window_vec = ones(N_tmp,1); % Retangle
    % feat_eda.win_type = 'Retangle';
    % window_vec = bartlett(N_tmp,'periodic'); % Bartlett
    % feat_eda.win_type = 'Bartlett';
    window_vec = hamming(N_tmp,'periodic'); % Hamming
    feat_eda.win_type = 'Hamming';

    data_tmp_win = window_vec'.*data_tmp; % windowing
    data_tmp_fft = fft(data_tmp_win,feat_eda.pad_size); % fft
    data_tmp_power2 = abs(data_tmp_fft).^2/feat_eda.pad_size; % double power
    data_tmp_power = data_tmp_power2(1:feat_eda.pad_size/2+1);
    data_tmp_power(2:end-1) = 2*data_tmp_power(2:end-1); % power
    % f = feat_eda.frq_rs*(0:(feat_eda.pad_size/2));
    % plot(f,data_tmp_power,'b')

    band_lf = 2:(round(0.5/feat_eda.frq_rs)+1); % LF: 0.02 - 0.5 Hz (have filted the 0 - 0.02 Hz)
    band_hf = (band_lf(end)+1):(round(1/feat_eda.frq_rs)+1); % HF: 0.5 - 1 Hz
    band_vhf = (band_hf(end)+1):feat_eda.pad_size/2; % VHF: 1 - Hz

    % lf time data
    data_tmp_fft_lf = zeros(size(data_tmp_fft));
    filted_band = [band_lf,feat_eda.pad_size-fliplr(band_lf)+1];
    data_tmp_fft_lf(filted_band) = data_tmp_fft(filted_band);
    data_tmp_lf = ifft(data_tmp_fft_lf);
    data_tmp_lf = real(data_tmp_lf(1:N_tmp));
    % plot(data_tmp); hold on
    % plot(data_tmp_lf)

    % hf time data
    data_tmp_fft_hf = zeros(size(data_tmp_fft));
    filted_band = [band_hf,feat_eda.pad_size-fliplr(band_hf)+1];
    data_tmp_fft_hf(filted_band) = data_tmp_fft(filted_band);
    data_tmp_hf = ifft(data_tmp_fft_hf);
    data_tmp_hf = real(data_tmp_hf(1:N_tmp));
    % plot(data_tmp); hold on
    % plot(data_tmp_hf)

    % vhf time data
    data_tmp_fft_vhf = zeros(size(data_tmp_fft));
    filted_band = [band_vhf,feat_eda.pad_size-fliplr(band_vhf)+1];
    data_tmp_fft_vhf(filted_band) = data_tmp_fft(filted_band);
    data_tmp_vhf = ifft(data_tmp_fft_vhf);
    data_tmp_vhf = real(data_tmp_vhf(1:N_tmp));
    % plot(data_tmp); hold on
    % plot(data_tmp_vhf)

    % LF time sam = sum abs time
    feat_eda.feats(i,1) = sum(abs(data_tmp_lf));
    % LF frq sam = sum abs freq
    feat_eda.feats(i,2) = sum(data_tmp_power(band_lf).^0.5);
    % LF frq pwr
    feat_eda.feats(i,3) = sum(data_tmp_power(band_lf));
    % LF frq std pwr
    feat_eda.feats(i,4) = std(data_tmp_power(band_lf));
    % HF time sam = sum abs time
    feat_eda.feats(i,5) = sum(abs(data_tmp_hf));
    % HF frq sam = sum abs freq
    feat_eda.feats(i,6) = sum(data_tmp_power(band_hf).^0.5);
    % HF frq pwr
    feat_eda.feats(i,7) = sum(data_tmp_power(band_hf));
    % HF frq std pwr
    feat_eda.feats(i,8) = std(data_tmp_power(band_hf));
    % VHF time sam = sum abs time
    feat_eda.feats(i,9) = sum(abs(data_tmp_vhf));
    % VHF frq sam = sum abs freq
    feat_eda.feats(i,10) = sum(data_tmp_power(band_vhf).^0.5);
    % VHF frq pwr
    feat_eda.feats(i,11) = sum(data_tmp_power(band_vhf));
    % VHF frq std pwr
    feat_eda.feats(i,12) = std(data_tmp_power(band_vhf));
end

feat_eda.eda_frq_bands = {band_lf,band_hf,band_vhf};
