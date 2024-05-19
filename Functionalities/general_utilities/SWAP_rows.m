function  M=SWAP_rows(M,row1,row2)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Swap two rows of a matrix.
%Input: M: matrix
%       j1: index of first column
%       j2: index of second column
%Output: The updated matrix M

temp = M(row1,:);
M(row1,:)=M(row2,:);
M(row2,:)=temp;

end