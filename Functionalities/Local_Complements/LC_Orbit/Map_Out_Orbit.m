function [Adj_LC]=Map_Out_Orbit(Adj,Optimizer)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%
%Script to generate the entire LC orbit of an input graph.
%Input: Adj: Adjacency matrix
%       Optimizer: 'all' to retain isomorphic graphs, or 'prune' to discard
%       isomorphic graphs
%Output: The LC orbit of the input graph

n              = length(Adj);
AdjList(1).Adj = {Adj};

switch Optimizer
    
    case 'all'
        
        COND=@(A,B) all(all(A==B)); %A and B are adjacencies
        
    case 'prune'
        
        %To convert to graph structure A has to be double or logical:
        
        if ~isa(Adj,'double')
           
            COND=@(A,B) all(all(A==B)) || isisomorphic(graph(double(A)),graph(double(B))); %A and B are adjacencies
            
        else
           
            COND=@(A,B) all(all(A==B)) || isisomorphic(graph(A),graph(B)); %A and B are adjacencies
            
        end
        
        
        
        
end


cnt=1;

while true %Till we generate no new graphs:

    AdjList(cnt+1).Adj={};

    for kk=1:length(AdjList(cnt).Adj) %for each adjacency in previous stage

        test_Adj = AdjList(cnt).Adj{kk};
        leaves   = detect_leaves(test_Adj,n);
        LC_nodes = setxor(1:n,leaves);

        for p=1:length(LC_nodes)

            flag   = true;
            newAdj = Local_Complement(test_Adj,LC_nodes(p));

            %Test that the newAdj is not the same with any of the
            %previously generated ones:

            all_Adjacencies=[AdjList.Adj];

            for l=1:length(all_Adjacencies)

                if COND(newAdj,all_Adjacencies{l})
                    
                   flag=false;

                   break 
                   
                end

            end

            if flag

                AdjList(cnt+1).Adj=[AdjList(cnt+1).Adj,{newAdj}];

            end

        end

    end

    if isempty(AdjList(cnt+1).Adj)

       break 

    end

    cnt=cnt+1;

end

Adj_LC = [AdjList.Adj];


end