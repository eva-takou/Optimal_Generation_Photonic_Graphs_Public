function mustBeValidOrdering(ordering,n)


if length(unique(ordering))~=length(ordering)
    
     ME=MException('mustBeValidOrdering:inputError','Detected duplicate labels for the qubits.');
    
     throw(ME)
    
end

if length(ordering)~=n
    
    ME=MException('mustBeValidOrdering:inputError','The size of the ordering elements does not match the number of qubits.');
    
    throw(ME)
    
end


end