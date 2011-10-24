function [ phi ] = scaling_factor( H, k, alpha, beta)

[Y, X] = size(H(:,:,1));

% gHK = zeros(size(H));

%gHK(:,:, 1) = H;
%gHK(:,:, 2) = H;


gHK = zeros(Y - 2, X - 2, 2);

%gHK(:, 2:X-1, 1) = (H(:, 3:X) - H(:, 1:X-2));
%gHK(2:Y-1, :, 2) = (H(3:Y, :) - H(1:Y-2, :));

gHK(:, :, 1) = (H(2:Y-1, 3:X) - H(2:Y-1, 1:X-2));
gHK(:, :, 2) = (H(3:Y, 2:X-1) - H(1:Y-2, 2:X-1));

% gHK = gHK ./ pow2(k+1);

% compute the magnitude of the gradient using euclide space
magGHK = sqrt(sum(gHK.^2, 3));

cAlpha = alpha * mean(magGHK(:));

% phi = (cAlpha ./ magGHK).^(1 - beta);
phi = zeros(size(magGHK));

%for x = 1:X - 2
%    for y = 1:Y-2
for x = 1:size(magGHK, 2)
    for y = 1:size(magGHK, 1)
        if magGHK(y,x) > 0
            phi(y,x) = (cAlpha ./ magGHK(y,x)).^(1 - beta);
            % phi(y,x) = (cAlpha / magGHK(y,x)) * (magGHK(y,x)/cAlpha)^(beta);
        end
    end
end

% phi  = phi ./ pow2(k+1);

end

