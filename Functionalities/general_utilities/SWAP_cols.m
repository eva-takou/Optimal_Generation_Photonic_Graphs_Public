function M=SWAP_cols(M,j1,j2)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Swap two columns of a matrix M.
%Input: M: matrix
%       j1: index of first column
%       j2: index of second column
%Output: The updated matrix M

M(:,[j1,j2])=M(:,[j2,j1]);

end