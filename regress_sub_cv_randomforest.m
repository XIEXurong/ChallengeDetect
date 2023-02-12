
load('process/sub_goodperson_analysis.mat');

% K-fold cross vaildation
cv_sub_rforest.K = 10;
cv_sub_rforest.data_num = size(anals_sub.feat_all_persons,1);
cv_sub_rforest.batch_size = floor(cv_sub_rforest.data_num/cv_sub_rforest.K);
cv_sub_rforest.rand_order = randperm(cv_sub_rforest.data_num);

cv_sub_rforest.emot_lab = anals_sub.batch_lab_all_persons(:,13);
cv_sub_rforest.pys_lab = anals_sub.batch_lab_all_persons(:,14);
cv_sub_rforest.cog_lab = anals_sub.batch_lab_all_persons(:,12);
cv_sub_rforest.low_lab = anals_sub.batch_lab_all_persons(:,15);


% all feats
min_leave_num = 3;
rand_sample = 0.75;
cv_sub_rforest.glm_ori = cell(cv_sub_rforest.K,1);
cv_sub_rforest.acc_ori = zeros(cv_sub_rforest.K,5);
cv_sub_rforest.mse_ori = zeros(cv_sub_rforest.K,4);
cv_sub_rforest.mae_ori = zeros(cv_sub_rforest.K,4);
cv_sub_rforest.rmse_ori = zeros(cv_sub_rforest.K,4);
cv_sub_rforest.corr_ori = zeros(cv_sub_rforest.K,4);
cv_sub_rforest.corr_p_ori = zeros(cv_sub_rforest.K,4);
cv_sub_rforest.confus_ori.precision = zeros(cv_sub_rforest.K,5);
cv_sub_rforest.confus_ori.recall = zeros(cv_sub_rforest.K,5);
for k=1:cv_sub_rforest.K
    % k=1;
    data_test_id = cv_sub_rforest.rand_order((k-1)*cv_sub_rforest.batch_size+1:(k-1)*cv_sub_rforest.batch_size+cv_sub_rforest.batch_size);
    data_test = anals_sub.feat_all_persons(data_test_id,:);
    label_test_emot = cv_sub_rforest.emot_lab(data_test_id);
    label_test_pys = cv_sub_rforest.pys_lab(data_test_id);
    label_test_cog = cv_sub_rforest.cog_lab(data_test_id);
    label_test_low = cv_sub_rforest.low_lab(data_test_id);
    label_test = [label_test_emot, label_test_pys, label_test_cog, label_test_low];
    
    data_train_id = [cv_sub_rforest.rand_order(1:(k-1)*cv_sub_rforest.batch_size),cv_sub_rforest.rand_order((k-1)*cv_sub_rforest.batch_size+cv_sub_rforest.batch_size+1:end)];
    data_train = anals_sub.feat_all_persons(data_train_id,:);
    label_train_emot = cv_sub_rforest.emot_lab(data_train_id);
    label_train_pys = cv_sub_rforest.pys_lab(data_train_id);
    label_train_cog = cv_sub_rforest.cog_lab(data_train_id);
    label_train_low = cv_sub_rforest.low_lab(data_train_id);
    label_train = [label_train_emot, label_train_pys, label_train_cog, label_train_low];

    cv_sub_rforest.glm_ori{k}.emot = fitrensemble(data_train, label_train_emot,'Method','Bag','Resample','on','Learners',templateTree('MinLeafSize',min_leave_num),'FResample',rand_sample);
    cv_sub_rforest.glm_ori{k}.pys = fitrensemble(data_train, label_train_pys,'Method','Bag','Resample','on','Learners',templateTree('MinLeafSize',min_leave_num),'FResample',rand_sample);
    cv_sub_rforest.glm_ori{k}.cog = fitrensemble(data_train, label_train_cog,'Method','Bag','Resample','on','Learners',templateTree('MinLeafSize',min_leave_num),'FResample',rand_sample);
    cv_sub_rforest.glm_ori{k}.low = fitrensemble(data_train, label_train_low,'Method','Bag','Resample','on','Learners',templateTree('MinLeafSize',min_leave_num),'FResample',rand_sample);

    linear_test = zeros(size(data_test,1),4);
    linear_test(:,1) = predict(cv_sub_rforest.glm_ori{k}.emot,data_test);
    linear_test(:,2) = predict(cv_sub_rforest.glm_ori{k}.pys,data_test);
    linear_test(:,3) = predict(cv_sub_rforest.glm_ori{k}.cog,data_test);
    linear_test(:,4) = predict(cv_sub_rforest.glm_ori{k}.low,data_test);

    cv_sub_rforest.mse_ori(k,:) = mean((linear_test - label_test).^2,1);
    [corr_,corr_p_] = corr(linear_test,label_test,'Tail','right');
    cv_sub_rforest.corr_ori(k,:) = diag(corr_);
    cv_sub_rforest.corr_p_ori(k,:) = diag(corr_p_);

    label_test_ori = anals_sub.batch_lab_all_persons(data_test_id,[8,9,7,10]);
    linear_test_ori = linear_test.*repmat(anals_sub.std_(data_test_id),1,4)+repmat(anals_sub.mean_(data_test_id),1,4);

    cv_sub_rforest.mae_ori(k,:) = mean(abs(linear_test_ori - label_test_ori),1);
    cv_sub_rforest.rmse_ori(k,:) = mean((linear_test_ori - label_test_ori).^2,1).^0.5;

    predict_test = [(linear_test_ori>=4),prod(linear_test_ori<4,2)];
    predict_test_label = [(label_test_ori>=4),prod(label_test_ori<4,2)];

    cv_sub_rforest.acc_ori(k,:) = mean(predict_test == predict_test_label,1);
    for i = 1:5
        cv_sub_rforest.confus_ori.precision(k,i) = mean(predict_test_label(round(predict_test(:,i))==1,i));
        if ~(cv_sub_rforest.confus_ori.precision(k,i) >= 0)
            cv_sub_rforest.confus_ori.precision(k,i) = 0; % NaN
        end
        cv_sub_rforest.confus_ori.recall(k,i) = mean(round(predict_test(predict_test_label(:,i)==1,i)));
        if ~(cv_sub_rforest.confus_ori.recall(k,i) >= 0)
            cv_sub_rforest.confus_ori.recall(k,i) = 0; % NaN
        end
    end

    sprintf('For k = %d, MAE = %.2f, RMSE = %.2f, Acc_2 = %.1f%%', k, ...
        mean(cv_sub_rforest.mae_ori(k,:)), ...
        mean(cv_sub_rforest.rmse_ori(k,:)), ...
        100*mean(cv_sub_rforest.acc_ori(k,:)))
