function x = id2onehot(id,dim)

l = length(id);

x = zeros(dim,l);

for i=1:l
    x(id(i),i) = 1;
end
