function [ phi ] = scaling_factor( H, k, alpha, beta)

[Y, X] = size(H(:,:,1));

gHK = H;

%gHK(:,:, 1) = H;
%gHK(:,:, 2) = H;


% gHK = zeros(Y - 2, X - 2, 2);

for x = 2:(X-1)
    gHK(:, x, 1) = (H(:, x+1) - H(:, x-1));
    % gHK(:, x - 1, 1) = (H(2:Y-1, x+1) - H(2:Y-1, x-1));
end

for y = 2:(Y-1)
    gHK(y - 1, :, 2) = (H(y+1, :, :) - H(y-1, :));
    % gHK(y - 1, :, 2) = (H(y+1, 2:X-1) - H(y-1, 2:X-1));
end

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

