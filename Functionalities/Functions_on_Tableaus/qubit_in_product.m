function [cond_product, state_flag]= qubit_in_product(Tab,n,qubit)
%Function to check if a qubit from the tableau is in product state.
%Input: Tab: Tableau
%       n: # of qubits
%       qubit: The qubit index to inspect if it is in product state
%Output: cond_product: true or false
%        state_flag: if cond_product is true, it outputs the state of the
%        qubit.

StabsX = Tab(:,qubit);     

if sum(StabsX)==0 %Only Zs 
    
    cond_product = true;
    state_flag   = 'Z'; 
    return
    
else
    
    StabsZ = Tab(:,qubit+n);
    
    
    if sum(StabsZ)==0 %Only Xs
    
        cond_product = true;
        state_flag   = 'X'; 
        return
        
    else %Determine whether in Y, or not in product
        
        if any(bitxor(StabsX,StabsZ)) %If =1 anywhere then not in Y. We can also use if sum(bitxor(StabsX,StabsZ))>0
            
            cond_product = false;
            state_flag   = ''; 
           
            return
            
        else
            
            cond_product = true;
            state_flag   = 'Y';
            return
            
        end        
        
    end


end



end

