function put_circuit_backward_order(Circ)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 4, 2024
%--------------------------------------------------------------------------
%
%Script to convert the forward photonic generation circuit to backward
%order.
%
%Input: Circ: A struct with field Gate and subfields name and qubit.
%             The .Gate.name is a cell of the Gate operations as char
%             The .Gate.qubit is a cell with the qubit indices on which the
%             gates act. Circ is in forward order
%Output: Circ: Circuit in backward order

Gates  = Circ.Gate.name;
Qubits = Circ.Gate.qubit;
    
for k=1:length(Gates)

    if strcmpi(Gates{k},'Pdag')

        Gates{k}='P';

    end

end

%Find the location of TRM and add an 'H' gate afterwards

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


Gates  = flip(Gates);
Qubits = flip(Qubits);

Circ.Gate.name  = Gates;
Circ.Gate.qubit = Qubits;

end