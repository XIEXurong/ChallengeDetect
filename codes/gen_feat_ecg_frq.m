function feat_ecg_frq = gen_feat_ecg_frq(data_itrr,time_shift,delta_t)

% delta_t = data_itrr.isi
% data_itrr = data_itrr.data;

frame_shift = round(time_shift/(delta_t*0.001));
feat_ecg_frq.pad_size = 2^ceil(log2(1/(delta_t*0.001*0.04))); % padding such that the frequency resolution approximates to 0.04 Hz
feat_ecg_frq.frq_rs = 1/(delta_t*0.001*feat_ecg_frq.pad_size); % frequency resolution

[data_itrr_batch, N] = batch_data(data_itrr, feat_ecg_frq.pad_size, frame_shift); % batching data

% L = 2^ceil(log2(size(data_itrr,1)));
% data_itrr_fft = fft(data_itrr',L);
% data_itrr_abs2 = abs(data_itrr_fft/L);
% data_itrr_abs = data_itrr_abs2(1:L/2+1);
% data_itrr_abs(2:end-1) = 2*data_itrr_abs(2:end-1);
% f = 1/(delta_t*0.001)*(0:(L/2))/L;
% plot(f,data_itrr_abs) 
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')

feat_ecg_frq.feat_lab = {'pwr VLF', 'pwr LF', 'pwr HF', ...
    'pwr TP', 'pwr LF/HF', 'pwr LF norm', 'pwr HF norm', ...
    'psd VLF', 'psd LF', 'psd HF', ...
    'psd TP', 'psd LF/HF', 'psd LF norm', 'psd HF norm'};
feat_ecg_frq.feat_num = size(feat_ecg_frq.feat_lab,2);
feat_ecg_frq.feats = zeros(N,feat_ecg_frq.feat_num);
for i=1:N
    data_tmp = data_itrr_batch{i};
    N_tmp = length(data_tmp);

    % window_vec = hann(N_tmp,'periodic'); % Hanning
    % feat_ecg_frq.win_type = 'Hanning';
    % window_vec = blackman(N_tmp,'periodic'); % Blackman
    % feat_ecg_frq.win_type = 'Blackman';
    % window_vec = ones(N_tmp,1); % Retangle
    % feat_ecg_frq.win_type = 'Retangle';
    % window_vec = bartlett(N_tmp,'periodic'); % Bartlett
    % feat_ecg_frq.win_type = 'Bartlett';
    window_vec = hamming(N_tmp,'periodic'); % Hamming
    feat_ecg_frq.win_type = 'Hamming';

    data_tmp_win = window_vec'.*data_tmp; % windowing
    data_tmp_fft = fft(data_tmp_win,feat_ecg_frq.pad_size); % fft
    data_tmp_power2 = abs(data_tmp_fft).^2/feat_ecg_frq.pad_size; % double power
    data_tmp_power = data_tmp_power2(1:feat_ecg_frq.pad_size/2+1);
    data_tmp_power(2:end-1) = 2*data_tmp_power(2:end-1); % power
    % data_tmp_psd = data_tmp_power/feat_ecg_frq.frq_rs;
    % f = feat_ecg_frq.frq_rs*(0:(feat_ecg_frq.pad_size/2));
    % plot(f,data_tmp_power,'b')
    % hold on
    % plot(f,data_tmp_psd,'r')
    band_vlf = 2:(round(0.04/feat_ecg_frq.frq_rs)+1); % VLF: 0 - 0.04 Hz, ignore the 0 Hz
    band_lf = (band_vlf(end)+1):(round(0.15/feat_ecg_frq.frq_rs)+1); % LF: 0.04 - 0.15 Hz
    band_hf = (band_lf(end)+1):(round(0.4/feat_ecg_frq.frq_rs)+1); % HF: 0.15 - 0.4 Hz

    % pwr VLF: 0 - 0.04 Hz
    feat_ecg_frq.feats(i,1) = sum(data_tmp_power(band_vlf));
    % pwr LF: 0.04 - 0.15 Hz
    feat_ecg_frq.feats(i,2) = sum(data_tmp_power(band_lf));
    % pwr HF: 0.15 - 0.4 Hz
    feat_ecg_frq.feats(i,3) = sum(data_tmp_power(band_hf));
    % pwr TP = VLF + LF + HF
    feat_ecg_frq.feats(i,4) = sum(feat_ecg_frq.feats(i,1:3));
    % pwr LF/HF
    feat_ecg_frq.feats(i,5) = feat_ecg_frq.feats(i,2)/feat_ecg_frq.feats(i,3);
    % pwr LF norm = LF/(LF + HF)
    feat_ecg_frq.feats(i,6) = feat_ecg_frq.feats(i,2)/(feat_ecg_frq.feats(i,2)+feat_ecg_frq.feats(i,3));
    % pwr HF norm = HF/(LF + HF)
    feat_ecg_frq.feats(i,7) = feat_ecg_frq.feats(i,3)/(feat_ecg_frq.feats(i,2)+feat_ecg_frq.feats(i,3));
    % psd VLF: 0 - 0.04 Hz
    feat_ecg_frq.feats(i,8) = mean(data_tmp_power(band_vlf))/feat_ecg_frq.frq_rs;
    % psd LF: 0.04 - 0.15 Hz
    feat_ecg_frq.feats(i,9) = mean(data_tmp_power(band_lf))/feat_ecg_frq.frq_rs;
    % psd HF: 0.15 - 0.4 Hz
    feat_ecg_frq.feats(i,10) = mean(data_tmp_power(band_hf))/feat_ecg_frq.frq_rs;
    % psd TP: 0 - 0.4 Hz
    feat_ecg_frq.feats(i,11) = mean(data_tmp_power([band_vlf,band_lf,band_hf]))/feat_ecg_frq.frq_rs;
    % psd LF/HF
    feat_ecg_frq.feats(i,12) = feat_ecg_frq.feats(i,2)/feat_ecg_frq.feats(i,3);
    % psd LF norm = LF/(LF + HF)
    feat_ecg_frq.feats(i,13) = feat_ecg_frq.feats(i,2)/(mean(data_tmp_power([band_lf,band_hf]))/feat_ecg_frq.frq_rs);
    % psd HF norm = HF/(LF + HF)
    feat_ecg_frq.feats(i,14) = feat_ecg_frq.feats(i,3)/(mean(data_tmp_power([band_lf,band_hf]))/feat_ecg_frq.frq_rs);
end

feat_ecg_frq.rr_frq_bands = {band_vlf,band_lf,band_hf};