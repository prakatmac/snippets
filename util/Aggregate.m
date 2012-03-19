function [A] = Aggregate(Ordinate, Abscissa, Bins, AggregationFunction)
    A = [];
    for i = 1:numel(Bins)-1
        Samples = Ordinate(Abscissa > Bins(i) & Abscissa <= Bins(i+1));
        A = vertcat(A, horzcat((Bins(i+1) + Bins(i))/2, AggregationFunction(Samples), numel(Samples)));
    end
end