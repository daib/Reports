function [ rgb ] = gradient_HDR(hdr_filename, alpha, beta)
hdr = hdrread(hdr_filename);


% r = hdr(:,:, r_index)./H;
% g = hdr(:,:, g_index)./H;
% b = hdr(:,:, b_index)./H;

H = luminance(hdr);

% imshow(mat2gray(H));

[Y, X] = size(H);


% compute ?H(x, y) ? (H(x+1, y)?H(x, y),H(x, y+1)?H(x, y))

%gradientH(:,:,1) = cat(2, H(:, X), diff(H, 1, 2)); 
%gradientH(:,:,2) = cat(1, H(Y, :), diff(H, 1, 1)); 

gradientH(:,:,1) =  H(2:Y-1, 3:X) - H(2:Y-1, 2:X-1);
gradientH(:,:,2) =  H(3:Y, 2:X-1) - H(2:Y-1, 2:X-1); 

Phi = gradient_attenuation(H, 0, alpha, beta);

%imshow(Phi);
imwrite(Phi, 'phi.png', 'png');
% imshow(scaling_factor(Phi, 0, alpha, beta));

G = zeros(size(H));
G(2:Y-1,2:X-1,1) = gradientH(:,:,1) .* Phi; % x
G(2:Y-1,2:X-1,2) = gradientH(:,:,2) .* Phi; % y

imshow(sum(G(:,:,1), 3));

diffG(:,:,1) = cat(2, diff(G(:,:,1), 1, 2), G(:, 1, 1)); % x
diffG(:,:,2) = cat(1, diff(G(:,:,2), 1, 1), G(1, :, 2)); % y

divG = sum(diffG, 3);

imshow(divG);

%[Y, X, dims] = size(G);

% divG = (G(2:Y, 2:X, 1) - G(2:Y, 1:X-1, 1)) + (G(2:Y, 2:X, 2) - G(1:Y-1, 2:X, 2));

% find I such that ?2I = divG using multigrid method

I = mgsolve(divG, 10);

%imwrite(I, 'I.png', 'png');
imshow(mat2gray(I));

s = 0.5;

% [Y, X] = size(H);
%base = 2;

for i=1:3
    %c = ((hdr(base:Y-1,base:X-1, i) ./ H(base:Y-1, base:X-1))).^s;
    c = (hdr(:,:, i) ./ H).^s;
    rgb(:,:,i) =  c .* I;
end

imshow(rgb);

imwrite(rgb, 'rgb.png', 'png');

end

