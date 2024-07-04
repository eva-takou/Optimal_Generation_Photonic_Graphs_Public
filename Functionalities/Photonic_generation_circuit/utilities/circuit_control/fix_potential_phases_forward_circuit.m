function Circuit=fix_potential_phases_forward_circuit(Circuit,Adj0,ne,CircuitOrder)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 4, 2024
%--------------------------------------------------------------------------
%
%Script to fix potential (-) phases of stabilizers to (+). In the backwards
%generation we do not keep track of |+> or |-> state of emitter when we
%apply the time-reversed measurement. For this reason, some phases might
%not be +. We can resolve this by applying Z gates on the photons for whose
%the stabilizer had the (-) phase.
%
%
%Input: Circuit: A struct with field Gate and subfields name and qubit.
%             The .Gate.name is a cell of the Gate operations as char
%             The .Gate.qubit is a cell with the qubit indices on which the
%             gates act. 
%      Adj0: The adjacency matrix of the photonic target state
%      ne: # of emitters
%      CircuitOrder: 'forward' or 'backward' to indicate the order of the
%      circuit we provide
%Output: Circ: Updated Circuit in same order as the input one, which
%              potentially has some extra 'Z' gates.

if strcmpi(CircuitOrder,'backward')
    
    Circuit=put_circuit_forward_order(Circuit);
    
end

[encountered_warning,Tab] = Verify_Circuit_Forward_Order(Circuit,Adj0,ne,CircuitOrder);

np = length(Adj0);

if encountered_warning
    
    for photon=1:np
       
        if Tab(photon,end)==1 %Can correct the phase via a Z operation on the photon
            
            Tab = Pauli_Gate(Tab,photon,n,'Z');
            Circuit = store_gate_oper(photon,'Z',Circuit,true);
            
        end
        
    end
    
end

if strcmpi(CircuitOrder,'backward')
    
    Circuit = put_circuit_backward_order(Circuit);
    
end

end