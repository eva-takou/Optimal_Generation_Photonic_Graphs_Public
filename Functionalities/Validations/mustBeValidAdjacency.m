function mustBeValidAdjacency(A)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 20, 2024
%
%Throw an error if the adjacency matrix is not valid
%Input: A: The adjacency matrix

mustBeSimple(A)

if ~issymmetric(single(A))

    ME = MException('mustBeValidAdjacency:inputError','Detected non-symmetric Adjacency matrix.');
    throw(ME)

end

if size(A,1)~=size(A,2)
    
    ME = MException('mustBeValidAdjacency:inputError','Adjacency matrix is not square.');
    throw(ME)
    
end

end