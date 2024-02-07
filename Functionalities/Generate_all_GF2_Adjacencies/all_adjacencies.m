function Adj=all_adjacencies(n,discard_isomorphism)
%Function to create all adjacency nxn matrices in GF2.
%Input:  n: the number of nodes 
%        discard_isomorphism: true or false to keep or not the isomorphs.
%Output: all adjacency matrices of order n (connected graphs) in cell array.

edges={};
for jj=1:n
    
    for kk=jj+1:n
    
        edges=[edges,{[jj,kk]}];
   
    end    
end

Le  = length(edges);
Adj = {};

edges = parallel.pool.Constant(edges);

parfor jj=n-1:Le %Need to choose AT LEAST n-1 edges for the graph to be connected (necessary but not sufficient)
    
    combs = nchoosek(1:Le,jj);
    
    disp(['running jj=',num2str(jj),' out of ',num2str(Le),' ...'])
    
    rows = size(combs,1);
    
    for mm=1:rows
    
        disp(['mm=',num2str(mm),' out of ',num2str(rows)])
        
        this_comb = combs(mm,:);

        if length(unique([edges.Value{[this_comb]}]))==n %one requirement (necessary, not sufficient) for connected graph is that every node appears in at least one edge
                            
            temp = reshape([edges.Value{[this_comb]}],2,length([edges.Value{[this_comb]}])/2).';   
            
            TEMP = zeros(n,n,'int8');
            idx=sub2ind(size(TEMP),temp(:,1),temp(:,2));
            TEMP(idx)=1;
            
            
            TEMP=TEMP+TEMP';
            
            Adj = [Adj,{TEMP}];
            
        end
        
    end
    
end

disp('Done.')

clearvars -except Adj n discard_isomorphism

%Check if some of the graphs are disconnected based on dfs search
indx=[];
disp('-----------------------------------------------------------')
disp('Checking disconnected or not...')
parfor kk=1:length(Adj)
    if ~isconnected(Adj{kk},n,'Adjacency')
       indx=[indx,kk]; 
    end
end
disp('Done.')
Adj(indx)=[];
disp('-----------------------------------------------------------')
disp(['Found ',num2str(length(Adj)),' connected graphs.'])

disp('-----------------------------------------------------------')

if discard_isomorphism
    
    
disp('Converting them to graphs...')

for jj=1:length(Adj)
    
   g{jj}=graph(double(Adj{jj}));
    
end
        
disp('Done.')
disp('-----------------------------------------------------------')        

indx=[];
LG = length(Adj);
    
disp('Checking isomorphism....')
    

parfor jj=1:LG

    disp(['jj=',num2str(jj),' out of ',num2str(LG)])

    for kk=jj+1:LG

        if isisomorphic(g{jj},g{kk})

           indx=[indx,kk]; 
           break
        end

    end


end

disp('Done.')
    
Adj(unique(indx))=[];

disp(['Found ',num2str(length(Adj)),' connected non-isomorphic graphs.'])
    
end



end