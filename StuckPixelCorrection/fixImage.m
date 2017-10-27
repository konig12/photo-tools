function fixImage( image , pts)
%FIXIMAGE Correct the stuck pixels of the specified image.

data = double(imread(image))/256;

I_out = removeStuckPixels(data,pts);

[path, name, ~] = fileparts(image);
imwrite(I_out,fullfile(path,[name '_corrected.tiff']));

end

