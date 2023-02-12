function [time,event] = process_event_txt(table)

for N_start=1:size(table,1)
    if sum(table{N_start,1} == 0)
        break
    end
end

N = table{end,1};
event = table{N_start:(N_start+N),3:4};

time = zeros(N+1,1);
for i=N_start:(N_start+N)
    if strfind(table{i,2}{1},'sec')
        time(i-N_start+1) = str2num(table{i,2}{1}(1:end-4));
    elseif strfind(table{i,2}{1},'min')
        time(i-N_start+1) = str2num(table{i,2}{1}(1:end-4))*60;
    end
end
