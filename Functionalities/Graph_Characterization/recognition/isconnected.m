function connected_cond=isconnected(in,n,Option)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 25, 2024
%--------------------------------------------------------------------------
%
%Check if the graph is connected.
%Input: in: the graph either as adjacency or graph
%       n: the order of the graph
%       Option: 'Adjacency' or 'Graph' to indicate type of input.
%Output: connected_cond: true or false

switch Option
    
    
    case 'Adjacency'

        if ~isa(in,'double') || ~isa(in,'single')
        
            G=graph(single(in));
            
        else
            
            G = graph(in);
            
        end
        
    case 'Graph'
        
        G=in;
end



for jj=1:n
    
    v = dfsearch(G,jj);
    
    if length(v)==n
        
        connected_cond = true;
       
        return
    end
    
end

connected_cond = false;



end