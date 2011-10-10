function [ rgb ] = recoverHDR(img_list_file, folder, scale, smooth)

[names, f, fstops, gains, nd_filters] = textread(sprintf('%s/%s',folder, img_list_file),'%s %f %d %d %d', 'headerlines', 3);

for j = 1:length(names)
    full_path_name = sprintf('%s/%s', folder, char(names(j)));
    original_img(:,:,:,j) = imread(full_path_name);
    img(:,:,:,j) = imresize(original_img(:,:,:,j), scale);
end

t = 1 ./f;

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
    [g(:, c), lE(:, c)] = gsolve(z, B, smooth, w);
    % plot(g(:, c));
end

%combine images

pixel_weights = w(original_img+1);
gs = g(original_img+1);
for j = 1:length(names)
    log_E(:,:,:,j) = gs(:,:,:,j) - B(j);
end

weighted_log_E = sum(pixel_weights .* log_E, 4);

% for c = 1:3
%     color = pixel_weights(:,:,c,:);
%     sum_weights = sum(color(:));
%     normalized_log_E(:,:,c) = weighted_log_E(:,:,c) ./ sum_weights;
% end
sum_weights(:,:,:) = sum(pixel_weights, 4);

normalized_log_E = weighted_log_E ./ sum_weights;

hdrwrite(exp(normalized_log_E), sprintf('%s/output.hdr', folder));



end

