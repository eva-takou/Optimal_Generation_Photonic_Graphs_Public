function [Gates,Qubits]=CNOT_to_CZ(Gates,Qubits,pos)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 29, 2024
%
%Convert the CNOT gate to a CZ.
%Input: Gates: A cell array with the names of the gates as char type
%       Qubits: A cell array with the indices of the qubits on which the
%       gates act
%       pos: The position where the CNOT is currently.
%Output: Gates: An updated cell array where we converted the CNOT to a CZ
%        Qubits: An updated celll array of the qubits.

Gates  = [Gates(1:pos-1),'H','CZ','H',Gates(pos+1:end)];
Qubits = [Qubits(1:pos-1),Qubits{pos}(2),Qubits{pos},Qubits{pos}(2),Qubits(pos+1:end)];


end