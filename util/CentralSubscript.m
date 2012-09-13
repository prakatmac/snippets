function [ out ] = CentralSubscript( Dims )
%CentralSubscript: calculate the central element's subscript for a matrix
%                  with dimension Dims.
    if(sum( mod(Dims, 2) ~= 1))
        warning('Utils:AmbiguousResult', ...
            'Even-length dimensions present. Center is not well defined');
    end
    out = ceil(Dims / 2);
end

