function [ error ] = overllappingError( im1, im2 )
    e = abs(im1 - im2);
    
    for i = 1:ndims(e)
        error = sum(e);
        clear e;
        e = error;
    end
end

