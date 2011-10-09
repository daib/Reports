function [ rgb ] = recoverHDR(img_list_file, folder)

[names, f, fstops, gains, nd_filters] = textread(sprintf('%s/%s',folder, img_list_file),'%s %f %d %d %d', 'headerlines', 3);

for j = 1:length(names)
    full_path_name = sprintf('%s/%s', folder, char(names(j)));
    img(:,:,:,j) = im2single(imread(full_path_name));
end

t = 1/f;

B = log(t);

for c = 1:3 %for each color
    for j = 1:length(B) %for each speed
        x = img(:,:,c,j );
        Z(:, j, c) = x(:);
    end
end

%weighting function for each pixel
z = Z(:, :, c);
z_min = 0; %min(z(:));
z_max = 255; %max(z(:));

%z_vals = ndgrid(z_min:z_max, z_min, z_max);

w = pixel_weight(ndgrid(z_min:z_max, 1), z_min, z_max);

for c = 1:3 %for each color 
    g(c) = gsolve(z, B, 10, w);
    plot(g(c));
end


end

