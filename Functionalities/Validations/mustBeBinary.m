function mustBeBinary(A)


if ~isbinary(A)
    
     ME=MException('mustBeBinary:inputError','Input must be binary.');
    
     throw(ME)
    
end



end