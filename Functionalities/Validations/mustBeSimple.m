function mustBeSimple(A)


if any(diag(A))
    
     ME=MException('mustBeSimple:inputError','Detected self loop in adjacency matrix.');
    
     throw(ME)
    
end



end