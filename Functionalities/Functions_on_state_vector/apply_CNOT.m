function psi = apply_CNOT(control,target,n,psi)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 4, 2024
%--------------------------------------------------------------------------
%
%Function to apply a CNOT gate between 2 qubits of an N-dimensional quantum
%state.
%Inputs: control: index of control qubit 
%        target: index of target qubit
%        n: total # of qubits
%        psi: input state vector
%Output: psi: the updated state vector

if control>n || target>n
   
    error('Qubit index exceeds the number of available qubits in the state.')
    
end

psi = CNOT(control,target,n)*psi;

end