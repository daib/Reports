function [ PhiK ] = gradient_attenuation( H, k, alpha, beta)

%compute gaussian image at this level

if k == 0
    GaussianH = H;
else
    % generate Gaussian pyramid
    gkernel = fspecial('gaussian', 5);

    gkernel = gkernel ./ sum(gkernel(:));
    GaussianH(:,:) = conv2(H, gkernel, 'same');
end
% GaussianH(:,:,2) = conv2(H(:,:,2), gkernel, 'same');

phiK = scaling_factor(GaussianH, k, alpha, beta);

% imshow((phiK)/1.3);

% recursively compute Phi using gaussian pyramid

if min(size(GaussianH(:,:,1))) >= 64
    
    % reduce the matrices' size
    rHGaussian = imresize(GaussianH, ceil(size(GaussianH)/2) + 2);
    % rHGaussian = imresize(GaussianH, 1/2);
    PhiKPP = gradient_attenuation(rHGaussian, k+1, alpha, beta);
    
    % imshow(mat2gray(PhiKPP));
    
    PhiK = imresize(PhiKPP, size(phiK), 'bilinear') .* phiK;
    % imshow((PhiK)/1.3);
    % PhiK = interp2(PhiKPP, size(phiK), 'linear') .* phiK;
else
    PhiK = phiK;
end

end

