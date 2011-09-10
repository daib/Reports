function himage = hybridImage(im1, im2, cutoff_low, cutoff_high)

fim1 = fftshift(fft2(im1));
fim2 = fftshift(fft2(im2));

[h1, w1, b1] = size(im1);
[h2, w2, b2] = size(im2);

%g1 = mat2gray(fspecial('gaussian', 2 * w1, 1));

g1 = zeros(h1,w1);
g1 = mat2gray(gauss2d(g1, 10, [h1/2 w1/2]));

cutoffg1 = zeros(size(g1));

cutoffg1((h1/2 - cutoff_low):(h1/2 + cutoff_low),(w1/2 - cutoff_low):(w1/2 + cutoff_low)) = g1((h1/2 - cutoff_low):(h1/2 + cutoff_low),(w1/2 - cutoff_low):(w1/2 + cutoff_low));

filteredfim1 = cutoffg1 .* fim1;

imagesc(abs(ifft2(ifftshift(filteredfim1))));

%g2 = 1 - mat2gray(fspecial('gaussian', 2 * w2, 1));

g2 = zeros(h2,w2);
g2 = 1 - mat2gray(gauss2d(g2, 10, [h1/2 w1/2]));

cutoffg2 = g2;

cutoffg2((h2/2 - cutoff_high):(h2/2 + cutoff_high),(w2/2 - cutoff_high):(w2/2 + cutoff_high)) = 0;

filteredfim2 = cutoffg2 .* fim2;

imagesc(abs(ifft2(ifftshift(filteredfim2))));

himage = abs(ifft2(ifftshift(filteredfim1 + filteredfim2)));

imagesc(himage);

