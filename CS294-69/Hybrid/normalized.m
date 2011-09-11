function [ nimg ] = normalized( img )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
m = img;
for i = 1:ndims(img)
    m = min(m);
end

if m < 0
    img = img - m;
end

m = img;

for i = 1:ndims(img)
    m = max(m);
end

if m > 1
    img = img / m;
end
nimg = img;
    


