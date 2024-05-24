function varargout=is_split_free_brute(Adj,verbose)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 24, 2024
%--------------------------------------------------------------------------
%
%Brute force way to check if the graph is split-free (prime).
%If it is not prime, we output the split too.
%
%Input: Adj: Adjacency matrix
%       verbose: true or false to display message
%Output: bool: true or false
%        V1|V2 partition
%        A\subset V1 and B\subset V2 which form the complete bipartite
%        graph.
%
%A split is a partition V1|V2 of V(G) with |V1|>=2<=|V2|
%st edges across V1 and V2 form the complete bipartite graph, for some
%subset A and B.
%In other words, we find N(V1)\V1 = {some nodes x in V2}
%                        N(V2)\V2 = {some nodes y in V1}

n = length(Adj);

if n==3 %All graphs on 3 nodes are prime.
    
    varargout{1} = true;
    varargout{2} = {[]};
    varargout{3} = {[]};
    return
    
end

V = 1:n;

for k=2:n-2 %|V1|,|V2| >=2
    
    all_V1 = nchoosek(V,k);
    
    for p=1:size(all_V1,1)
        
        V1 = all_V1(p,:);
        V2 = setxor(V,V1);
        
        Nv1 = [];
        Nv2 = [];
        
        for v1=1:length(V1) 
            
            Nv1 = [Nv1,Get_Neighborhood(Adj,V1(v1))'];
            
        end
        
        B = setdiff(Nv1,V1); %N(V1)\V1 = B \subset V2
        
        for v2=1:length(V2)
           
            Nv2 = [Nv2,Get_Neighborhood(Adj,V2(v2))'];
            
        end
        
        A = setdiff(Nv2,V2); %N(V2)\V2 = A\subset V1
        
        not_a_split = false;
        
        %does every a \in A connect with every b \in B?
        
        for l1=1:length(A)
            
            for l2=1:length(B)
            
                if Adj(A(l1),B(l2))~=1 %Not a split
                    
                    not_a_split = true;
                    break
                    
                end
                
            end
            
            if not_a_split
               break 
            end
            
        end
        
        
        if ~not_a_split %The split was found
            
            if verbose
               
                disp('A split was found.') 
                
            end
            
            varargout{1} = false;
            varargout{2} = {{V1},{V2}};
            varargout{3} = {{A},{B}};
            return            
            
        end
        
        
    end
    
    
end

%If we did not return, then it is split-free:
varargout{1} = true;
varargout{2} = {[]};
varargout{3} = {[]};


end