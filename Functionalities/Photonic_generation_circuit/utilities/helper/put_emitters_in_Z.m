function [Tab,Circuit]=put_emitters_in_Z(n,Tab,Circuit,emitters_in_X,emitters_in_Y,Store_Gates)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 14, 2024
%--------------------------------------------------------------------------
%
%Script to put the input emitters in Z (for some stabilizer row), by 
%applying local Clifford gates.
%
%Inputs: Tab: Tableau
%        Circuit: The circuit we have so far
%        emitters_in_X/Y: the index of emitters in X,Y counting from
%        np+1:n
%        Store_Gates: true or false to store the gates.
%Output: Tab: The updated Tableau
%        Circuit: The updated circuit

for jj=1:length(emitters_in_X)

    Tab     = Had_Gate(Tab,emitters_in_X(jj),n);
    Circuit = store_gate_oper(emitters_in_X(jj),'H',Circuit,Store_Gates);   

end

for jj=1:length(emitters_in_Y)

    Tab  = Phase_Gate(Tab,emitters_in_Y(jj),n);
    Tab  = Had_Gate(Tab,emitters_in_Y(jj),n);
    
    Circuit = store_gate_oper(emitters_in_Y(jj),'P',Circuit,Store_Gates);   
    Circuit = store_gate_oper(emitters_in_Y(jj),'H',Circuit,Store_Gates);   

end    

end