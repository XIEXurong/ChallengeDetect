
% all person analysis

all_persons_list='used_persons_list.txt';
name_list=importdata(all_persons_list);
anals_sub.good_person=name_list(:)';
name_num=size(anals_sub.good_person,2);

% check all files
for name_id=1:name_num
    name_str=anals_sub.good_person{name_id};
    ls(['process/',name_str,'_analysis.mat']);
end

load(['data_preprocess3/','comA_person_1','_featNlab.mat']);
feat_lab = feats_all.feat_emg.feat_lab;
    feat_lab = {['1_',feat_lab{1}],['2_',feat_lab{1}],['3_',feat_lab{1}],['4_',feat_lab{1}],['5_',feat_lab{1}],['6_',feat_lab{1}],['7_',feat_lab{1}],...
        feat_lab{2},['1_',feat_lab{3}],['2_',feat_lab{3}],['3_',feat_lab{3}],['4_',feat_lab{3}],['5_',feat_lab{3}],['6_',feat_lab{3}],['7_',feat_lab{3}],...
        feat_lab{4},feat_lab{5}};
anals_sub.feats_lab_all_persons = [feats_all.feat_ecg_time.feat_lab,feats_all.feat_ecg_frq.feat_lab,feats_all.feat_tem.feat_lab,feats_all.feat_rsp.feat_lab,feat_lab,feats_all.feat_eda.feat_lab];
anals_sub.feats_lab_num = [size(feats_all.feat_ecg_time.feat_lab,2),size(feats_all.feat_ecg_frq.feat_lab,2),size(feats_all.feat_tem.feat_lab,2),size(feats_all.feat_rsp.feat_lab,2),size(feat_lab,2),size(feats_all.feat_eda.feat_lab,2)];

anals_sub.feat_all_persons = [];
anals_sub.good_person_sig = cell(name_num,2);
anals_sub.batch_lab_all_persons = [];
anals_sub.mean_ = [];
anals_sub.std_ = [];
for name_id = 1:name_num
    name_str=anals_sub.good_person{name_id};
    load(['process/',name_str,'_analysis.mat']);
    anals_sub.good_person_sig{name_id,1} = name_str;
    anals_sub.feat_all_persons = [anals_sub.feat_all_persons; anals.feat_all_mat];
    anals_sub.batch_lab_all_persons = [anals_sub.batch_lab_all_persons;anals.batch_lab];
    anals_sub.mean_ = [anals_sub.mean_; anals.mean_];
    anals_sub.std_ = [anals_sub.std_; anals.std_];
end


anals_sub.feats_lab_all_persons_new = anals_sub.feats_lab_all_persons;
for i= 1:15
    anals_sub.feats_lab_all_persons_new{i} = ['ecg_time_', anals_sub.feats_lab_all_persons_new{i}];
end
for i= 16:29
    anals_sub.feats_lab_all_persons_new{i} = ['ecg_frq_', anals_sub.feats_lab_all_persons_new{i}];
end
for i= 30:36
    anals_sub.feats_lab_all_persons_new{i} = ['tem_', anals_sub.feats_lab_all_persons_new{i}];
end
for i= 37:51
    anals_sub.feats_lab_all_persons_new{i} = ['rsp_', anals_sub.feats_lab_all_persons_new{i}];
end
for i= 52:68
    anals_sub.feats_lab_all_persons_new{i} = ['emg_', anals_sub.feats_lab_all_persons_new{i}];
end
for i= 69:80
    anals_sub.feats_lab_all_persons_new{i} = ['eda_', anals_sub.feats_lab_all_persons_new{i}];
end

% save analysis
save('process/sub_goodperson_analysis.mat', 'anals_sub');

