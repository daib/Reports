function mat = gauss2d(mat, sigma, center)
gsize = size(mat);
[R,C] = ndgrid(1:gsize(1), 1:gsize(2));
mat = gaussC(R,C, sigma, center);
%for r=1:gsize(1)
%    for c=1:gsize(2)
%        mat(r,c) = gaussC(r,c, sigma, center);
%    end
%end