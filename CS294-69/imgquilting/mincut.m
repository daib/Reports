function [ curve ] = mincut( im1, im2, dir )

error = rgb2gray(im2 - im1).^2;

if dir
    error = error';
end

[h, w, b] = size(error);

minError = error;

% vertical 
for i = 2:h
    for j = 1:w
       minError(i, j) = error(i, j) + min(minError(i-1, max(j-1,1):min(j+1, w)));
    end
end

% trace back
curve = zeros(h);
minVal  = minError(h, 1);
index = 1;
for j = 2:w
    if minVal > minError(h, j)
        minVal = minError(h, j);
        index = j;
    end
end

curve(h) = index;
for i = h-1:1
    minVal = 0;
    for j = max(index - 1, 1):min(index + 1, w);
        if minVal == 0
            minVal = minError(i, j);
            nextIndex = j;
        elseif minVal > minError(i, j)
            minVal = minError(i, j);
            nextIndex = j;    
        end
    end 
    index = nextIndex;
    curve(i) = index;
end

end

