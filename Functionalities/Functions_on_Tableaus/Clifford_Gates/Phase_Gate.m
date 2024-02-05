function Tab=Phase_Gate(Tab,qubit,n)
%Implementation of the phase gate on the stabilizer Tableau.
%Inputs: Tab: The Tableau
%        qubit: an array of 2 qubits (first one is control)
%        n: the # of qubits represented by the Tableau.
%Output: The updated Tableau.

X = Tab(:,qubit);
Z = Tab(:,qubit+n);

Tab(:,end)     = bitxor(X.*Z,Tab(:,end));
Tab(:,qubit+n) = bitxor(X,Z);                    


end