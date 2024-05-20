function Tab=Clifford_Gate(Tab,qubit,Oper,n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%
%Function to apply Clifford gates on a stabilizer Tableau.
%Input:  Tab: The stabilizer tableau (n x 2n+1 array).
%        qubit: indices of qubit(s) as ordered in the Tableau. 
%               For a 2-qubit gate, qubit is a two-element vector with
%               the first qubit being the control.
%        Oper:  char of the name of the operation 
%               ('H', 'P', 'X', 'Y', 'Z', 'CNOT', 'CZ', etc)
%Output: The updated Tableau.


switch Oper
    
    case 'H'
   
        Tab = Had_Gate(Tab,qubit,n);
        
    case 'P'
        
        Tab = Phase_Gate(Tab,qubit,n);
        
    case 'X'
        
        Tab = Pauli_Gate(Tab,qubit,n,'X');
        
    case 'Y'
        
        Tab = Pauli_Gate(Tab,qubit,n,'Y');
        
    case 'Z'
        
        Tab = Pauli_Gate(Tab,qubit,n,'Z');
        
    case 'CNOT'
        
        if qubit(1)==qubit(2)
            
            error('Attempted to do CNOT_{ii}.')
            
        end
        
        Tab = CNOT_Gate(Tab,qubit,n); %1st qubit in qubit array is control, 
        
    case 'CZ' 
        
        if qubit(1)==qubit(2)
            
            error('Attempted to do CZ_{ii}.')
            
        end
        
        Tab = Had_Gate(Tab,qubit(2),n); %(1\otimes H)CNOT(1\otimes H)=CZ
        Tab = CNOT_Gate(Tab,qubit,n);
        Tab = Had_Gate(Tab,qubit(2),n);
        
    case 'SWAP'
        
        
        Tab(:,qubit)   = Tab(:,flip(qubit));
        Tab(:,qubit+n) = Tab(:,flip(qubit)+n);
        
    case 'HP'
        
        Tab = Had_Gate(Tab,qubit,n);
        Tab = Phase_Gate(Tab,qubit,n);
        
    case 'PH'

        Tab = Phase_Gate(Tab,qubit,n);        
        Tab = Had_Gate(Tab,qubit,n);
        
    case 'HPH'
        
        Tab = Had_Gate(Tab,qubit,n);
        Tab = Phase_Gate(Tab,qubit,n);
        Tab = Had_Gate(Tab,qubit,n);
        
    case 'PHP'

        Tab = Phase_Gate(Tab,qubit,n);        
        Tab = Had_Gate(Tab,qubit,n);
        Tab = Phase_Gate(Tab,qubit,n);  
        
end
    
end