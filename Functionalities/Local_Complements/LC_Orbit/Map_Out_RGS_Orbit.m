function [AdjLC,all_nodes]=Map_Out_RGS_Orbit(n,ordering)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Function to map the orbit of RGS, w/o including isomorphs.
%First n qubits in ordering are core qubits
%Last n qubits in ordering are leaf qubits
%Input: n: number of core nodes
%       ordering: first n qubits are core nodes, last n qubits are leaf
%       nodes.

Adj = create_RGS(n,ordering,n,'Adjacency');


nodes     = [1,2];
all_nodes = [nodes];
l         = (3*(2*n+1)-(-1)^(n+1))/4;

while true
    
    others    = n+nodes(1);
    nodes     = nodes+2;
    all_nodes = [all_nodes,others,nodes];
    
    if length(all_nodes)>=l-1

        break

    end      

end

[~,b]     = unique(all_nodes,'first');
all_nodes = all_nodes(sort(b));

all_nodes = ordering(all_nodes);

if (-1)^n==1
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