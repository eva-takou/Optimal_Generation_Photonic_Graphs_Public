function [gi,non_shift_nodes,Pseq]=first_pass_is_circle(Adj0)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 24, 2024
%--------------------------------------------------------------------------
%
%Function to reduce the input prime graph to a prime graph of 5 nodes,
%after taking elementary i-minors, that are still prime. This is the "first"
%pass subroutine mentioned in Bouchet's circle graph recognition algorithm.
%
%Input: Adj0: Adjacency matrix
%Output: gi: A cell of adjacency matrices, for the graphs starting from 
%            i=n till i=5
%        non_shifted_nodes: The node we remove in each stage according to
%        the ordering in the graph gi
%        Pseq: A cell array containing the operation \empty, *v, *vwv we
%        perform per stage.

if ~is_split_free_brute(Adj0,false)
    
    error('Error in first pass. The input graph is not prime wrt splits.')
    
end

n   = length(Adj0);
Adj = Adj0;

non_shift_nodes = [];
Pseq            = [];
gi              = {Adj0};

while n>5
    
    for v = 1:n %Find the prime subgraph
    
        [node,p,bool_split_free,Adj] = find_pair(v,Adj); 
        
        if bool_split_free
            
           break 
           
        end
    
    end
    
    if ~bool_split_free
       
        error('Checked all i-minors, and no prime subgraph was found.')
        
    end

    non_shift_nodes = [non_shift_nodes,node]; %Removed node has the labeling it had in the graph
                                              %of the particular stage
    
    Pseq     = [Pseq,p];
    gi       = [gi,{Adj}];
    n        = length(Adj); %update # of nodes of Adj (n->n-1)
    
end

end