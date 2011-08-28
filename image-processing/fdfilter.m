% Construct a 3D Fourier domain bandpass filter based on real space minimum
% and maximum dimensions.
%
% size: a 3 element integer vector representing the final dimensions of the
%       constructed filter.  
% min:  a length in voxels specifying the smallest structures to keep.
% max:  a length in voxels specifying the largest structures to keep.
%
% Ouput is a filter that is ready to be used via fdapply.
function filter = fdfilter(size, min, max)
    filter = false(size);
    [x y z] = ind2sub(size, 1:numel(filter));
    x = x - size(1)/2;
    y = y - size(2)/2;
    z = z - size(3)/2;
    nx = size(1)/2 - 1;
    ny = size(2)/2 - 1;
    nz = size(3)/2 - 1;
    d = (x./nx).^2 + (y./ny).^2 + (z./nz).^2;
    ubound = 1/min;
    lbound = 1/max;    
    filter( (d <= ubound) & (d >= lbound) ) = 1;
end

