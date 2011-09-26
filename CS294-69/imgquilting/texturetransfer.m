function [img] = texturetransfer( sourceName, targetName, N, patchW, patchH, patchReductionFactor, overlapFraction, err )

source = im2single(imread(sourceName));

[sourceH, sourceW, sourceB] = size(source);

target = im2single(imread(targetName));

[targetH, targetW, targetB] = size(target);

img = zeros(size(target));

for iteration = 1:N
    alpha = 0.8 * (iteration-1)/(N-1) + 0.1;
    overlappingW = floor(overlapFraction * patchW);
    overlappingH = floor(overlapFraction * patchH);
    
    %tiling the target image
    for j = 1:ceil((targetH - overlappingH)/(patchH - overlappingH))
        for i = 1:ceil((targetW - overlappingW)/(patchW - overlappingW))
            initPoitW = (i - 1) * (patchW - overlappingW) + 1;
            initPoitH = (j - 1) * (patchH - overlappingH) + 1;
            
            %assert(initPoitH + overlappingH - 1 < targetH);
            %assert(initPoitW + overlappingW - 1 < targetW);


            
            % search for a suitable patch that is close to the patch of the target
            % and the already tiled image

            errors = zeros(sourceW - patchW, sourceH - patchH);
            % iterate through the source image
            % to find the most suitable match
            for w = 1:(sourceW - patchW)
                for h = 1:(sourceH - patchH)
                    tmpPatch = source((h:(h+patchH-1)), (w:(w+patchW-1)), :);
                    
                    % error against the tiling image
                    
                    if iteration == 1
                        errorTiling = 0;
                        % first iteration only
                        % compute overlapping errors because the image is
                        % not there yet
                        
                        % left overlapping
                        if i > 1
                            recW = min(overlappingW, targetW - initPoitW + 1);
                            recH = min(patchH, targetH - initPoitH + 1);
                            errorTiling = overllappingError(tmpPatch(1:recH , (1:recW), :), img(initPoitH:(initPoitH + recH - 1), initPoitW:(initPoitW + recW - 1), :));
                        end

                        %above overlapping
                        if j > 1    
                            recW = min(patchW, targetW - initPoitW + 1);
                            recH = min(overlappingH, targetH - initPoitH + 1);
                            
                            errorTiling = errorTiling + overllappingError(tmpPatch((1:recH) , 1:recW , :), img(initPoitH:(initPoitH + recH - 1), initPoitW:(initPoitW + recW - 1), :));
                        end
                    else
                        % next iterations, the image is aready there
                        %errorTiling = overlappingError(tmpPatch, img(initPoitH:(initPoitH + patchH - 1), initPoitW:(initPoitW + patchW - 1), :));
                        recW = min(patchW, targetW - initPoitW + 1);
                        recH = min(patchH, targetH - initPoitH + 1);
                        e = (tmpPatch(1:recH, 1:recW, :) - img(initPoitH:(initPoitH + recH - 1), initPoitW:(initPoitW + recW - 1), :)).^2;
    
                        for k = 1:ndims(e)
                            errorTiling = sum(e);
                            clear e;
                            e = errorTiling;
                        end
                    end
                    
                    % error against the target image
                    %tmpTarget = target(initPoitH:(initPoitH + patchH - 1), initPoitW:(initPoitW + patchW - 1), :);
                    %errorTarget = overlappingError(tmpPatch, tmpPatch);   
                    recW = min(patchW, targetW - initPoitW + 1);
                    recH = min(patchH, targetH - initPoitH + 1);
                    e = (tmpPatch(1:recH, 1:recW,:) - target(initPoitH:(initPoitH + recH - 1), initPoitW:(initPoitW + recW - 1), :)).^2;
    
                    for k = 1:ndims(e)
                        errorTarget = sum(e);
                        clear e;
                        e = errorTarget;
                    end

                    errors(w,h) = alpha *  errorTiling + (1-alpha) * errorTarget;
                end
            end

            best = min(errors(:));
            candidates = find(errors(:) <= (1+err)*best);

            idx = candidates(ceil(rand(1)*length(candidates)));

            [minW, minH] = ind2sub(size(errors), idx);

            patch = source((minH:(minH+patchH - 1)), (minW:(minW+patchW-1)), :);

            % find the minimum cut

            if overlappingH > 2
                if j > 1
                    
                    recW = min(patchW, targetW - initPoitW + 1);
                    recH = min(overlappingH, targetH - initPoitH + 1);
                            
                    % horizontal cut
                    hCurve = mincut(patch((1:recH) , 1:recW , :), img(initPoitH:(initPoitH + recH - 1), (initPoitW:(initPoitW + recW - 1)), :), true);

                    % copy the image
                    for w = 1:recW
                        patch(1:hCurve(w), w, :) = img(initPoitH:(initPoitH + hCurve(w) - 1), (initPoitW + w - 1), :);
                    end
                end
            end

            if overlappingW > 2
                if i > 1
                    recW = min(overlappingW, targetW - initPoitW + 1);
                    recH = min(patchH, targetH - initPoitH + 1);
                    
                    % vertical cut
                    vCurve = mincut(patch(1:recH , (1:recW), :), img(initPoitH:(initPoitH + recH - 1), (initPoitW:(initPoitW + recW - 1)), :), false);

                    % copy the image
                    for h = 1:recH
                        patch(h, 1:vCurve(h), :) = img((initPoitH + h - 1), initPoitW:(initPoitW + vCurve(h) - 1), :);
                    end
                end
            end

            recW = min(patchW, targetW - initPoitW + 1);
            recH = min(patchH, targetH - initPoitH + 1);
            
            img(initPoitH:(initPoitH + recH - 1), initPoitW:(initPoitW + recW - 1), :) = patch(1:recH, 1:recW,:);
        end
    end
    
    patchW = floor(patchW * patchReductionFactor);
    patchH = floor(patchH * patchReductionFactor);
    
    imwrite(img, sprintf('tt_%s_%s_%d.png', sourceName, targetName, iteration), 'png');
end

end

