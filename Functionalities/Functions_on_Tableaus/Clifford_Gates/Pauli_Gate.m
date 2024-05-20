function Tab=Pauli_Gate(Tab,qubit,n,Pauli)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%
%Implementation of the Pauli X,Y, or Z gate on the stabilizer Tableau.
%Inputs: Tab: The stabilizer Tableau (n x 2n+1 array)
%        qubit: index of qubit as represented in the Tableau
%        n: the # of qubits represented by the Tableau
%        Pauli: 'X', 'Y', or 'Z' (char)
%Output: The updated Tableau.
%
%Based on Ref: https://arxiv.org/pdf/2311.03906.pdf

switch Pauli
    
    case 'X' %X gate on qubit a: ri_a=ri_a+zi_a 

        zi         = Tab(:,qubit+n);
        Tab(:,end) = bitxor(Tab(:,end),zi);
        
    case 'Y' %Y gate on qubit a: ri_a=ri_a+zi_a+xi_a 
        
        zi         = Tab(:,qubit+n);
        xi         = Tab(:,qubit);
        Tab(:,end) = bitxor(Tab(:,end),bitxor(zi,xi));
        
    case 'Z' %Y gate on qubit a: ri_a=ri_a+x_ia 
        
        xi         = Tab(:,qubit);
        Tab(:,end) = bitxor(Tab(:,end),xi);
        
end
       
end