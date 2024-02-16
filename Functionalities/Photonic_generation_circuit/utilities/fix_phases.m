function [Tab,Circuit]=fix_phases(Tab,np,ne,Circuit,Store_Gates)
%Function to put the phases of stabilizers to +1.
%Input: Tab: Tableau
%       np: # of photons
%       ne: # of emitters
%       Circuit: The circuit so far
%Output: Tab: The updated tableau
%        Circuit: The updated circuit

n = np+ne;

for ii=1:n
    
    phase = Tab(ii,end);
    
    if phase~=0
        
        Tab     = Pauli_Gate(Tab,ii,n,'X');
        Circuit = store_gate_oper(ii,'X',Circuit,Store_Gates); 
    end
    
end

end