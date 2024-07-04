function [Gates,Qubits,flag_success]=remove_initial_Hadamards(Gates,Qubits,circuit_order)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 28, 2024
%
%Function to remove initial Hadamards from the beginning of the circuit. 
%The circuit should be provided in forward order. We remove initial H gates
%if we want to plot instead of |0> the |+> state in draw circuit. If not
%all qubits are acted by an initial H gate, then this script throws an
%error.
%
%Input: Gates: A cell array with the names of the gates
%       Qubits: A cell array with the indices of the qubits
%       circuit_order: 'forward' of 'backward'
%
%Output: Updated Gates and Qubits in forward order.

n        = max([Qubits{:}]);
all_in_H = false(1,n); %Assume none of the qubits are acted by initial H gate

switch circuit_order
    
    case 'backward'
   
        Circ.Gate.name  = Gates;
        Circ.Gate.qubit = Qubits;
        
        Circ=put_circuit_backward_order(Circ);
        
        Gates  = Circ.Gate.name;
        Qubits = Circ.Gate.qubit;
        
        
end

locs_Q = zeros(1,n); %Just initialization

for jj=1:n
    
    for kk=1:length(Gates)

       if any(Qubits{kk}==jj)
           
           if strcmpi(Gates{kk},'H')

               locs_Q(jj)   = kk; %Store location where H is
               all_in_H(jj) = true;
               break %Break upon first encounter
               
           end

       end

    end    
    
end


if ~all(all_in_H)
    
    flag_success = false;
    warning('Not all qubits are initially acted by Hadamard gate. Consider simplifying the circuit first.')
    
end

%Remove the initial Hadamards:

Gates(locs_Q)  = [];
Qubits(locs_Q) = [];

flag_success = true;
end