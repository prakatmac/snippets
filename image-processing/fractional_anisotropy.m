% Fractional anisotropy as described in the paper referenced below.  Input 
% is a cell array containing the precomputed diffusion tensor components in
% the form:
%
% TensorComponents = {IXX IYY IZZ IXY IXZ IYZ}
%
% Output is a scalar N-D volume with values in the range [0,1] and
% dimensions set by the size(IXX).  All elements of the TensorComponents
% input are expected to have the same dimensions.
%
% Reference:
%     Basser, PJ & Pierpaoli, C. (1996). "Microstructural and physiological
%     features of tissues elucidated by quatitative-diffusion-tensor MRI."
%     Journal of Magnetic Resonance, Series B. 111, 209-219
%
function FA = fractional_anisotropy(TensorComponents)
    FA = zeros(size(TensorComponents{1}));
    disp(sprintf('%3u%% Complete', 0));
    tic;
    for i = 1:numel(FA)
        if(toc > 5)
           disp([char(8)*ones(1,14) sprintf('%3u%% Complete', uint8(100*i/numel(FA)))]);
           tic;
        end
        % populate inertia tensor
        INERTIA = [TensorComponents{1}(i) TensorComponents{4}(i) TensorComponents{5}(i); ...
            TensorComponents{4}(i) TensorComponents{2}(i) TensorComponents{6}(i); ...
            TensorComponents{5}(i) TensorComponents{6}(i) TensorComponents{3}(i)];
        % diagonalize it
        VALUES = eig(INERTIA);
        FA(i) = frac_aniso(VALUES);
    end
end

function FA = frac_aniso(Eigenvalues)
    E = mean(Eigenvalues(:));
    FA = sqrt(3/2)*norm(Eigenvalues - E)/norm(Eigenvalues);
end
