function [ weights ] = interpweights(I, i, segment)

weights = zeros(size(i));

[h,w] = size(i);

for i = 1:h
    for j = 1:w
        Is = I(i, j);
        if Is >= i && Is < (i + segment)
            weights(i,j) = 1 - (Is - i)/segment;
        elseif Is < i && Is >= (i - segment)
            weights(i,j) = 1 - (i - Is)/segment;
        end
    end
end

end

