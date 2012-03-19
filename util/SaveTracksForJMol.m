function [status] = SaveTracksForJMol(tracks, varargin)
    if(numel(varargin) > 0)
        out = fopen(varargin{1}, 'w+');
    else
        % dry run
        out = 1;
    end
    
    for t = min(tracks(:,4)):max(tracks(:,4))
        current = tracks(tracks(:,4) == t, :);
        % print the header
        fprintf(out, '%i\n', size(current, 1));
        fprintf(out, 'TIME %i\n', t);
        % loop through particles and output coordinates
        for i = 1:size(current, 1)
            fprintf(out, 'P%i %f %f %f\n', current(i,5), current(i,1), ...
                current(i,2), current(i,3));
        end
        % extra line
        fprintf(out, '\n');
    end
    
    if(~isequal(out, 1))
        fclose(out);
    end
    
    status = true;
end

