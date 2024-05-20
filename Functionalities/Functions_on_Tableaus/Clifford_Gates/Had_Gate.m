function Tab=Had_Gate(Tab,qubit,n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%
%
%Implementation of the Hadamard gate on the stabilizer Tableau.
%Inputs: Tab: The stabilizer Tableau (n x 2n+1 array)
%        qubit: index of qubit as represented in the Tableau
%        n: the # of qubits represented by the Tableau.
%Output: The updated Tableau.

XZ         = Tab(:,qubit).*Tab(:,qubit+n);
Tab(:,end) = bitxor(XZ,Tab(:,end));         

temp           = Tab(:,qubit+n); 
Tab(:,qubit+n) = Tab(:,qubit);
Tab(:,qubit)   = temp;

end