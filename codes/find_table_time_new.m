function time_label = find_table_time_new(label_table,name)

test_type = name(4);
name0 = name(6:end);

sub_table = label_table.(test_type);
var_list = sub_table.Properties.VariableNames;

time_start = [name0,test_type,'_start'];
time_end = [name0,test_type,'_end'];
c = length(var_list);

check_start = 0;
check_end = 0;
for i=3:c
    string = var_list(i);
    if contains(string, time_start)
        check_start = 1;
    end
    if contains(string, time_end)
        check_end = 1;
    end
end

if check_start*check_end == 0
    time_label.have_label = 0;
    sprintf("Name = %s does not have time label", name)
else
    time_label.have_label = 1;
    time_label.start = sub_table.(time_start);
    time_label.end = sub_table.(time_end);
    time_label.label = sub_table.('Label');
end
