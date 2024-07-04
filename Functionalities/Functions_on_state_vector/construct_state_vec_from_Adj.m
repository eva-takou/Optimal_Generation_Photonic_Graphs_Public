function psi = construct_state_vec_from_Adj(Adj)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 4, 2024
%--------------------------------------------------------------------------
%
%Function to create the state vector corresponding to a graph state.
%Inputs: Adj: Adjacency matrix
%Output: psi: The state vector representing the graph

n    =  length(Adj);   %# of qubits
ketP = [1;1]/sqrt(2);  %|+>
psi  = ketP;

for l=1:n-1

    psi = kron(ketP,psi);

end

for m=1:n

    for l=m+1:n

        if Adj(m,l)==1

            psi = apply_CZ(m,l,n,psi);

        end

    end

end


end