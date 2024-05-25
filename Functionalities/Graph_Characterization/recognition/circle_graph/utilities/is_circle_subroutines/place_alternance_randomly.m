function [mnew,success_flag] = place_alternance_randomly(m,A,v,Nv)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 24, 2024
%--------------------------------------------------------------------------
%
%Check if we can add alternances of node v in a pre-existing word m, such
%that we satisfy that in m, v connects with Nv, as dictated by the
%adjacency matrix.
%
%Input: m: Alternance word without v
%       A: Adjacency matrix
%       v: node of adjacency matrix we want to add in m
%       Nv: neighborhood of v in A
%Ouput: mnew: The new alternance word if we succeeded (empty otherwise)
%       success_flag: true or false for whether the process succeeded or not

mfixed       = m;
L_m_extended = length(m)+2; 
random_locs  = nchoosek(1:L_m_extended,2);  %All possible combinations of 2 positions in the extended word m 
other_nodes  = setxor(1:length(A),[Nv',v]); %Nodes besides Nv and v.
degv         = length(Nv);                  %degree of node v

for jj = 1:size(random_locs,1)

    mnew = m;
    locs = random_locs(jj,:);
    mnew = insert_occurences_v(mnew,v,locs);

    exists_wrong_alternance = false;
    flag_found_alternance   = false(1,degv);

    %First: Make sure that we did not introduce an alternance between v and
    %nodes not in Nv

    for k=1:length(other_nodes)

        u = other_nodes(k);
        
        if exists_v1v2_alternance(u,v,mnew) && A(u,v)==0 

            exists_wrong_alternance = true;
            break

        end

    end          
    
    if exists_wrong_alternance
        continue
    end
    
    %Second: Check if we created an alternance wv for each w\in Nv 
    for k=1:degv

        if exists_v1v2_alternance(Nv(k),v,mnew)

            flag_found_alternance(k)=true; 
            
        else
            break
        end

    end

    if all(flag_found_alternance) 
            
        success_flag = true;
        return 
            
    end

end

success_flag = false;
mnew         = mfixed; %do not change the word if we failed.

end
