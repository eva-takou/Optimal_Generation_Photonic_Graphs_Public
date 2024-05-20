function mustBeSparse(A)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 20, 2024
%
%Throw an error if the input matrix is not sparse
%Input: A: Matrix

if ~issparse(A)
   
    ME=MException('mustBeSparse:inputError','Input must be sparse.');
    
    throw(ME)
    
end



end