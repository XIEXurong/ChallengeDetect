
mkdir data_preprocess3;
addpath('codes');

all_persons_list='used_persons_list.txt';
name_list=importdata(all_persons_list);
name_list=name_list(:)';
name_num=size(name_list,2);
fs = 1000;
batch_time = 10;
time_shift = 5;

% check all files
for name_id=1:name_num
    name_str=name_list{name_id};
    ls(['data_preprocess2/',name_str,'_process2.mat']);
    ls(['data_preprocess2/',name_str, '.txt']);
    ls(['data_preprocess2/','HRV_Tachogram_of_', name_str,'.mat']);
    ls(['data_preprocess2/','HRV_Interpolated_RR_of_', name_str,'.mat']);
end

% load label
label_table.A = readtable('data/time-episode.xlsx', 'Sheet', 1);
label_table.B = readtable('data/time-episode.xlsx', 'Sheet', 2);
label_table.C = readtable('data/time-episode.xlsx', 'Sheet', 3);

for name_id=1:name_num
    % name_id = 1;

    % read data
    name_str=name_list{name_id};

%     load(['data_preprocess2/',name_str,'_featNlab.mat']);

    data_channels = load(['data_preprocess2/',name_str,'_process2.mat']); % load channel data
    data_ecg = data_channels.data(:,1);
    data_tem = data_channels.data(:,2);
    data_rsp = data_channels.data(:,3);
    data_emg = data_channels.data(:,4);
    data_eda = data_channels.data(:,5);
    clear data_channels; % save memory
    [event, Penh] = readtxttable_all(['data_preprocess2/',name_str, '.txt']); % load txt table
    [time,event] = process_event_txt(event); % process txt table
    data_rr = load(['data_preprocess2/','HRV_Tachogram_of_', name_str,'.mat']); % load RR data
    data_itrr = load(['data_preprocess2/','HRV_Interpolated_RR_of_', name_str,'.mat']); % load interpolated RR data

    feats_all.time_shift = time_shift;
    feats_all.batch_time = batch_time;

    % process ECG

    feats_all.feat_ecg_time = gen_feat_ecg_time(data_ecg,data_rr.data,batch_time,time_shift,fs); % time domain features

    feats_all.feat_ecg_frq = gen_feat_ecg_frq(data_itrr.data,time_shift,data_itrr.isi); % frequence domain features


    % process TEM
    
    feats_all.feat_tem = gen_feat_tem(data_tem,batch_time,time_shift,fs);


    % process RSP

    feats_all.feat_rsp = gen_feat_rsp(data_rsp,time,event,'Recovery',batch_time,time_shift,fs);


    % process EMG

    feats_all.feat_emg = gen_feat_emg(data_emg,batch_time,time_shift,fs);

    % frmtime = 1; frmshifttime = 0.5; % seconds
    % feats_all.feat_emg_stft = gen_feat_emg_stft(data_emg,batch_time,time_shift,fs,frmtime,frmshifttime); % stft features


    % process EDA

    feats_all.feat_eda = gen_feat_eda(data_eda,batch_time,time_shift,fs);

    % frmtime = 1; frmshifttime = 0.5; % seconds
    % feats_all.feat_eda_stft = gen_feat_eda_stft(data_eda,batch_time,time_shift,fs,frmtime,frmshifttime); % stft features


    % get time label

    time_label = find_table_time_new(label_table,name_str);


    % save data

    save(['data_preprocess3/',name_str,'_featNlab.mat'],'feats_all','time_label');
end

