function [time_lab,event_lab] = find_lab(time,event,lab,col)

time_lab = [];
event_lab = {};
[r,c] = size(event);
if col < 1
    col = 1;
elseif col > c
    col = c;
end

for i=1:r
    if strfind(event{i,col},lab)
        time_lab = [time_lab;time(i)];
        event_lab = [event_lab;event(i,:)];
    end
end
