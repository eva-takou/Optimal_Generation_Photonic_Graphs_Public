function Adj=create_regular_graph(n)


while true
    
   Adj=create_random_graph(n);
   G=graph(double(Adj));
   
   degs=degree(G);
   
   degs=degs-degs(1);
   
   if all(degs==0)
       
       break
       
   end
    
    
end





end