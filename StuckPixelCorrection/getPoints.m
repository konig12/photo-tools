function [ pts ] = getPoints( I )
%GETPOINTS Get the points to remove from a large image
%    The resulting format is a 2xn matrix of pixel coordinates

[r, c, ~] = size(I);
max_rows = 800;
max_cols = 1300;

rStart = 1;
rEnd = min([r,max_rows]);
cStart = 1;
cEnd = min([c,max_cols]);

allrows = [];
allcols = [];

while true
    % show this patch
    imshow(I(rStart:rEnd,cStart:cEnd));
    [col, row] = getpts;
    %display('col, row');
    %[cStart, rStart]
    
    % convert the points and append to the output lists
    allcols = [allcols; col+cStart+1];
    allrows = [allrows; row+rStart+1];
    
    % check if it is time to quit
    if rEnd == r && cEnd == c
        break;
    end
    
    % Calculate next patch locations
    if cEnd < c
        cEnd = min([c, cEnd+max_cols]);
        cStart = cStart+max_cols;
    else
        cEnd = min([c,max_cols]);
        cStart = 1;
        rEnd = min([r, rEnd+max_rows]);
        rStart = rStart+max_rows;
    end
end

pts = [allrows';allcols'];
end

