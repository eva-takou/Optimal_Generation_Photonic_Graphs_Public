function Adj=create_opt_ordering_RGS_many_leaves(core_qubits,num_leaves)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Input: core_qubits: number of core qubits. 
%       num_leaves: number of leaves per core qubit.
%Output: Adjacency matrix of RGS with multiple leaves with optimal emission
%        ordering that requires only 2 emitters.

%--------------------------------------------------------------------------
%The pattern to generate the optimal ordering:
%Leaves of 1st core
%Core
%Next core 
%Leaves of next core
%Core
%Next core

%Leaves of this core
%Leaves of next core
%Core
%Exchange last core with one of last leaves

%Leaves -> core -> next leaves -> core -> exchange this core with a leaf
%Leaves -> core -> exchange leaf with core
%Leaves -> core -> exchange leaf with core
%--------------------------------------------------------------------------

%Put natural emission ordering (leaves-then core of the set of leaves)
%Exchange core of all others except the 1st core with 1 of its leaves

N           = core_qubits + num_leaves*core_qubits;
core_labels = num_leaves+1:num_leaves+1:N; 
leaf_labels = setxor(1:N,core_labels); %every num_leaves
                                       %we connect with different core

%For 2nd pos of core label, exchange a core label with a leaf label
for k=2:length(core_labels)
   
    shift                = (k-1)*num_leaves;
    temp                 = core_labels(k);
    core_labels(k)       = leaf_labels(1+shift);
    leaf_labels(1+shift) = temp;
    
end

                                       
EdgeList={};

for k1=1:length(core_labels)
    
    for k2=k1+1:length(core_labels)
        
    EdgeList = [EdgeList,[core_labels(k1),core_labels(k2)]];
        
    end
    
end

for k=1:length(core_labels)
    
    shift=(k-1)*num_leaves;
    
        for leaf=1:num_leaves

            EdgeList = [EdgeList,[core_labels(k),leaf_labels(leaf+shift)]];

        end        
       
end

Adj=edgelist_to_Adj(EdgeList,N);


end