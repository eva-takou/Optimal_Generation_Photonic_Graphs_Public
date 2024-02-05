function Adj=create_triangle_free_graph(n)


while true

    Adj = create_random_graph(n);
    Adj = double(Adj);
    if trace(Adj*Adj*Adj)==0
       
        break
        
    end
    
end








end