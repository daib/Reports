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


logLuminance = log(ycbcr(:,:,1));
sigma = min(size(logLuminance)) * .02;

f = fspecial('gaussian', min(size(logLuminance)), sigma);
%f = f / max(f(:));
% points = ndgrid(-h:h, 1);
% g = gauss_distribution(points, 0, sigma);

%lIm = fastbilateral(lIm, f, g, 8, sigma);
lIm = fastbilateral(logLuminance, f, 4, sigma);

imshow(lIm);

% obtain the details
hIm = logLuminance - lIm;

imshow(hIm);


%reduce the contrast of the low level details
lIm = lIm / contrast;

imshow(lIm);

ycbcr(:,:,1) = exp(hIm + lIm);

rgb = ycbcr2rgb(ycbcr);


imshow(rgb);

end

