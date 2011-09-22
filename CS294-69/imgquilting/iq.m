im = im2single(imread('./weave.jpg'));


% path size
pW = 80;    
pH = 80;

%synthesis image size

sW = 512;
sH = 512;

qim = quilting(im, pW, pH, sW, sH);

imwrite(qim, 'qim.png', 'png');

