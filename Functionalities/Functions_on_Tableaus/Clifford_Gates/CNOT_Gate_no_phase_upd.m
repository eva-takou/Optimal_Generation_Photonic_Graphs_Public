function  Tab=CNOT_Gate_no_phase_upd(Tab,qubit,n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%
%Implementation of the CNOT gate on the stabilizer Tableau w/o the phase
%update. 
%Inputs: Tab: The stabilizer Tableau (n x 2n+1 array)
%        qubit: an array of 2 qubits (first one is control)
%        n: the # of qubits represented by the Tableau
%Output: The updated Tableau.


XC     = Tab(:,qubit(1));
ZC     = Tab(:,qubit(1)+n);

XT     = Tab(:,qubit(2));
ZT     = Tab(:,qubit(2)+n);

Tab(:,qubit(2))    = bitxor(XT,XC);
Tab(:,qubit(1)+n)  = bitxor(ZT,ZC);

end