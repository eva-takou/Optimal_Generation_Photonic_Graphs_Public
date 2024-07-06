% Check the size of LC orbit of circle graphs

clear; clc; close all;

iterMax = 100;
n       = 7;

for iter = 1:iterMax

    Adj = create_random_graph(n);
    l   = count_l_Bouchet(Adj);
    
    if ~isnan(l) %it is a circle graph
       
        Adj_LC = Map_Out_Orbit(Adj,'all');
        
        length_of_orbit = length(Adj_LC);
    
        if l~=length_of_orbit
           error('Error in the implementation of Bouchet`s algorithm.') 
        end    
        
    end

end