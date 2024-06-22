function Adj6_Orbits=Generate_n6_orbits
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 22, 2024
%--------------------------------------------------------------------------
%
%Script to obtain one representative graph for each orbit of n=6 graphs.
%
%Output: Adj6_Orbits: Cell array that contains all 312 nxn non-LC
%        equivalent adjacencies (including isomorphic) of order n=6.

n                   = 6;
discard_isomorphism = false;
Adj6                = all_adjacencies(n,discard_isomorphism);
to_remove           = [];


%Check for LC equivalence
disp('Discarding based on LC check...')
parfor k1=1:length(Adj6)
    
    G1 = Adj6{k1};
    
    for k2=k1+1:length(Adj6)

        G2         = Adj6{k2};
        [~,flag,~] = LC_check(G1,G2);
        
        if flag
            
            to_remove=[to_remove,k2];
            
            break
            
        end
        
        
    end
end

disp('Done')
Adj6_Orbits            = Adj6;
Adj6_Orbits(to_remove) = [];



end