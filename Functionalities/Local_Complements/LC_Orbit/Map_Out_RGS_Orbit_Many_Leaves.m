function [AdjLC,all_nodes]=Map_Out_RGS_Orbit_Many_Leaves(core_qubits,num_leaves)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Input: core_qubits: # of core nodes
%       num_leaves: # of leaves per core qubits
%
%Function to map the orbit of RGS w/ multiple leaves, w/o including isomorphs.
%Default ordering is the optimal emission ordering that requires 2 emitters.

Adj         = create_opt_ordering_RGS_many_leaves(core_qubits,num_leaves);
N           = core_qubits + num_leaves*core_qubits;
core_labels = num_leaves+1:num_leaves+1:N; 
leaf_labels = setxor(1:N,core_labels); %every num_leaves
                                       %we connect with different core
%For 2nd pos of core label, exchange a core label with a leaf label
for k=2:length(core_labels)
   
    shift=(k-1)*num_leaves;
    
    temp =core_labels(k);
    
    core_labels(k)=leaf_labels(1+shift);
    
    leaf_labels(1+shift)=temp;
    
end



%--------------------------------------------------------------------------

nodes     = [1,2];
all_nodes = nodes;
l         = (3*(2*core_qubits+1)-(-1)^(core_qubits+1))/4;

while true
    
    others    = nodes(1)-1+nodes(1)*num_leaves;
    nodes     = nodes+2;
    
    all_nodes = [all_nodes,others,nodes];
    
    if length(all_nodes)>=l-1

        break

    end      

end

[~,b]     = unique(all_nodes,'first');
all_nodes = all_nodes(sort(b));

%Now go to all_nodes and replace 1:n with core labels.
%Also replace n+1:2*n with leaf labels.

cnt=0;
cnt_core=0;
for l=1:length(all_nodes)
   
    if all_nodes(l)<=core_qubits
       
        cnt_core=cnt_core+1;
        all_nodes(l) = core_labels(cnt_core);
        
    else
        cnt=cnt+1;
        all_nodes(l) = leaf_labels(cnt+(cnt-1)*num_leaves);
        
    end
    
end

%all_nodes = ordering(all_nodes);

if (-1)^core_qubits==1
   all_nodes(end)=[]; 
end  


tempAdj = Adj;

for k=1:length(all_nodes)
    
    tempAdj = Local_Complement(tempAdj,all_nodes(k));
    AdjLC{k}=tempAdj;
    
end


if length(all_nodes)~=length(AdjLC)
   error('Generated wrong orbit?') 
    
end

AdjLC=[{Adj},AdjLC];



end