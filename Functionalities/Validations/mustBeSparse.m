function mustBeSparse(A)

if ~issparse(A)
   
    ME=MException('mustBeSparse:inputError','Input must be sparse.');
    
    throw(ME)
    
end



end