function [ points ] = autoGetPoints(darkFrame)
%autoGetPoints Get the bad pixel coordinates from a provided dark frame
%   Output is a 2xn matrix of pixel coordinates. Coordinates are given in
%   [row; column] format

% There must be 3 dimensions: color images
assert(length(size(darkFrame)) == 3);
assert(isa(darkFrame, 'uint8'));

% We use a simple heuristic:
% Pixels over 1/2 exposed are stuck
stuckMask = darkFrame > 128;

% check for excessive hot pixels
assert(nnz(stuckMask) < 500);

% Get the locations in each channel and or them together
[rows, cols] = find( ...
    stuckMask(:,:,1) | ...
    stuckMask(:,:,2) | ...
    stuckMask(:,:,3));

points = [rows'; cols'];

end

