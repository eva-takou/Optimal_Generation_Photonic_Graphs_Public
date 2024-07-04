function [Circ]=put_circuit_forward_order(Circ)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 4, 2024
%--------------------------------------------------------------------------
%
%Script to bring the backward circuit obtained by the Tableau to forward
%order.
%
%Input: Circ: A struct with field Gate and subfields name and qubit.
%             The .Gate.name is a cell of the Gate operations as char
%             The .Gate.qubit is a cell with the qubit indices on which the
%             gates act. Circ is in backward order
%Output: Circ: Circuit in forward order


Gates  = Circ.Gate.name;
Qubits = Circ.Gate.qubit;
    
for k=1:length(Gates)

    if strcmpi(Gates{k},'P')

        Gates{k}='Pdag';

    end

end
    
%Need to also add an H gate on the control emitter after the 'Measure'

Gates  = flip(Gates);
Qubits = flip(Qubits);

loc_TRM = [];
    
for k=1:length(Gates)

   if strcmpi(Gates{k},'Measure')

       loc_TRM = [loc_TRM,k];

   end

end

for l = 1:length(loc_TRM)

    Gates   = [Gates(1:loc_TRM(l)),'H',Gates(loc_TRM(l)+1:end)];
    Qubits  = [Qubits(1:loc_TRM(l)),Qubits{loc_TRM(l)}(1),Qubits(loc_TRM(l)+1:end)];
    loc_TRM = loc_TRM+1;

end


n              = max([Qubits{:}]);
[Gates,Qubits] = cancel_out_gates(Gates,Qubits,n);

Circ.Gate.name  = Gates;
Circ.Gate.qubit = Qubits;

warning('Some phases of stabilizers might be (-). For an accurate circuit, call fix_potential_phases_forward_circuit.')

end