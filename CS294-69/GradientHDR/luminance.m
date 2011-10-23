function [ lum ] = luminance( img )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
% separate color and intensity
r_index = 1;
g_index = 2;
b_index = 3;

r_weight = 0.3;
g_weight = 0.59;
b_weight = 0.11;
whole_weight = 1;

lum = (img(:,:, r_index) * r_weight + img(:,:, g_index) * g_weight + img(:,:, b_index) * b_weight)/whole_weight;

end

