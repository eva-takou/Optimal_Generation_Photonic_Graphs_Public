function Adj=complement_graph(Adj)
%Get the complement of a graph.
%Input: Adjacency matrix
%Output: The adjacency matrix of the complement graph.

n=length(Adj);
for jj=1:n
    
   for kk=jj+1:n
       
       
      Adj(jj,kk) = bitxor(Adj(jj,kk),1);
      Adj(kk,jj) = Adj(jj,kk);
       
       
       
   end
    
    
    
    
    
end


end