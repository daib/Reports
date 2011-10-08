function [ displayimg ] = tonemapping( hdr_filename, contrast)
% This function implement fast bilateral filering
% for tone mapping

hdr = hdrread(hdr_filename);

%rgb = tonemap(hdr);
%imshow(rgb);
%displayimg = rgb;

% separate color and intensity

% to chrominance scale
ycbcr = rgb2ycbcr(double(hdr));

sigma = 18;

f = fspecial('gaussian', min(size(ycbcr(:,:,1))), sigma);
% points = ndgrid(-h:h, 1);
% g = gauss_distribution(points, 0, sigma);

%lIm = fastbilateral(lIm, f, g, 8, sigma);
lIm = fastbilateral(ycbcr(:,:,1), f, 8, sigma);

% obtain the details
hIm = ycbcr(:,:,1) - lIm;

imshow(hIm);

imshow(lIm);
%reduce the contrast of the low level details
lIm = lIm / contrast;

imshow(lIm);

ycbcr(:,:,1) = hIm + lIm;

rgb = ycbcr2rgb(ycbcr);


imshow(rgb);

end

