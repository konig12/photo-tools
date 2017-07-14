function I_out = removeStuckPixels(I, locations)
% This function removes a set of pixels which are known to be misbehaving,
% interpolating new values for them from their neighbors. The locations are
% bled out to also get rid of JPEG compression smearing of the pixel
% values.
%
% Inputs:
% I        : an image
% locations: a 2xn matrix where each column is an row,column coordinate
%            pair for a bad pixel.

%% compute some parameters
[nrows, ncols, colors] = size(I);
bleed_radius = 5;

%% Create the mask
mask = false(nrows, ncols);

% Compute pixel indices to be erased
targetRow = uint32(round(locations(1,:)));
targetCol = uint32(round(locations(2,:)));
indexes = targetRow + (targetCol-1)*nrows;

% mark the target coordinates and dilate
mask(indexes) = true;
mask = imdilate(mask, strel('diamond',bleed_radius));

%% do the filling

I_out = zeros(nrows, ncols, colors);
for color=1:colors
   I_out(:,:,color) = regionfill(I(:,:,color), mask);
end
end