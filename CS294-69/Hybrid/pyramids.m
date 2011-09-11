function [ images ] = pyramids(im12, N)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
g = im12;
images = {};
lowpassfilter = [1/9 1/9 1/9;1/9 1/9 1/9;1/9 1/9 1/9];
for i = 1:N
    %compute low pass of the input im12
    [h, w, b] = size(g);
    for j = 1:b
        lowpassedg(:, :, j) = conv2(g(:, :, j), lowpassfilter, 'same');
    end
    
    l = (g - lowpassedg);
    
    
    images = {images, l};
    imagesc(lowpassedg);
    imagesc(normalized(l));
    clear g;
    for j = 1:b
        g(:,:,j) = imresize(lowpassedg(:,:,j), 0.5);
    end
    clear lowpassedg;
end

