function [data_batch, N] = batch_data(data, batch_size, frame_shift)

sample_num = size(data,1);
N = ceil(1 + (sample_num-batch_size)/frame_shift); % batch number

data_batch = cell(N,1);

for i = 1:(N-1)
    time_start = (i-1)*frame_shift + 1;
    time_end = time_start + batch_size -1;
    data_batch{i} = data(time_start:time_end,1)';
end

time_start = (N-1)*frame_shift + 1;
data_batch{N} = data(time_start:end,1)';
