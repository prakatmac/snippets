function [ output ] = Reject( a, fn )
    if(iscell(a))
        idx = cellfun(fn, a);
    else
        idx = arrayfun(fn, a);
    end
    output = a(find(~idx));
end

