function [ displayimg ] = tonemapping( hdr_filename )
% This function implement fast bilateral filering
% for tone mapping

hdr = hdrread(hdr_filename);

%rgb = tonemap(hdr);
%imshow(rgb);
%displayimg = rgb;

% separate color and intensity

% to chrominance scale
ycbcr = rgb2ycbcr(double(hdr));

% tranform luminance of the image to frequency domain
fy = fftshift(fft2(ycbcr(:,:,1)));

% then separate between high frequency parts and low frequency part

[h,w] = size(fy);

proportion = 5;

fthresholdH = floor(h / proportion);

fthresholdW = floor(w / proportion);

halfH = floor(h/2);
halfW = floor(w/2);

lfY = fy;
hfy = zeros(size(fy));

lfY(halfH - fthresholdH:halfH + fthresholdH, halfW - fthresholdW:halfW + fthresholdW) = 0;

hfy(halfH - fthresholdH:halfH + fthresholdH, halfW - fthresholdW:halfW + fthresholdW) = fy(halfH - fthresholdH:halfH + fthresholdH, halfW - fthresholdW:halfW + fthresholdW);

% now, manipulate the flow frequency image luminance using bilateral filter
lIm = ifft2(ifftshift(lfY));

sigma = 10;

f = fspecial('gaussian', min(h,w), sigma);
% points = ndgrid(-h:h, 1);
% g = gauss_distribution(points, 0, sigma);

%lIm = fastbilateral(lIm, f, g, 8, sigma);
lIm = fastbilateral(lIm, f, 8, sigma);

lfy = fftshift(fft2(lIm));

fy = hfy + lfy;

ycbcr(:,:,1) = abs(ifft2(ifftshift(fy)));

rgb = ycbcr2rgb(ycbcr);


imshow(rgb);

end

