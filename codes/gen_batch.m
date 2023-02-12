function batch_id = gen_batch(time_label,time_shift,max_batch)

batch_id = [];

episode_num = size(time_label.label,1);

for i = 1:episode_num
    time_s = time_label.start(i);
    time_e = time_label.end(i);
    if time_e > 0
        batch_s = round(time_s/time_shift)+1;
        batch_e = floor(time_e/time_shift);
        if batch_e > max_batch
            batch_e = max_batch;
        end
        batch_id_tmp = (batch_s:batch_e)';
        batch_id = [batch_id; batch_id_tmp];
    end
end
