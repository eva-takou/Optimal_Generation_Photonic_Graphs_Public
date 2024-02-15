function Adj=create_RGS_natural_ordering(n)
%n: number of core qubits
%Adj: adjacency matrix of RGS with natural emission ordering.

cores  = 1:2:2*n;
leaves = 2:2:2*n;
EdgeList={};
for l1=1:length(cores)
   
    
    for l2=l1+1:length(cores)
        EdgeList=[EdgeList,{[cores(l1),cores(l2)]}];
    end
    
end

for k=1:n
    
    EdgeList=[EdgeList,{[cores(k),leaves(k)]}];
    
end

Adj=edgelist_to_Adj(EdgeList,2*n);



end