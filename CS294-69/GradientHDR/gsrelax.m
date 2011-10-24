function u = gsrelax( f, u, h )
% GSRELAX  Does one sweep of Gauss-Seidel relaxation for the Poisson problem
%
% Usage:  u = gsrelax( f, u, h )
%
% Input
%    f    right-hand side
%    u    current approximation
%    h    mesh spacing
%
% Returns
%    u    updated

% Author:   Scott R. Fulton
%
% Revision history:
% 03/15/99:  original version
% 04/15/03:  cleaned up the code for use in MA571

[nx,ny] = size( f );
h2 = h*h;
r2 = 0;
jsw = 1;
for ipass=1:2
    isw = jsw;
    for j=2:ny-1
      for i=(isw+1):2:nx-1
        u(i,j) = (u(i-1,j) + u(i+1,j) + u(i,j-1) + u(i,j+1) - h2*f(i,j))/4;
      end
      isw = 3 - isw;
    end
    jsw = 3 - jsw;
end

end
