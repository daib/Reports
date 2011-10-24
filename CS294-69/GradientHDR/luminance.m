function [ lum ] = luminance( img )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
% separate color and intensity
r_index = 1;
g_index = 2;
b_index = 3;

% r_weight = 0.3;
% g_weight = 0.59;
% b_weight = 0.11;
% whole_weight = 1;

r_weight = 20;
g_weight = 40;
b_weight = 1;
whole_weight = 61;

lum = (img(:,:, r_index) * r_weight + img(:,:, g_index) * g_weight + img(:,:, b_index) * b_weight)/whole_weight;
%ycbcr = rgb2ycbcr(double(img));

%lum = ycbcr(:,:,1);

end

