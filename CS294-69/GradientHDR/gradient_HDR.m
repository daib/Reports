function [ rgb ] = gradient_HDR(hdr_filename, alpha, beta)
hdr = hdrread(hdr_filename);

% input intensity= 1/61*(R*20+G*40+B)
% r=R/(input intensity), g=G/input intensity, B=B/input intensity
% log(base)=Bilateral(log(input intensity))
% log(detail)=log(input intensity)-log(base)
% log (output intensity)=log(base)*compressionfactor+log(detail) - log_absolute_scale
% R output = r*10^(log(output intensity)), etc.

% separate color and intensity
r_index = 1;
g_index = 2;
b_index = 3;

r_weight = 20;
g_weight = 40;
b_weight = 1;

H = (hdr(:,:, r_index) * r_weight + hdr(:,:, g_index) * g_weight + hdr(:,:, b_index) * b_weight)/61;

% r = hdr(:,:, r_index)./H;
% g = hdr(:,:, g_index)./H;
% b = hdr(:,:, b_index)./H;

[Y, X] = size(H);


% compute ?H(x, y) ? (H(x+1, y)?H(x, y),H(x, y+1)?H(x, y))

gradientH(:,:,1) = cat(1, H(:, X), diff(H, 1, 2)); 
gradientH(:,:,2) = cat(1, H(Y, :), diff(H, 1, 1)); 

Phi = gradient_attenuation(gradientH, 0, alpha, beta);

G = gradientH .* Phi;

divG(:,:,1) = cat(1, diff(G, 1, 2), H(:, 1)); % x
divG(:,:,2) = cat(1, diff(G, 1, 1), G(1, :)); % y

% find I such that ?2I = divG using multigrid method

end

