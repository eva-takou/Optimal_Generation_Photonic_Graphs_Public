function [prob_P,prob_M,Proj1,Proj2]=measure_state(psi,n,qubit,basis)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 3, 2024
%--------------------------------------------------------------------------
%
%Function to perform a single-qubit Pauli measurement on a state vector.
%
%Inputs: psi: input state
%          n: total # of qubits
%       qubit: the qubit index that we measure
%       basis: 'X' or 'Y' or 'Z'
%
%Output: prob_P : probability for +1 outcome
%        prob_M : probability for -1 outcome
%        Proj1  : projector onto the +1 eigenspace
%        Proj2  : projector onto the 11 eigenspace

if qubit>n
   error('Qubit index exceeds the number of qubits contained in the state.') 
end


Z    = diag([1,-1]);
X    = [0 1 ; 1 0];
Y    = [0 -1i; 1i 0];


Pz_P = 1/2*(eye(2)+Z);
Pz_M = 1/2*(eye(2)-Z);

Px_P = 1/2*(eye(2)+X);
Px_M = 1/2*(eye(2)-X);

Py_P = 1/2*(eye(2)+Y);
Py_M = 1/2*(eye(2)-Y);


Proj1=1;
Proj2=1;

if strcmpi(basis,'Z')

    for k=1:n
       
        if k==qubit
            
            Proj1 = kron(Proj1,Pz_P);
            
        else 
            
            Proj1 = kron(Proj1,eye(2));
            
            
        end
        
    end

    for k=1:n
       
        if k==qubit
            
            Proj2 = kron(Proj2,Pz_M);
            
        else 
            
            Proj2 = kron(Proj2,eye(2));
            
            
        end
        
    end
    
    
elseif strcmpi(basis,'X')
    
    for k=1:n
       
        if k==qubit
            
            Proj1 = kron(Proj1,Px_P);
            Proj2 = kron(Proj2,Px_M);
            
        else 
            
            Proj1 = kron(Proj1,eye(2));
            Proj2 = kron(Proj2,eye(2));
            
        end
        
    end
    
    
elseif strcmpi(basis,'Y')
    
    for k=1:n
       
        if k==qubit
            
            Proj1 = kron(Proj1,Py_P);
            Proj2 = kron(Proj2,Py_M);
            
        else 
            
            Proj1 = kron(Proj1,eye(2));
            Proj2 = kron(Proj2,eye(2));
            
        end
        
    end
    
    
end


if all(all(Proj1==Proj2))
   error('Error in measurement.') 
end

psi_final1 = Proj1*psi;
psi_final2 = Proj2*psi;


prob_P = abs(psi_final1'*psi)^2/norm(psi_final1)^2;
prob_M = abs(psi_final2'*psi)^2/norm(psi_final2)^2;



end