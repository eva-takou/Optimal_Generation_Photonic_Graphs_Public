function psi_Out=single_gate(l,n,gate,psi)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 3, 2024
%--------------------------------------------------------------------------
%
%Function to perform a single-qubit gate on one of the qubits of an n-qubit
%state.
%
%Inputs: l: qubit index \in [1,n] on which we act with the gate
%        n: total # of qubits
%       gate: 'X' or 'Y' or 'Z' or 'H' or 'P'
%       psi: the input state (2^n x 1 vector)
%
%Output: psi_Out: the output state

P  = diag([1,1i]);
X  = [0 1; 1 0];
Y  = [0 -1i; 1i 0];
Z  = diag([1,1i]);
H  = [1,1; 1,-1]/sqrt(2);
I2 = eye(2);


if strcmpi(gate,'P')
    act_Gate = P;
elseif strcmpi(gate,'H')
    act_Gate = H;
elseif strcmpi(gate,'Z')
    act_Gate = Z;
elseif strcmpi(gate,'X')
    act_Gate = X;
elseif strcmpi(gate,'Y')
    act_Gate = Y;
end


gate =1;

for k=1:n

    if k==l

        gate = kron(gate,act_Gate);
        
    else
        
        gate = kron(gate,I2);

    end

end
    
psi_Out = gate*psi;

end