function Tab=Phase_Gate(Tab,qubit,n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%
%Implementation of the phase gate on the stabilizer Tableau.
%Inputs: Tab: The stabilizer Tableau (n x 2n+1 array)
%        qubit: index of qubit as represented in the Tableau
%        n: the # of qubits represented by the Tableau
%Output: The updated Tableau.

X = Tab(:,qubit);
Z = Tab(:,qubit+n);

Tab(:,end)     = bitxor(X.*Z,Tab(:,end));
Tab(:,qubit+n) = bitxor(X,Z);                    


end