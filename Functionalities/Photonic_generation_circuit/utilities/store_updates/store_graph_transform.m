function graphs = store_graph_transform(G,identifier,graphs)
%Function to store the graphs of the circuit generation in a list.
%Input: G: the graph to store
%       identifier: if this after a TRM, a decoupling step, or photon
%       absorption
%       graphs: the remaining circuit so far (could be empty)
%Output: the updated graphs

if isempty(graphs)

    graphs.Adjacency{1}  = G;
    graphs.identifier{1} = identifier;
    
else

    graphs.Adjacency{end+1}  = G;
    graphs.identifier{end+1} = identifier;
    
end

end