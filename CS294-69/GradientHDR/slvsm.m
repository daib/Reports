function [ u ] = slvsm( rhs )
% solve the courest level
h = 0.5;
u = zeros(3);
u(2,2) = - h * h * rhs(2,2)/4;
end

