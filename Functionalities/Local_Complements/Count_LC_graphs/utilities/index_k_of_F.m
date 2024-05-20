function k=index_k_of_F(Adj)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%
%Count the index k(G) of a graph. %Based on Bouchet's paper: Recognizing locally equivalent graphs, 1991.
%Input: Adj: Adjacency matrix
%Output:  k: index k of the graph.

n             = length(Adj);
dim_nu_G      = bineighborhood_space(Adj);
dim_nu_G_orth = n-dim_nu_G;
k             = 2^dim_nu_G_orth;

[bool,~]      = is_in_class_mu(Adj);

if bool 
   
    k = k+2;
    
end


end