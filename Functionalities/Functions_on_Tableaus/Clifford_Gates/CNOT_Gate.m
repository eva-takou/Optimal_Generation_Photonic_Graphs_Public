function  Tab=CNOT_Gate(Tab,qubit,n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%
%Implementation of the CNOT gate on the stabilizer Tableau.
%Inputs: Tab: The stabilizer Tableau
%        qubit: an array of 2 qubits (first one is control)
%        n: the # of qubits represented by the Tableau.
%Output: The updated Tableau.

XC     = Tab(:,qubit(1));
ZC     = Tab(:,qubit(1)+n);
r      = Tab(:,end);

XT     = Tab(:,qubit(2));
ZT     = Tab(:,qubit(2)+n);

Tab(:,qubit(2))    = bitxor(XT,XC);
Tab(:,qubit(1)+n)  = bitxor(ZT,ZC);

%The phase update is: XC.*ZT.*( bitxor( XT ,bitxor(ZC,1)) );
temp = mod(ZC+1,2);     %Mod is faster here than bitxor
temp = bitxor(XT,temp);
temp = ZT.*temp;
temp = XC.*temp;


Tab(:,end) = bitxor(temp,r); 


end