function feat_rsp = gen_feat_rsp(data_rsp,time,event,lab,batch_time,time_shift,fs)

data_rsp_zs = zscore(data_rsp);

time_lab = find_lab(time,event,lab,1);
frm_lab = round(time_lab*fs);
val_lab = data_rsp_zs(frm_lab);
diff_val_lab = val_lab - [val_lab(1);val_lab(1:end-1)];
period_lab = time_lab - [0;time_lab(1:end-1)];
diff_period_lab = period_lab - [period_lab(1);period_lab(1:end-1)];

frm_num = size(time_lab,1);
batch_id = 1;
batch_time_start = 0;
batch_time_range = [batch_time_start, batch_time];
batch_overlap_range = [time_shift, batch_time];
data_batch = {[]};
data_overlap = [];
for i = 1:frm_num
    if time_lab(i) > batch_time_range(1) && time_lab(i) <= batch_time_range(2)
        data_batch{batch_id,1} = [data_batch{batch_id}, i];
    elseif time_lab(i) > batch_time_range(2)
        batch_id = batch_id + 1;
        batch_time_start = (batch_id-1)*time_shift;
        batch_time_range = [batch_time_start, batch_time_start + batch_time];
        batch_overlap_range = [batch_time_start + time_shift, batch_time_start + batch_time];
        data_batch{batch_id,1} = data_overlap;
        data_overlap = [];
        data_batch{batch_id,1} = [data_batch{batch_id}, i];
    end
    if time_lab(i) > batch_overlap_range(1) && time_lab(i) <= batch_overlap_range(2)
        data_overlap = [data_overlap, i];
    end
end

N = size(data_batch,1);

feat_rsp.feat_lab = {'cycle per minute', 'val mean', 'val std', 'val mad', ...
    'prd mean', 'prd std', 'prd mad', ...
    'Diffval mean', 'Diffval std', 'Diffval mad', 'Diffval mas', ...
    'Diffprd mean', 'Diffprd std', 'Diffprd mad', 'Diffprd mas'};
feat_rsp.feat_num = size(feat_rsp.feat_lab,2);
feat_rsp.feats = zeros(N,feat_rsp.feat_num);
for i=1:N
    batch_tmp = data_batch{i};
    data_v_tmp = val_lab(batch_tmp);
    data_p_tmp = period_lab(batch_tmp);
    data_diffv_tmp = diff_val_lab(batch_tmp);
    data_diffp_tmp = diff_period_lab(batch_tmp);

    feat_rsp.feats(i,1) = length(batch_tmp)/(batch_time/60);

    feat_rsp.feats(i,2) = mean(data_v_tmp);

    if length(batch_tmp) > 1
        feat_rsp.feats(i,3) = std(data_v_tmp);
    end

    feat_rsp.feats(i,4) = mean(abs(data_v_tmp - feat_rsp.feats(i,2)));

    feat_rsp.feats(i,5) = mean(data_p_tmp);

    if length(batch_tmp) > 1
        feat_rsp.feats(i,6) = std(data_p_tmp);
    end

    feat_rsp.feats(i,7) = mean(abs(data_p_tmp - feat_rsp.feats(i,5)));

    feat_rsp.feats(i,8) = mean(data_diffv_tmp);

    if length(batch_tmp) > 1
        feat_rsp.feats(i,9) = std(data_diffv_tmp);
    end

    feat_rsp.feats(i,10) = mean(abs(data_diffv_tmp - feat_rsp.feats(i,8)));

    feat_rsp.feats(i,11) = mean(abs(data_diffv_tmp));

    feat_rsp.feats(i,12) = mean(data_diffp_tmp);

    if length(batch_tmp) > 1
        feat_rsp.feats(i,13) = std(data_diffp_tmp);
    end

    feat_rsp.feats(i,14) = mean(abs(data_diffp_tmp - feat_rsp.feats(i,12)));

    feat_rsp.feats(i,15) = mean(abs(data_diffp_tmp));
end

