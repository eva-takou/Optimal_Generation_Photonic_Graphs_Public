function Adj=create_encoded_RGS(n,opt)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Input: n: number of core qubits. 
%       opt: true to add leaves to the graph
%Output: Adjacency matrix of encoded RGS for tree encoding with
%        b0=b1=2.

if (-1)^n~=1
    
   error('Need even core for the encoded RGS.') 
   
end


%Make complete graph:

EdgeList={};

for k=1:n
    
    for l=k+1:n
        
        EdgeList=[EdgeList,{[k,l]}];
        
    end
    
end

%Take node l and l+1, and add an extra node to connect them

extra_nodes = n/2;
w           = n;
v           = [1,2];
for m=1:extra_nodes
   
    w = w+1;
    
    for l=1:2
       
        EdgeList = [EdgeList,{[w,v(l)]}];
        
    end
    
    v=v+2;
    
end

if ~opt
    
    Adj=edgelist_to_Adj(EdgeList,max([EdgeList{:}]));
    
else
   
    %Add two more leaves per core qubit
    w = max([EdgeList{:}])+1;
    
    for k=1:n
        
        EdgeList = [EdgeList,{[k,w]}];
        w        = w+1;
        EdgeList = [EdgeList,{[k,w]}];
        w        = w+1;
        
    end
    
    Adj=edgelist_to_Adj(EdgeList,max([EdgeList{:}]));
    
end

end