function [ qim ] = quilting( im, pW, pH, sW, sH )
%quilting : function that synthesizes a texture image from an input

[iH,iW,iB] = size(im);

overlappingW  = floor(pW / 10);
overlappingH = floor(pH / 10);


qim = zeros(sH, sW, iB);
patch = zeros(pH, pW, iB);


for j = floor(1:sH/(pH - overlappingH))
    for i = 1:floor(sW/(pW - overlappingW))
        initPoitW = (i - 1) * (pW - overlappingW) + 1;
        initPoitH = (j - 1) * (pH - overlappingH) + 1;
        
        if i == 1 && j == 1
            %first image, get an arbitrary one
             patch = im(1:pH, 1:pW, :);
        else
            %search for a suitable block that is close to neighboring patched
            %blocks
            min = 0;
            minH = 0;
            minW = 0;
            
            % iterate through the input image
            % to find the suitable match
            for w = 1:(iW - pW)
                for h = 1:(iH - pH)
                    tmpPatch = im((h:(h+pH-1)), (w:(w+pW-1)), :);
                    
                    error = 0;
                    %compute overlapping errors
                    %left overlapping
                    if i > 1                   
                        error = overllappingError(tmpPatch(: , (1:overlappingW), :), qim(initPoitH:(initPoitH + pH - 1), (initPoitW:(initPoitW + overlappingW - 1)), :));
                    end
                    
                    %above overlapping
                    if j > 1
                        error = error + overllappingError(tmpPatch((1:overlappingH) , : , :), qim(initPoitH:(initPoitH + overlappingH - 1), (initPoitW:(initPoitW + pW - 1)), :));
                    end
                    
                    if min == 0
                        min = error;
                        minH = h;
                        minW = w;
                    else
                        if min > error
                            min = error;
                            minH = h;
                            minW = w;
                        end
                    end
                end
            end
            
            patch = im((minH:(minH+pH - 1)), (minW:(minW+pW-1)), :);
            
            % find the minimum cut
            
            
        end
        qim(initPoitH:(initPoitH + pH - 1), initPoitW:(initPoitW + pW - 1), :) = patch;
    end
end
end

