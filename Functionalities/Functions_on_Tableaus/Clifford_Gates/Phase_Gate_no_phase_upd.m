function Tab=Phase_Gate_no_phase_upd(Tab,qubit,n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%
%Implementation of the phase gate on the stabilizer Tableau w/o the phase
%update.
%Inputs: Tab: The stabilizer Tableau (n x 2n+1 array)
%        qubit: index of qubit as represented in the Tableau
%        n: the # of qubits represented by the Tableau
%Output: The updated Tableau.

X = Tab(:,qubit);
Z = Tab(:,qubit+n);

Tab(:,qubit+n) = bitxor(X,Z);                    


end