end

cv_sub_rforest.acc_ori_allK = sum(cv_sub_rforest.acc_ori,1)/cv_sub_rforest.K;
cv_sub_rforest.acc_std_ori_allK = std(cv_sub_rforest.acc_ori,1);
cv_sub_rforest.acc_ori_all = mean(cv_sub_rforest.acc_ori_allK);
cv_sub_rforest.acc_std_ori_all = mean(cv_sub_rforest.acc_std_ori_allK);

cv_sub_rforest.confus_ori.macro_f1 = 2.*cv_sub_rforest.confus_ori.precision.*cv_sub_rforest.confus_ori.recall./(cv_sub_rforest.confus_ori.precision+cv_sub_rforest.confus_ori.recall+1e-10);
cv_sub_rforest.confus_ori.macro_f1_K = mean(cv_sub_rforest.confus_ori.macro_f1,1);
cv_sub_rforest.confus_ori.macro_f1_all = mean(cv_sub_rforest.confus_ori.macro_f1_K);

cv_sub_rforest.mse_ori_allK = sum(cv_sub_rforest.mse_ori,1)/cv_sub_rforest.K;
cv_sub_rforest.mse_std_ori_allK = std(cv_sub_rforest.mse_ori,1);
cv_sub_rforest.mse_ori_all = mean(cv_sub_rforest.mse_ori_allK);
cv_sub_rforest.mse_std_ori_all = mean(cv_sub_rforest.mse_std_ori_allK);

cv_sub_rforest.mae_ori_allK = sum(cv_sub_rforest.mae_ori,1)/cv_sub_rforest.K;
cv_sub_rforest.mae_std_ori_allK = std(cv_sub_rforest.mae_ori,1);
cv_sub_rforest.mae_ori_all = mean(cv_sub_rforest.mae_ori_allK);
cv_sub_rforest.mae_std_ori_all = mean(cv_sub_rforest.mae_std_ori_allK);

cv_sub_rforest.rmse_ori_allK = sum(cv_sub_rforest.rmse_ori,1)/cv_sub_rforest.K;
cv_sub_rforest.rmse_std_ori_allK = std(cv_sub_rforest.rmse_ori,1);
cv_sub_rforest.rmse_ori_all = mean(cv_sub_rforest.rmse_ori_allK);
cv_sub_rforest.rmse_std_ori_all = mean(cv_sub_rforest.rmse_std_ori_allK);

cv_sub_rforest.corr_ori_allK = sum(cv_sub_rforest.corr_ori,1)/cv_sub_rforest.K;
cv_sub_rforest.corr_std_ori_allK = std(cv_sub_rforest.corr_ori,1);
cv_sub_rforest.corr_ori_all = mean(cv_sub_rforest.corr_ori_allK);
cv_sub_rforest.corr_std_ori_all = mean(cv_sub_rforest.corr_std_ori_allK);


% print the results
sprintf('On average, MAE = %.2f, RMSE = %.2f, Acc_2 = %.1f%%, F1_2 = %.1f%%', ...
    cv_sub_rforest.mae_ori_all, ...
    cv_sub_rforest.rmse_ori_all, ...
    100*cv_sub_rforest.acc_ori_all, ...
    100*cv_sub_rforest.confus_ori.macro_f1_all)


save('process/regress_sub_cv_goodpersons_rforest','cv_sub_rforest','-v7.3');

