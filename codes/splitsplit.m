function splitsplit_num = splitsplit(split_num,sqlen)

splitsplit_num = [];

for i = 1:length(split_num)
    num = floor(split_num(i)/sqlen);
    res = split_num(i) - num*sqlen;
    tmp = sqlen*ones(1,num);
    if res > 0
        tmp = [tmp, res];
    end
    splitsplit_num = [splitsplit_num, tmp];
end
