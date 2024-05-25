function Adj=create_RGS_opt_ordering(n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Input: n: number of core nodes of RGS
%Output: Adjacency matrix of RGS
%
%Start with natural emission ordering.
%Leaves labeled with step 2 as 1,3,... till n

leaf_labels = 1:2:2*n;
core_labels = 2:2:2*n;

for k=1:length(core_labels)
   
    EdgeList{k}=[leaf_labels(k),core_labels(k)];
    
end

%Create fully connected core:

for k1=1:length(core_labels)
    
    for k2=k1+1:length(core_labels)
       
        EdgeList=[EdgeList,{[core_labels(k1),core_labels(k2)]}];
        
    end
    
    
end

%Exchange 2nd to core qubit with last leaf qubit

Adj=edgelist_to_Adj(EdgeList,2*n);

P=eye(2*n);
P(:,[core_labels(end-1),leaf_labels(end)])=P(:,[leaf_labels(end),core_labels(end-1)]);

Adj=P*single(Adj)*P';
Adj=int8(Adj);

end