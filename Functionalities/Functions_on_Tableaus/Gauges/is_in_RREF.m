function bool=is_in_RREF(Tab,n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 25, 2024
%--------------------------------------------------------------------------
%
%Function to check if we the Tableau is in RREF gauge.
%
%Input: Tab: The stabilizer tablea (n x 2n+1) array
%Output:  n: # of qubits


[stabs] = Tab_To_String(Tab);

occur  = zeros(1,n);
pauli  = cell(1,n);
qubits = [];

for l=1:n
    
   [cond_prod,~]=qubit_in_product(Tab,n,l);
   
   if ~cond_prod
      qubits=[qubits,l];
   end
   
end


for ll=1:n
   
    this_stab = stabs{ll}(2:end);
    
    for l=1:length(qubits)
        
        qubit=qubits(l);
       
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