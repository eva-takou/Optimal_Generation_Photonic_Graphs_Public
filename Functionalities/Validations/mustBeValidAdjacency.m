function mustBeValidAdjacency(A)

mustBeSimple(A)


if ~issymmetric(single(A))

ME=MException('mustBeValidAdjacency:inputError','Detected non-symmetric Adjacency matrix.');
    
throw(ME)

end


if size(A,1)~=size(A,2)
    
ME=MException('mustBeValidAdjacency:inputError','Adjacency matrix is not square.');
    
throw(ME)
    
end

end