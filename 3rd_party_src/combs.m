% ---------------------------------------------------------------------------- %
% Generate all possible combinations of the elements of a given vector.        %
% ---------------------------------------------------------------------------- %
% table = combs(v, k) returns a matrix containing all possible combinations of %
% the elements of vector v selected k times (includes repetitions). Matrix     %
% table has k columns and n^k rows, where n is the number of elements of       %
% vector v.                                                                    %
% ---------------------------------------------------------------------------- %
% By Carlos Souto - csouto@fe.up.pt                                            %
% ---------------------------------------------------------------------------- %
%Carlos Souto (2024). combs: Generate all possible combinations of vector elements (https://www.mathworks.com/matlabcentral/fileexchange/99684-combs-generate-all-possible-combinations-of-vector-elements), MATLAB Central File Exchange. Retrieved July 6, 2024.
function table = combs(v, k)
    nvals = numel(v);
    rows = nvals^k;
    table = zeros(rows, k);
    for col = 1:1:k
        vid = 1;
        step = nvals^(k - col);
        for rowstart = 1:step:rows
            for row = rowstart:1:(rowstart + step - 1)
                table(row, col) = v(vid);
            end
            if vid < nvals
                vid = vid + 1;
            else
                vid = 1;
            end
        end
    end
end
