% N-D circular convolution using Fast Fourier Transforms
function output = fdapply(data, filter)
    output = real(ifftn(ifftshift(fftshift(fftn(data)) .* filter)));
end

