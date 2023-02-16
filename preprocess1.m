
mkdir data_preprocess1;

all_persons_list='used_persons_list.txt';
name_list=importdata(all_persons_list);
name_list=name_list(:)';
name_num=size(name_list,2);
sample_period = 0.001;
for name_id=1:name_num
    % name_id = 1;
    name_str=name_list{name_id};
    load(['data/',name_str,'.mat']);
    data_ecg = data(:,1);
    N = size(data_ecg,1);
    T = N*sample_period;
    time = sample_period:sample_period:T;
    % figure; hold on
    % plot(time(1:10000),data_ecg(1:10000),'b');

    data_ecg_median = data_ecg;
    medFilt1 = dsp.MedianFilter(200);
    medFilt2 = dsp.MedianFilter(600);
    data_ecg_median = medFilt1(data_ecg_median);
    data_ecg_median = medFilt2(data_ecg_median);
    % plot(time(1:10000),data_ecg_median(1:10000),'r');
    data_ecg_bwr = data_ecg - data_ecg_median;
    % plot(time(1:10000),data_ecg_bwr(1:10000),'g');

    data_ecg_bwr_zs = zscore(data_ecg_bwr);
    % plot(time(1:10000),data_ecg_bwr_zs(1:10000),'y');

    data(:,1) = data_ecg_bwr_zs;
    save(['data_preprocess1/',name_str,'_process1.mat'],'data','isi','isi_units','labels','units','-v6');
end
