function Tab=Pauli_Gate(Tab,qubit,n,Pauli)
%Implementation of the Pauli X,Y, or Z gate on the stabilizer Tableau.
%Inputs: Tab: The Tableau
%        qubit: an array of 2 qubits (first one is control)
%        n: the # of qubits represented by the Tableau.
%        Pauli: 'X', 'Y', or 'Z'
%Output: The updated Tableau.

%Update from this: https://arxiv.org/pdf/2311.03906.pdf

switch Pauli
    
    case 'X' %X gate on qubit a: ria=ria+zia (stabs and destabs)

        %Find where we have non-zero zia:
        zi             = Tab(:,qubit+n);
        Tab(:,end) = bitxor(Tab(:,end),zi);
        

        
    case 'Y' %Y gate on qubit a: ria=ria+zia+xia (stabs and destabs)
        
        zi             = Tab(:,qubit+n);
        xi             = Tab(:,qubit);
        Tab(:,end) = bitxor(Tab(:,end),bitxor(zi,xi));
        
      
        
    case 'Z' %Y gate on qubit a: ria=ria+xia (stabs and destabs)
        
        
        xi             = Tab(:,qubit);
        Tab(:,end) = bitxor(Tab(:,end),xi);
        
      
        
end
       

end