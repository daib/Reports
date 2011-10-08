function [ weights ] = interpweights(I, ij, segment)

weights = zeros(size(I));

[h,w] = size(I);

for i = 1:h
    for j = 1:w
        Is = I(i, j);
        if Is >= ij && Is < (ij + segment)
            weights(i,j) = 1 - (Is - ij)/segment;
        elseif Is < ij && Is >= (ij - segment)
            weights(i,j) = 1 - (ij - Is)/segment;
        end
    end
end

end

