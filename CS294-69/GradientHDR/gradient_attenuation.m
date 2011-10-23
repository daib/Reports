function [ PhiK ] = gradient_attenuation( gradientH, k, alpha, beta)

%compute gaussian image at this level

% generate Gaussian pyramid
gkernel = fspecial('gaussian');

gHGaussian(:,:,1) = conv2(gradientH(:,:,1), gkernel, 'same');
gHGaussian(:,:,2) = conv2(gradientH(:,:,2), gkernel, 'same');

phiK = scaling_factor(gHGaussian, k, alpha, beta);

% reduce the matrices' size
rGHGaussian = imresize(gHGaussian, 1/2);

% recursively compute Phi using gaussian pyramid

if min(size(rGHGaussian)) >= 32
    PhiKPP = gradient_attenuation(rGHGaussian, k+1, alpha, beta);
    
    PhiK = imresize(PhiKPP, size(phiK), 'bilinear') .* phiK;
else
    PhiK = phiK;
end

end

