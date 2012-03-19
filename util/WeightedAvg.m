function [ Avg ] = WeightedAvg( Var, Weights )
    Avg = sum(Var(:) .* Weights(:)) / sum(Weights(:));
end

