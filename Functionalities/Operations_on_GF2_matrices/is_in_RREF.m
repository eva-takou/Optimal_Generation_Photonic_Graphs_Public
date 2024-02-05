function bool=is_in_RREF(Tab,n)


[stabs]=Tab_To_String(Tab);
occur=zeros(1,n);

cnt=zeros(1,n);
pauli=cell(1,n);
for ll=1:n
   
    this_stab = stabs{ll}(2:end);
    
    
    for qubit=1:n
       
        if this_stab(qubit)~='I' 
            
            pauli{qubit} = [pauli{qubit},{this_stab(qubit)}];
            occur(qubit) = occur(qubit)+1;
            
            break

            
        end
        
    end
    
end

if any(occur>2)
    bool=false;
    return
end

for i=1:n
    
    these_Paulis = pauli{i};
    
    if ~isempty(these_Paulis) && length(these_Paulis)>1
       
        if these_Paulis{1}==these_Paulis{2}
            
            bool=false;
            return
        end
        
    end
    
    
end
bool=true;





end