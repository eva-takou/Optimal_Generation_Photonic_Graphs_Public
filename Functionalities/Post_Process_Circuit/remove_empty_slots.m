function [Gates,Qubits]=remove_empty_slots(Gates,Qubits)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 28, 2024
%
%Function to remove the empty positions due to re-arrangement of gates.
%Input: Gates: A cell array with the Clifford gate names e.g. 'CNOT','X','Z' etc
%       Qubits: A cell array of qubits, ordered as Gates, on which we apply
%       the gates.
%Output: The Gates and Qubits cell after removing empty entries.

to_remove=[];

for kk=1:length(Gates)

    if isempty(Gates{kk})

       to_remove=[to_remove,kk];

    end

end

Gates(to_remove)  = [];
Qubits(to_remove) = [];         


end