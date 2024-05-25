function Adj=create_random_graph(n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Create a random graph of order n.
%Input: n: # of qubits
%Output: The adjacency of the graph.

Adj = round(rand(n));
Adj = triu(Adj) + triu(Adj,1)';
Adj = Adj - diag(diag(Adj));

%check that it is a connected graph with dfs:

if ~isconnected(Adj,n,'Adjacency')
    
    %call again
    Adj = create_random_graph(n);
    
else
    
    Adj = int8(Adj);
    return
    
end

end