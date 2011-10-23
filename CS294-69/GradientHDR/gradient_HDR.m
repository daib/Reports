function [ rgb ] = gradient_HDR(hdr_filename, alpha, beta)
hdr = hdrread(hdr_filename);


% r = hdr(:,:, r_index)./H;
% g = hdr(:,:, g_index)./H;
% b = hdr(:,:, b_index)./H;

H = luminance(hdr);

% imshow(mat2gray(H));

[Y, X] = size(H);


% compute ?H(x, y) ? (H(x+1, y)?H(x, y),H(x, y+1)?H(x, y))

gradientH(:,:,1) = cat(2, H(:, X), diff(H, 1, 2)); 
gradientH(:,:,2) = cat(1, H(Y, :), diff(H, 1, 1)); 

Phi = gradient_attenuation(H, 0, alpha, beta);

imshow(Phi);
% imshow(scaling_factor(Phi, 0, alpha, beta));

G(:,:,1) = gradientH(:,:,1) .* Phi;
G(:,:,2) = gradientH(:,:,2) .* Phi;

% imshow(mat2gray(G(:,:,1)));

% divG(:,:,2) = cat(2, diff(G(:,:,2), 1, 2), G(:, 1, 2)); % x
% divG(:,:,1) = cat(1, diff(G(:,:,1), 1, 1), G(1, :, 1)); % y

% find I such that ?2I = divG using multigrid method

end

