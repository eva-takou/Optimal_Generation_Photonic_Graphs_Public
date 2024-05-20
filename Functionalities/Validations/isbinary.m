function flag=isbinary(A)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%
%Test if the input matrix is binary.
%Input:  A: Matrix
%Output: flag: true or false

flag = all( all(A==0 | A==1) );

end