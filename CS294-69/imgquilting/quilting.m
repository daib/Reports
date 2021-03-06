function [ qim ] = quilting( imname, pW, pH, sW, sH, overlappingFraction, err )
%quilting : function that synthesizes a texture image from an input

im = im2single(imread(imname));

[iH,iW,iB] = size(im);

overlappingW  = floor(pW * overlappingFraction);
overlappingH = floor(pH * overlappingFraction);


qim = zeros(sH, sW, iB);
patch = zeros(pH, pW, iB);


for j = 1:floor(sH/(pH - overlappingH))
    for i = 1:floor(sW/(pW - overlappingW))
        initPoitW = (i - 1) * (pW - overlappingW) + 1;
        initPoitH = (j - 1) * (pH - overlappingH) + 1;
        
        if i == 1 && j == 1
            %first image, get an arbitrary one
            x = ceil(rand(1)*(iW - pW));
            y = ceil(rand(1)*(iH - pH));
            patch = im(x:(pH + x - 1), y:(pW + y -1), :);
        else
            %search for a suitable block that is close to neighboring patched
            %blocks
           
            errors = zeros(iW - pW, iH - pH);
            % iterate through the input image
            % to find the most suitable match
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
                    
                    errors(w,h) = error;
                end
            end
            
            best = min(errors(:));
            candidates = find(errors(:) <= (1+err)*best);
          
            idx = candidates(ceil(rand(1)*length(candidates)));
                         
            [minW, minH] = ind2sub(size(errors), idx);
            
            patch = im((minH:(minH+pH - 1)), (minW:(minW+pW-1)), :);
            
            % find the minimum cut
            
            if j > 1
                % horizontal cut
                hCurve = mincut(patch((1:overlappingH) , : , :), qim(initPoitH:(initPoitH + overlappingH - 1), (initPoitW:(initPoitW + pW - 1)), :), true);
                
                % copy the image
                for w = 1:pW
                    patch(1:hCurve(w), w, :) = qim(initPoitH:(initPoitH + hCurve(w) - 1), (initPoitW + w - 1), :);
                end
            end
            
            if i > 1
                % vertical cut
                vCurve = mincut(patch(: , (1:overlappingW), :), qim(initPoitH:(initPoitH + pH - 1), (initPoitW:(initPoitW + overlappingW - 1)), :), false);
                
                % copy the image
                for h = 1:pH
                    patch(h, 1:vCurve(h), :) = qim((initPoitH + h - 1), initPoitW:(initPoitW + vCurve(h) - 1), :);
                end
            end
            
        end
        qim(initPoitH:(initPoitH + pH - 1), initPoitW:(initPoitW + pW - 1), :) = patch;
    end
end

imwrite(qim, sprintf('quilting_%s.png', imname), 'png');

end

