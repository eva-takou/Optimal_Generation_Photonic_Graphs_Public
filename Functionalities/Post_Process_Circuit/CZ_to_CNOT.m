function [Gates,Qubits]=CZ_to_CNOT(Gates,Qubits,pos,target)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 29, 2024
%
%Convert the CZ gate to a CNOT.
%Input: Gates: A cell array with the names of the gates as char type
%       Qubits: A cell array with the indices of the qubits on which the
%       gates act
%       pos: The position where the CZ is currently.
%       target: The qubit you want to make it be the target.
%Output: Gates: An updated cell array where we converted the CZ to a CNOT
%        Qubits: An updated celll array of the qubits.

Gates  = [Gates(1:pos-1),'H','CNOT','H',Gates(pos+1:end)];
Qubits = [Qubits(1:pos-1),target,Qubits{pos},target,Qubits(pos+1:end)];


end