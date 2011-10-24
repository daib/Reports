function [ u ] = slvsm( rhs )
h = 0.5;
u = - h * h * rhs/4;
end

