function  Matrix=SWAP_rows(Matrix,row1,row2)
%Function to swap rows in a matrix.
%Input: The matrix, and the rows
%Output: The matrix with swapped rows.

temp = Matrix(row1,:);
Matrix(row1,:)=Matrix(row2,:);
Matrix(row2,:)=temp;

end