function [node,p,bool_split_free,Adj]=find_pair(v,Adj0)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 24, 2024
%--------------------------------------------------------------------------
%
%Check if any of the 3 i-minors with respect to v of the input graph G is 
%prime. This is based on the theorem that if G is prime, then there exists
%some v\in V(G) st at least one of the three i-minors is still prime:
%G\v or G*v\v G*vwv\v. 
%
%
%Input: v: Node v to take the i-minors
%       Adj0: Adjacency matrix
%Output: node: the input node v
%        p: the operation which is either {{[]}}, {{v}}, {{v,w,v}}
%        bool_split_free: Flag to announce whether a split free sub-graph 
%        was found.
%       Adj: The adjacency of the i-minor that was prime.

verbose = false;
n       = length(Adj0);

if v>n
    error('Node v not in V.')
end


Adj      = Adj0;
Adj(:,v) = [];  %G\v
Adj(v,:) = [];

if is_split_free_brute(Adj,verbose)
   
    p    = {{[]}};
    node = {v};
    bool_split_free = true;
    return
    
else %G*v\v
    
    Adj      = Local_Complement(Adj0,v);
    Adj(:,v) = [];
    Adj(v,:) = [];
    
    if is_split_free_brute(Adj,verbose)
        
        p          = {{v}};
        node       = {v};
        bool_split_free = true;
        return
        
    else %G*vwv\v
        
        Adj = Adj0;
        Nv  = Get_Neighborhood(Adj,v);
        w   = Nv(1);
        Adj = Local_Complement(Adj,v);
        Adj = Local_Complement(Adj,w);
        Adj = Local_Complement(Adj,v);
        Adj(:,v)=[];
        Adj(v,:)=[];    
        
        if is_split_free_brute(Adj,verbose)
            
            p          = {{v,w,v}};
            node       = {v};
            bool_split_free = true;
            return
            
        else
           
            p          = {{[]}};
            node       = {[]};
            bool_split_free = false;
            Adj        = Adj0;
            
            return
            
        end
        
    end
    
end


end
