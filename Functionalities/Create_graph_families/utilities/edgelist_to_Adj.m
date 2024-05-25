function Adj=edgelist_to_Adj(EdgeList,n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Function to convert an Edgelist to the adjacency matrix.
%
%Input: EdgeList: A cell array with the edges of the graph
%       n: # of graph nodes
%Output: Adj: The adjacency matrix of the graph (int8)

Adj = zeros(n,n,'int8');

for jj=1:length(EdgeList)
    
   this_edge = EdgeList{jj} ;
   v         = this_edge(1);
   w         = this_edge(2);
   Adj(v,w)  = 1;
   
end

Adj = Adj + Adj';

end