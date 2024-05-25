function bool=is_circle_graph_obstruction_old(A)

%Check if the adjacency matrix has a vertex minor that is isomorphic to
%either W5, or BW3, or W7 of Bouchet's circle graph obstructions.

%6 node graph
AdjW5 = [0 1 0 0 1 1;...
         1 0 1 0 0 1;...
         0 1 0 1 0 1;...
         0 0 1 0 1 1;...
         1 0 0 1 0 1;...
         1 1 1 1 1 0];
%8 node graph     
AdjW7 = [0 1 0 0 0 0 1 1;...
         1 0 1 0 0 0 0 1;...
         0 1 0 1 0 0 0 1;...
         0 0 1 0 1 0 0 1;...
         0 0 0 1 0 1 0 1;...
         0 0 0 0 1 0 1 1;...
         1 0 0 0 0 1 0 1;...
         1 1 1 1 1 1 1 0];     

%7 node graph
AdjBW3 = [0 1 0 0 0 1 0;...
          1 0 1 0 0 0 1;...
          0 1 0 1 0 0 0;...
          0 0 1 0 1 0 1;...
          0 0 0 1 0 1 0;...
          1 0 0 0 1 0 1;...
          0 1 0 1 0 1 0];     

n  = length(A);

if n==6
    
    if isisomorphic(graph(A),graph(AdjW5)) %Is it isomorphic (permutation) of W5?
        
        bool=true;
        return
    else
       
        %Check LC equivalence for all permutations.
        
        p  = perms(1:n);
        P0 = eye(n);

        for jj=1:size(p,1)
           
            this_perm = p(jj,:);
            P         = P0;
            P(:,1:n)  = P(:,this_perm);
            
            [~,LC_flag]=LC_check(P*A*P',AdjW5);
            
            if LC_flag
                
                bool=true;
                return
                
            end
            
        end
        
        if ~LC_flag
            
            bool=false;
            
        end
        
        
        
    end
    
    bool=false;
    return
    
    
elseif n==7
    
    if isisomorphic(graph(A),graph(AdjBW3)) %isomorphic to BW3?
        
        bool=true;
        return
        
    end
    
    %Check LC equivalence for all perms.
    p       = perms(1:n);
    P0      = speye(n);
    
    for jj=1:size(p,1)

        this_perm = p(jj,:);
        P         = P0;
        P(:,1:n)  = P(:,this_perm);

        [~,LC_flag]=LC_check(P*A*P',AdjBW3);

        if LC_flag

            bool=true;
            return

        end

    end

    
    %otherwise, test if A\{v} is isomorphic to W5.
    
    for v=1:n
        
       Atest = A;
       Atest(:,v)=[];
       Atest(v,:)=[];
       
       if isisomorphic(graph(Atest),graph(AdjW5))
          
           bool=true;
          return
           
       end
       
    end
    
    p  = perms(1:n-1);
    P0 = speye(n-1);
    
    for v=1:n
        
       Atest = A;
       Atest(:,v)=[];
       Atest(v,:)=[];
       
       
       for jj=1:size(p,1)
          
           this_perm   = p(jj,:);
           P           = P0;
           P(:,1:n-1)  = P(:,this_perm);
           [~,LC_flag] = LC_check(P*Atest*P',AdjW5);
           
           
           if LC_flag
               
               bool=true;
               return
               
           end
           
       end
       
       
    end    
    
    
    
    bool=false;
    return
    
else
    
    error('Please add more cases in circle graph obstruction.')
    
    
end







end