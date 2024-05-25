function [bool,m]=is_circleG_subroutine(Adj)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 24, 2024
%--------------------------------------------------------------------------
%
%Subroutine for circle graph recognition, based on Bouchet. This is applied
%on an input graph that is prime.
%
%Input:   Adj: Adjacency matrix
%Output: bool: true or false
%           m: alterance word if bool is true. empty if bool is false.

[bool_split_free,~,~]=is_split_free_brute(Adj,false);

if ~bool_split_free
    
    error('The subroutine of is_circleG requires a split-free graph.')
    
end

if length(Adj)>=5

    [gi,non_shift_nodes,Pseq] = first_pass_is_circle(Adj);
    m                         = construct_word_g5(gi{end});
    [m,bool_obstruction]      = second_pass_is_circle(m,gi,non_shift_nodes,Pseq);

    if ~bool_obstruction

        if is_correct_word_for_Adj(Adj,m)

            bool=true;

        else

            error('Did not produce the correct word.')

        end

    else

        bool=false;

    end

elseif length(Adj)==4 %there is no split-free graph of 4 nodes.
    
    error('Input graph is not split-free.')
    
elseif length(Adj)==3
    
    %Is it a K3?
    Adj_test=create_Kn(3,'Adjacency');
    
    if all(all(Adj==Adj_test))
        
        m    = [1:3,1:3];
        bool = true;
        return
    end
    
    %Is it a P3?
    Adj_test = create_Pn(3,'Adjacency');
    p3       = perms(1:3);
    P0       = eye(3);
    
    for jj=1:size(p3,1)
        
       P        = P0;
       P(:,1:3) = P(:,p3(jj,:));
        
       if all(all(P*Adj*P'==Adj_test))
           
           m    = double_occurrence_Pn(3,p3(jj,:),false);
           bool = true;
           return
           
           
       end
        
    end
    
    error('Check again the subroutine.')
    
elseif length(Adj)==2 %Only 1 option
    
    m    = [1,2,1,2];
    bool = true;
    return
    
end

end