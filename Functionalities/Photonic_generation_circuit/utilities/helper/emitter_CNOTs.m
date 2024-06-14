function CNOT_cnt=emitter_CNOTs(Circuit)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 14, 2024
%--------------------------------------------------------------------------
%
%Function to count the number of CNOTs acting on emitter qubits only.
%Inputs: Circuit: The circuit that generates the photonic graph state
%Output: The CNOT count.

CNOT_cnt       = Circuit.EmCNOTs;

end