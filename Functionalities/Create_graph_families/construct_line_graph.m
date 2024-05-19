function Adj_line=construct_line_graph(Adj)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Construct the line graph L(G) of the graph:
%For each edge in G, make a vertex in L(G).
%For every 2 edges in G that have a vertex in common, make an edge between
%their corresponding vertices in L(G).
%
%Input: Adjacency matrix of G
%Output: Line graph of G

n   = length(Adj);
cnt = 0;

for jj=1:n
    
    for kk=jj+1:n
        
        if Adj(jj,kk)==1 %we have an edge
             
            cnt=cnt+1;
            edges{cnt} = [jj,kk];
             
        end
        
    end
    
end

max_node = cnt;
nodes    = 1:max_node;
Adj_line = zeros(max_node,max_node,'int8');

for l1=1:length(edges)
    
    edge_1 = edges{l1};
    
    for l2=l1+1:length(edges)
        
        edge_2=edges{l2};
        
        if any(ismember(edge_1,edge_2))
            
            TEMP = zeros(max_node,max_node);
            TEMP(nodes(l1),nodes(l2))=1;
            TEMP=TEMP+TEMP';
            
            Adj_line = Adj_line  + TEMP;
            
        end
        
    end
   
end


end