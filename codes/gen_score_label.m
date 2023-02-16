function [challenge_dist,challenge_scores,challenge_id] = gen_score_label(lab_self_name, time_step)

lab_table = readtable(lab_self_name, 'Delimiter', ',');

r = size(lab_table,1);

challenge_scores  = zeros(r,7);
challenge_dist = zeros(r,7);
challenge_id = zeros(r,3);

for i = 1:r
    time_start = time_step*(i-1)+1;
    time_end = time_step*i;
    cogn_avg = mean(lab_table{i,2:12});
    emot_avg = mean(lab_table{i,13:21});
    phys_avg = mean(lab_table{i,22:26});
    deci_avg = mean(lab_table{i,27:31});
    challenge_scores(i,1:6) = [time_start, time_end, cogn_avg, emot_avg, phys_avg, deci_avg];
end

mean_all = mean(mean(challenge_scores(:,3:6)));

challenge_scores(:,7) = mean_all;
challenge_dist = challenge_scores;
challenge_dist(:,3:7) = challenge_dist(:,3:7)./repmat(sum(challenge_dist(:,3:7),2),1,5);

challenge_id(:,1:2) = challenge_dist(:,1:2);
[~, challenge_id(:,3)] = max(challenge_dist(:,3:7), [], 2);
