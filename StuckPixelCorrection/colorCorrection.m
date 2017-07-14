
%% load the images
images = {'IMG_7354.JPG', ...
'IMG_7360.JPG', ...
'IMG_7366.JPG', ...
'IMG_7406.JPG', ...
'IMG_7407.JPG', ...
'IMG_7408.JPG'};

images_data = cellfun(@(x)imread(x), images,'Uniform',false);
images_data = cellfun(@(x)double(x)/256, images_data, 'Uniform',false);

%% Compute black and white images

image_data_bw = cellfun(@(x)rgb2gray(x), images_data, 'Uniform',false);

% create flat working vectors
[r, c] = size(image_data_bw{1});
flat_images = cell2mat(cellfun(@(x)reshape(x,[r*c, 1]),image_data_bw,'Uniform',false));

%% Compute mean and standard deviation per pixel


% mean
means = reshape(mean(flat_images,2), [r, c]);
stds = reshape(std(flat_images,0,2), [r, c]);

zero_stds = find(stds==0);