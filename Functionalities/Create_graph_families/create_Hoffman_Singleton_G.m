function Adj=create_Hoffman_Singleton_G




adjC5=create_Cn(5,'Adjacency'); %Pentagon?

G=graph(adjC5);

%Constructed from pentagon and pentagram as follows: 
%Take five pentagons $P_h$
%and five pentagrams $Q_i$ . 
%Join vertex $j$ of $P_h$ to vertex $h·i+j$ of $Q_i$ [1].
%Vertices modulo 5.
%[1] https://en.wikipedia.org/wiki/Hoffman%E2%80%93Singleton_graph


%Make the 5 pentagons:

G=graph();

for l=1:5 %edges between v_{i-1}-v_{i} and v_{i}-v_{i+1}
    
   for w=1:5 
       
       v = w+5*(l-1);

       if w~=5
            G=addedge(G,v,v+1);
       else
           G=addedge(G,v,1+5*(l-1));
       end
   end
   
   plot(G)
   
    
end
%25 nodes so far


%Constract the 5 pentagrams:
for l=1:5 %edges between v_{i-2}-v_{i} and v_{i}-v_{i+2}
    
   for w=1:5 
       
       v = w+5*(l-1)+25;

       for m=w+1:5
       
            if m==w+2 
           
                G=addedge(G,v,v+2);
            elseif  m==w+3
                G=addedge(G,v,v+3);
                
            end
            
       end    
               
       
   end
   

    
end

%50 nodes total.

for h=1:5
   
   for j=1:5 
       
       vertex_of_Ph = j+5*(h-1);

       for i=1:5
          
           
           vertex_of_Qi = 5*(i-1)+25+j;
           %vertex_of_Qi = 5*(j-1)+25+i;
           
           %vertex_of_Qi = 5*(j-1)+i;
           
           
           G=addedge(G,vertex_of_Qi,vertex_of_Ph);
           
       end
       
   end
   
   
end
close all
plot(G,'layout','circle','EdgeColor','k')

degree(G)
%It has 175 edges, and it is regular with deg=7 for all nodes


[];
iterMax=10;

figure(2)
tiledlayout('flow')

for iter=1:iterMax
    
    ordering=randperm(50);
    
    nexttile
    
    P=eye(50);
    P(:,1:50)=P(:,ordering);
    
    plot(graph(P*adjacency((G))*P'),'layout','circle','EdgeColor','k')
    hold on
    
    


end
[];

end
