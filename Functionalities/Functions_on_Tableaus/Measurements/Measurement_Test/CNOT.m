function CNOT_Gate=CNOT(l,m,n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 3, 2024
%--------------------------------------------------------------------------
%
%Function to create a 2^n x 2^n CNOT gate acting on 2 out of the n qubits.
%Inputs: l: control qubit (index \in [1,n])
%        m: target qubit (index \in [1,n])
%        n: total # of qubits
%Output: CNOT_Gate: the matrix representation of the CNOT (2^n x 2^n array)

if l>n || m>n
    
    error('Qubit index bigger than dimension of gate.')
    
end

H       = [1 1 ;1 -1]/sqrt(2);
CZ_Gate = CZ(l,m,n);
H_all   = 1;

for k=1:n
   
    if k==m %Target
        
        H_all = kron(H_all,H);
        
    else
        
        H_all = kron(H_all,eye(2));
        
    end
end

CNOT_Gate = H_all * CZ_Gate * H_all;

end