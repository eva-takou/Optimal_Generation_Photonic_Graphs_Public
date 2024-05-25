function [m,bool_obstruction]=second_pass_is_circle(m,gi,non_shift_nodes,Pseq)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 24, 2024
%--------------------------------------------------------------------------
%
%In the second pass, we start from g5 and try to match g6 by inserting an
%alternace in the word of g5. We continue this bottom-up construction till
%we reach gn. If at some step we cannot satisfy the alternances, then it
%holds that the input graph gn was not a circle graph. The subgraphs
%of a circle graph have to be circle graphrs themselves.
%
%Input: m: the alternance word for g5
%       gi: a cell of the graphs starting from gn -> all the way to g5
%       non_shifted_nodes: the node we removed from gi, with labeling
%       according to gi 
%       Pseq: A cell of cells, which contains the info on which operation
%       we did before removal of node v_i from g_i.
%
%Output: m: the alternance word
%        bool_obstruction: true or false to indicate that potential we
%        reached a circle graph obstruction because we failed to match the
%        alternances

Lg = length(gi);

for ii=Lg-1:-1:1 %start processing from g6 -> g7 and so on
   
    %it holds that g_i = (g_{i+1}*p_{i+1})\v_{i+1}
    
    A       = gi{ii}; %g_{i+1}
    v       = non_shift_nodes{ii}; %v_{i+1}
    m(m>=v) = m(m>=v)+1; %re-store labeling of word of g_{i} to labeling in g_{i+1}
    p       = Pseq{ii}; %p_{i+1}

    if ~isempty(p{1})
        
        for jj=1:length(p)

            q = p{jj};
            A = Local_Complement(A,q); %g_{i+1}*p_{i+1}

        end
    
    end
    
    %Insert 2 occurences of v_{i+1}, st in the word of m(g_i) we 
    %respect the alternances between v_{i+1} and N(v_{i+1}) in g_{i+1}.
    
    Nv       = Get_Neighborhood(A,v); 
    degv     = length(Nv);
    
    if degv==1 
       
        v_in_m = any(m==v);  %ismember(v,m); 
        w_in_m = any(m==Nv); %ismember(Nv,m);
        
        if v_in_m
            
            error('v should not exist yet in the word.')
            
        end
        
        if ~w_in_m
           
            error('If the neighbor of v did not exist in the word then we would not have prime graph.')
            
        end
        
        locs   = find(m==Nv);
        prev_m = m(1:locs(2)-1);
        afte_m = m(locs(2)+1:end);
        m      = [prev_m,v,Nv,v,afte_m];
            
%         if ~is_correct_word_for_Adj(A,m)
%            error('we failed.') 
%         end
        
    else %Try all possible insertions of v into m, st alternances satisfy connections in A
        
        [m,success_flag] = place_alternance_randomly(m,A,v,Nv);
        
        if ~success_flag %We failed so we exit (encountered obstruction)
            
            bool_obstruction=true;
            m=[];
            
            return
                  
        end
        
    end
    
    m = transform_word_LC(m,p); %Re-apply the operation to transform the alternance word
    
end

bool_obstruction=false; %if we didnt return above, then we succeded.

end