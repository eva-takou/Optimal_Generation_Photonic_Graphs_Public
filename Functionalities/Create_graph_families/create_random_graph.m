function Adj=create_random_graph(n)
%Create a random graph of order n.
%Input: n: # of qubits
%       formatOption: 'Edgelist' or 'Adjacency' to control the output.
%Output: The adjacency of the graph.


Adj = round(rand(n));
Adj = triu(Adj) + triu(Adj,1)';
Adj = Adj - diag(diag(Adj));

Adj = int8(Adj);

%check that it is a connected graph with dfs:

if ~isconnected(Adj,n,'Adjacency')
    
    %call again
    Adj=create_random_graph(n);
else
    return
    
end






end