function [event, Penh] = readtxttable_all(txttable)

table_all=readtable(txttable);

event_start = 1;
for Penh_start=1:size(table_all,1)
    if table_all{Penh_start,1} == 0
        event_start = Penh_start;
    end

    if strfind(table_all{Penh_start,8}{1}, 'Penh')
        break
    end
end

if Penh_start < size(table_all,1)
    event_end = Penh_start - 4; % two table
    if event_end < event_start
        sprintf('May have wrong position, change it!')
        event_end = size(table_all,1);
    end
else
    event_end = Penh_start; % one table
end

event = table_all(1:event_end,:);
Penh = table_all(Penh_start:end,:);
