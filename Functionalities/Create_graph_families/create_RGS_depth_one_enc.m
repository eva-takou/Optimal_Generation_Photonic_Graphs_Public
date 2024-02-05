function Adj=create_RGS_depth_one_enc(core_qubits,num_leaves)


%Make fully connected core first:

EdgeList = {};


for node = 1:core_qubits
   
    for node_other = node+1:core_qubits
        
        EdgeList = [EdgeList,[node,node_other]];
        
    end
    
end

%To each core qubit attach num_leaves



leaf=core_qubits;

for node = 1:core_qubits
    
    for k=1:num_leaves
       
        leaf     = leaf+1;
        EdgeList = [EdgeList,[node,leaf]];
        
        
    end
    
   
end

n=max([EdgeList{:}]);

Adj = edgelist_to_Adj(EdgeList,n);





end