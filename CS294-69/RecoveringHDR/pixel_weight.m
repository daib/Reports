function [ w ] = pixel_weight(z, z_min, z_max)
for i = 1:length(z)
    if z(i) <= (z_min + z_max)/2
        w(i) = z(i) - z_min;
    else
        w(i) = z_max - z(i);
    end
end
end

