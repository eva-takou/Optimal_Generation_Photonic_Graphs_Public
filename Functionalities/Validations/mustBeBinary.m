function mustBeBinary(A)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%
%Throw an error if the input matrix is not binary.
%
%Input: A: Matrix

if ~isbinary(A)
    
     ME = MException('mustBeBinary:inputError','Input must be binary.');
     throw(ME)
    
end

end