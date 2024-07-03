function M=Gauss_elim_GF2_with_rowsum(M,nn)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 3, 2024
%--------------------------------------------------------------------------
%
%Function to implement gaussian elimination in the field GF2, on a Tableau
%matrix. This script is used to find the outcome of determinate single
%qubit measurement.
%
%Input:  Tableau Matrix n x 2nn+1
%Output: Tableau Matrix n x 2nn+1

if size(M,1)~=nn || size(M,2)~=2*nn+1
   
    error('Input matrix does not have the correct dimensions.') 
    
end
    

m = nn;
n = 2*nn+1;

%Determine the leftmost non-zero column
col_start=1;
row_start=1;
ROW=1;
COL=1;

while ROW<=m && COL<=n-1

    for col=col_start:n-1

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
            
            M=rowsum(M,nn,nnz_rows(jj),ROW);

        end

    end

    nnz_full_rows=nnz(M(ROW+1:end,1:2*nn));

    if nnz_full_rows==0
        break

    end

    ROW=ROW+1;   
    COL=COL+1;
    col_start=col_start+1;
    row_start=row_start+1;

end

%Need to do back-substitution too, to remove 1s from rows above

for lower_row=nn:-1:2

    %find where nnz entries of current row are contained in rows above
    
    entries_this_row = find(M(lower_row,1:2*nn));
    
    for upper_row=lower_row-1:-1:1
        
        entries_other_row = find(M(upper_row,1:2*nn));
        
        if all(ismember(entries_this_row,entries_other_row))
        
            M = rowsum(M,nn,upper_row,lower_row);
            
        end
        
    end
    
end

end