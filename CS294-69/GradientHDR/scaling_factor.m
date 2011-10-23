function [ phi ] = scaling_factor( gradientH, k, alpha, beta)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[Y, X] = size(gradientH(:,:,1));

gHK = gradientH;

for x = 2:(X-1)
    gHK(:, x, :) = (gradientH(:, x+1, :) - gradientH(:, x-1, :)) / 2;
end

for y = 2:(Y-1)
    gHK(y, :, :) = (gradientH(y+1, :, :) - gradientH(y-1, :, :)) / 2;
end

% compute the magnitude of the gradient using euclide distance
magGHK = sqrt(sum(gHK.^2, 3));

phi = (alpha./magGHK).^(1-beta);

end

