all_persons_list='used_persons_list.txt';
name_list=importdata(all_persons_list);
name_list=name_list(:)';
name_num=size(name_list,2);

time_step = 30; % 30s for 1 lab score

anals.time_step = time_step;

% check all files
for name_id=1:name_num
    name_str=name_list{name_id};
    ls(['data_preprocess3/',name_str,'_featNlab.mat']);
end

for name_id = 1:name_num
    name_str=name_list{name_id};
    name_str
    load(['data_preprocess3/',name_str,'_featNlab.mat']);

    % episode_num = size(time_label.label,1);
    % episode_id = (1:episode_num)';
    % challenge_id = cell(episode_num,5);

    lab_self_name = ['data/CORGIS_', name_str, '.csv'];
    [challenge_dist,challenge_scores,challenge_id] = gen_score_label(lab_self_name, time_step);
    % cogn = 1, emot = 2, phys = 3, deci = 4, no_chal = 5

    max_batch = min([ size(feats_all.feat_ecg_time.feats,1); ...
        size(feats_all.feat_ecg_frq.feats,1); ...
        size(feats_all.feat_tem.feats,1); ...
        size(feats_all.feat_rsp.feats,1); ...
        size(feats_all.feat_emg.feats,1); ...
        size(feats_all.feat_eda.feats,1)]);

    time_shift = feats_all.time_shift;
    % [batch_id, batch_lab] = gen_batch_label(time_label,episode_id,challenge_id,time_shift,max_batch);
    batch_id = gen_batch(time_label,time_shift,max_batch);

    r = size(challenge_id,1);
    mean_ = mean(mean(challenge_scores(:,3:6)));
    std_ = std(reshape(challenge_scores(:,3:6),1,r*4));

    challenge_scores_nm = (challenge_scores(:,3:6)-mean_)/std_;

    challenge_lab_all = [challenge_id(:,3), challenge_dist(:,3:7), challenge_scores(:,3:7), challenge_scores_nm];
    batch_lab = [];
    for i = 1:size(batch_id,1)
        lab_id = ceil(batch_id(i)*time_shift/time_step); % used the end of each time shift as label id, as the window is 2 times of time shift
        batch_lab = [batch_lab; challenge_lab_all(lab_id,:)];
    end

    % ecg time feat
    feat_ecg_time = feats_all.feat_ecg_time.feats(batch_id,:);
    feat_ecg_time_zs = zscore(feat_ecg_time);
    anals.mean_ecg_time = mean(feat_ecg_time);
    anals.std_ecg_time = std(feat_ecg_time);
    
    [anals.anova1.ecg_time_all.p,anals.anova1.ecg_time_all.tbl,anals.anova1.ecg_time_all.stats] = anova1(feat_ecg_time_zs',batch_lab(:,1)','off');
    [anals.anova1.ecg_time_all.c,anals.anova1.ecg_time_all.mean,anals.anova1.ecg_time_all.h,anals.anova1.ecg_time_all.gnames] = multcompare(anals.anova1.ecg_time_all.stats,'Display','off');

    % anals.anovan.ecg_time_all = two_way_anova(feat_ecg_time_zs,batch_lab(:,1));

    anals.correlation_ecg_time_all = corr(feat_ecg_time_zs);
    % imagesc(correlation_ecg_time_all); colorbar
    % corrplot(feat_ecg_time_zs)

   

    % ecg frq feat
    feat_ecg_frq = feats_all.feat_ecg_frq.feats(batch_id,:);
    feat_ecg_frq_zs = zscore(feat_ecg_frq);

    % tem feat
    feat_tem = feats_all.feat_tem.feats(batch_id,:);
    feat_tem_zs = zscore(feat_tem);

    % rsp feat
    feat_rsp = feats_all.feat_rsp.feats(batch_id,:);
    feat_rsp_zs = zscore(feat_rsp);

    % emg feat
    feat_emg = feats_all.feat_emg.feats(batch_id,:);
    feat_emg_zs = zscore(feat_emg);

    % eda feat
    feat_eda = feats_all.feat_eda.feats(batch_id,:);
    feat_eda_zs = zscore(feat_eda);
  
    % all feats
    anals.feat_all_mat = [feat_ecg_time_zs, feat_ecg_frq_zs, feat_tem_zs, feat_rsp_zs, feat_emg_zs, feat_eda_zs];

    % save analysis
    anals.mean_ = mean_*ones(size(batch_id,1),1);
    anals.std_ = std_*ones(size(batch_id,1),1);
    anals.batch_lab = batch_lab;
    anals.batch_id = batch_id;
    anals.challenge_id = challenge_id;
    anals.challenge_dist = challenge_dist;
    anals.challenge_scores = challenge_scores;
    save(['process/',name_str,'_analysis.mat'], 'anals');
end


