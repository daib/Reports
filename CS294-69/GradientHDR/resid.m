function r = resid( f, u, h )
%
% function r = resid( f, u, h )
%
% Computes the residual for the Poisson problem
%
% Input
%   f      right-hand side
%   u      current approximate solution
%   h      mesh spacing
%
% Returns
%   r      residual
%
% Author
%   Scott R. Fulton (03/15/99)
%
[nx,ny] = size( f );
r = zeros(nx,ny);
h2 = h*h;
for j=2:ny-1
  for i=2:nx-1
    r(i,j) = f(i,j) - (u(i-1,j)+u(i+1,j)+u(i,j-1)+u(i,j+1)-4*u(i,j))/h2;
  end
end
