function fixImage( image , pts)
%FIXIMAGE Summary of this function goes here
%   Detailed explanation goes here

data = double(imread(image))/256;

I_out = removeStuckPixels(data,pts);

[path, name, ~] = fileparts(image);
imwrite(I_out,fullfile(path,[name '_corrected.tiff']));

end

