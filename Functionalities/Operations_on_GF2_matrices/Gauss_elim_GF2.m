function M=Gauss_elim_GF2(M)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 25, 2024
%--------------------------------------------------------------------------
%
%Function to implement gaussian elimination in the field GF2.
%
%Input: M binary matrix m x n
%Output: M binary matrix m x n


[m,n]=size(M);

%Determine the leftmost non-zero column
col_start=1;
row_start=1;
ROW=1;
COL=1;

while ROW<=m && COL<=n

    for col=col_start:n

        temp  = M(row_start:end,col);
        cond1 = temp>0;
        
        if any(cond1)
            
            nnz_rows = find(temp);  %find(M,1)
            row_loc  = nnz_rows(1);
            nnz_rows(1) = [];
            break
            
        end

    end
    
    M = SWAP_rows(M,ROW,row_loc+(row_start-1));
    
    if ~isempty(nnz_rows)

        nnz_rows=nnz_rows+(row_start-1);
        nnz_rows(nnz_rows==ROW)=[];

        for jj=1:length(nnz_rows)
            
            M=bitxor_rows(M,nnz_rows(jj),ROW);

        end

    end

    nnz_full_rows=nnz(M(ROW+1:end,:));

    if nnz_full_rows==0
        break

    end

    ROW=ROW+1;   
    COL=COL+1;
    col_start=col_start+1;
    row_start=row_start+1;

end


end