function leaves = detect_leaves(G0,n)
%Function to detect leaves of an input graph.
%Input: G0: adjacency matrix
%        n: # of qubits
%Output: the indices of the leaf qubits of the graph G0.

cnt=0;
for ll=1:n

    neighbors = Get_Neighborhood(G0,ll);
    
    if length(neighbors)==1
        
        cnt=cnt+1;
        leaves(cnt)=ll;
        
    end
    
    
end

if cnt==0
    
    leaves=[];
    
end
    
    



end