function Adj=create_encoded_RGS_Opt_Ordering(n,leaves)
%%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Input: n: number of core nodes
%       leaves: leaf nodes per core node
%Output: Encoded RGS with optimal emission ordering that needs only 2 emitters.
%        The branching parameters are b0=2, and b1=leaves.

if (-1)^n~=1

   error('Need even # of core nodes for encoded RGS.') 
   
end

%Pattern: (core->leaves->core->leaves->top) x num of triangles.
%if l>=2 exchange labeling of top with last core node.

EdgeList={};

v         = 1;
triangles = n/2;
all_cores = [];

for l=1:triangles
    
    %Core - leaves
    cores=[v];
    for m=1:leaves
       
        w = max([EdgeList{:},v]);
        if isempty(w)
            w=1;
        end
        EdgeList=[EdgeList,{[v,w+1]}];
        
    end
    
    v=max([EdgeList{:}])+1;
    cores=[cores,v];
    %Core -leaves
    for m=1:leaves
       
        w = max([EdgeList{:},v]);
        EdgeList=[EdgeList,{[v,w+1]}];
        
    end    
    
    %Top:
    k = max([EdgeList{:}]);
    for m=1:2
        
        EdgeList=[EdgeList,{[k+1,cores(m)]}];
        
    end
    
    v=max([EdgeList{:}])+1;
    all_cores=[all_cores,cores];
    
    %Exchange core with top 
    
    if l>=2 
       
        for m=1:length(EdgeList)
           
            this_edge=EdgeList{m};
            
            loc1 = this_edge==k+1;
            loc2 = this_edge==all_cores(end);
            
            if any(loc1) || any(loc2)
                new_edge=this_edge;
                new_edge(loc1)=all_cores(end);
                new_edge(loc2)=k+1;
                EdgeList{m}=new_edge;
                
            end
            
            
            
        end
        all_cores(end)=k+1;
        
    end
    
end

for l1=1:length(all_cores)
   
    for l2=l1+1:length(all_cores)
       
        EdgeList=[EdgeList,{[all_cores(l1),all_cores(l2)]}];
        
    end
    
end

Adj=edgelist_to_Adj(EdgeList,max([EdgeList{:}]));

end