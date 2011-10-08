function [ rgb ] = tonemapping( hdr_filename, sigmaR, compressionfactor)
% This function implement fast bilateral filering
% for tone mapping

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

intensity = (hdr(:,:, r_index) * r_weight + hdr(:,:, g_index) * g_weight + hdr(:,:, b_index) * b_weight)/61;

r = hdr(:,:, r_index)./intensity;
g = hdr(:,:, g_index)./intensity;
b = hdr(:,:, b_index)./intensity;


sigmaS = min(size(intensity)) * .02;

f = fspecial('gaussian', min(size(intensity)), sigmaS);
%f = f / max(f(:));

% sigmaR = 0.4;
log_intensity = log(intensity);
imshow(log_intensity);

log_base = fastbilateral(log_intensity, f, 4, sigmaR);

imshow(log_base);

% obtain the details
log_detail = log_intensity - log_base;

imshow(log_detail);

log_output_intensity = log_base * compressionfactor + log_detail - max(log_detail(:)) * compressionfactor;

imshow(log_output_intensity);

rgb = zeros(size(hdr));
rgb(:,:,r_index) = r .* exp(log_output_intensity);
rgb(:,:,g_index) = g .* exp(log_output_intensity);
rgb(:,:,b_index) = b .* exp(log_output_intensity);


imshow(rgb);

end

