im = im2single(imread('./input.png'));


% path size
pW = 30;    
pH = 30;

%synthesis image size

sW = 512;
sH = 512;

qim = quilting(im, pW, pH, sW, sH);

imwrite(qim, 'qim.png', 'png');

