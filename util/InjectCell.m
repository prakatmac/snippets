function [ set ] = InjectCell(block, list, initial)
    set = initial;
    for i = 1:numel(list)
        set = feval(block, set, list{i});
    end
end

