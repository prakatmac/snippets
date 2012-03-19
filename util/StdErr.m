function [out] = StdErr(X)
    out = std(X)/sqrt(numel(X));
end