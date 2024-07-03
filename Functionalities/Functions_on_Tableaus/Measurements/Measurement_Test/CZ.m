function CZ_Gate=CZ(l,m,n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 3, 2024
%--------------------------------------------------------------------------
%
%Function to create a 2^n x 2^n CZ gate acting on 2 out of the n qubits.
%CZ is symmetric so control and target do not matter.
%Inputs: l: control qubit (index \in [1,n])
%        m: target qubit (index \in [1,n])
%        n: total # of qubits
%Output: CZ_Gate: the matrix representation of the CZ (2^n x 2^n array)

if l>n || m>n
    
    error('Qubit index bigger than dimension of gate.')
    
end

s00 = [1 0 ; 0 0];
s11 = [0 0 ; 0 1];
Z   = diag([1,-1]);


CZ_part1 = 1;
CZ_part2 = 1;

for k=1:n
   
    if k==l
       
        CZ_part1 = kron(CZ_part1,s00);
        
    elseif k==m
        
        CZ_part1 = kron(CZ_part1,eye(2));
        
    else
        
        CZ_part1 = kron(CZ_part1,eye(2));
        
    end
    
end


for k=1:n
   
    if k==l
       
        CZ_part2 = kron(CZ_part2,s11);
        
    elseif k==m
        
        CZ_part2 = kron(CZ_part2,Z);
        
    else
        
        CZ_part2 = kron(CZ_part2,eye(2));
        
    end
    
end

CZ_Gate = CZ_part1 + CZ_part2;


end