function [ I ] = simple_poisson( f )

A = zeros(size(f, 1) * size(f, 1));

grows = size(f, 1);
gcols = size(f, 2);

for j = 1:size(f, 1)
    for l = 1:size(f, 2)
        row = j + (l - 1) * grows;
        if j < grows
            A(row, row + 1) = 1; % u_j+1,l
        end
        
        if j > 1
            A(row, row - 1) = 1; % u_j-1,l
        end
        
        if l < gcols
            A(row, row + grows) = 1; % u_j, l+1
        end
        
        if l > 1
            A(row, row - grows) = 1; % u_j,l-1
        end
        
        A(row,row) = -4;
    end
end


% I = conjgrad(A, f(:));
I = A\f(:);

end

