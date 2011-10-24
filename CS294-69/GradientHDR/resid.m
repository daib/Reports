function r = resid( u , f , n )
%
% function r = resid( f, u, n )
%
% Computes the residual for the Poisson problem
%
% Input
%   f      right-hand side
%   u      current approximate solution
%
% Returns
%   r      residual
%
% Author
%   Scott R. Fulton (03/15/99)
%
%[nx,ny] = size( f );
r = zeros(size(u));
h = 1/(n-1);
h2 = h*h;
for j=2:n-1
  for i=2:n-1
    r(i,j) = f(i,j) - (u(i-1,j)+u(i+1,j)+u(i,j-1)+u(i,j+1)-4*u(i,j))/h2;
  end
end
