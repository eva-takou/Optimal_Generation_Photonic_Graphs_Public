function Circuit = store_gate_oper(qubit,operation,Circuit,Store_Gates)
%Function to store the gates of the circuit generation in a list.
%Input: qubit: the qubit(s) onto which the operation is acted
%       operation: an char of the operation e.g. 'CNOT','H','P' etc
%       Circuit: the remaining circuit so far (could be empty)
%       Store_Gates: true or false to actually store the update.
%                    if false, we do not make any update.
%Output: the updated circuit

if ~Store_Gates
    
    if isempty(Circuit)
        
        Circuit.EmCNOTs       = 0;
        
    end
    
else
    
    if isempty(Circuit)
        
        Circuit.Gate.qubit{1} = qubit;
        Circuit.Gate.name{1}  = operation;
        Circuit.EmCNOTs       = 0;
        
    else
        
        Circuit.Gate.qubit{end+1}=qubit;
        Circuit.Gate.name{end+1}=operation;
        
    end
    
end

    
end