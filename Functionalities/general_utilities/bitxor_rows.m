function  M=bitxor_rows(Matrix,row_replace,row_fixed)
%Function to output the updated matrix after adding 2 rows.
%The row_replace is updated in the input matrix.
%Input: Matrix: The matrix to do the row operation
%       row_replace: the row that is replaced
%       row_fixed: the row that is added to the row that is replaced.
%Output: The updated matrix.


M                = Matrix;
M(row_replace,:) = bitxor(M(row_replace,:),M(row_fixed,:));
%M(row_replace,:) = bitxor(Matrix(row_replace,:),Matrix(row_fixed,:));


end