function [ lum ] = luminance( img )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
% separate color and intensity
r_index = 1;
g_index = 2;
b_index = 3;

r_weight = 0.27;
g_weight = 0.67;
b_weight = 0.06;
whole_weight = 1;

lum = (img(:,:, r_index) * r_weight + img(:,:, g_index) * g_weight + img(:,:, b_index) * b_weight)/whole_weight;

end

