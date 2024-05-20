function mustBeSimple(A)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 20, 2024
%
%Throw an error if the adjacency matrix is not simple
%Input: A: adjacency matrix

if any(diag(A))
    
     ME = MException('mustBeSimple:inputError','Detected self loop in adjacency matrix.');
     throw(ME)
    
end


end