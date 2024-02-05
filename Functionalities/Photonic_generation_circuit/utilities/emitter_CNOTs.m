function CNOT_cnt=emitter_CNOTs(Circuit)
%Function to count the number of CNOTs acting on emitter qubits only.
%Inputs: Circuit: The circuit that generates the photonic graph state
%        ne: # of emitters
%        np: # of photons
%Output: The CNOT count.


CNOT_cnt       = Circuit.EmCNOTs;


end