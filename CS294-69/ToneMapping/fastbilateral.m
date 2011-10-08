function [ J ] = fastbilateral( I, f, z, sigma )
% This function implements the fast bilateral algorithm
% with I is the intensity of the image, f is the spatial kernels
% andg is the intensity influence, z is the downsampling factor

J = zeros(size(I));
II = imresize(I,1/z);
ff = imresize(f,1/z);


minI = min(I(:));
maxI = max(I(:));

NB_SEGMENTS = floor((maxI - minI)/sigma);

segmentLen = ((maxI - minI) / NB_SEGMENTS);

for j = 0:NB_SEGMENTS
    ij = minI + segmentLen * j;
    %Gj = g(II - ij);
    %residual = II - ij;
    Gj = gauss_distribution(II - ij, 0, 0.4); %normalize the distribution
    %Gj = Gj/max(Gj(:));
    
    Kj = conv2(Gj, ff, 'same');
    % surf(Kj);
    Hj = Gj .* II;
    Hjstar = conv2(Hj, ff, 'same');
    
    JJj = Hjstar ./ Kj;
    
    % surf(JJj);
    
    Jj = imresize(JJj, size(I));
    J = J + Jj .* interpweights(I, ij, segmentLen);
    
    clear Gj;
    clear Kj;
    clear Hj;
    clear Hjstar;
    clear JJj;
end

