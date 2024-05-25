function Adj=create_triangle_free_graph(n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------

%Input: n: # of nodes
%Output: Adjacency matrix of triangle-free graph       

while true

    Adj = create_random_graph(n);
    
    if trace(single(Adj)*single(Adj)*single(Adj))==0
       
        break
        
    end
    
end

end