function [TabOut,CircuitOut,graphsOut]=...
    photon_absorption_W_CNOT_Opt(Tab,np,ne,photon,Circuit,graphs,...
                                 Store_Graphs,Store_Gates,try_LC,LC_Rounds)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 27, 2024
%--------------------------------------------------------------------------
%
%Script to inspect several degrees of freedom before performing PA on a
%photon where we require emitter-emitter CNOTs upfront.
%This script explores:
%1) which emitter to free-up for the photon absorption
%2) row operations
%3) intermediate LC operations
%
%Input: Tab: The tableau
%       np: # of photons
%       ne: # of emitters
%       photon: index of photon to be absorbed \in [1,np]
%       Circuit: The circuit we have so far
%       graphs: The graphs we have so far corresponding to each step of the
%       circuit
%       Store_Graphs: true or false (to store the graph evolution)
%       Store_Gates: true or false to store the circuit updates
%       try_LC: true or false to attempt LCs before photon absorption
%       LC_Rounds: How many LC rounds to apply on distinct nodes (allowing
%       repetitions)
%Output: TabOut: All realizations of new Tableaus after photon absorption
%        CircuitOut: All new circuits
%        graphsOut: All new graphs

fixedTab     = Tab;
fixedCircuit = Circuit;
fixedGraphs  = graphs;

n = np+ne;

%-Get the rows where the Pauli starts from the photon to be absorbed.
%-Get also operators where we have support solely on emitters.
%not_absorbed_photons = 1:photon;
[row_ids_photon,photon_flag_Gate] = detect_Stabs_start_from_photon(fixedTab,photon,n);


%-Check all emitter choices w/o allowing row multiplications.--------------

cnt = 0;

for ll=1:length(row_ids_photon)
   
   newTab                                      = fixedTab;
   Circuit                                     = fixedCircuit;
   graphs                                      = fixedGraphs;
   
   [emitters_in_X,emitters_in_Y,emitters_in_Z] = emitters_Pauli_in_row(newTab,row_ids_photon(ll),np,ne);
   possible_emitters                           = [emitters_in_X,emitters_in_Y,emitters_in_Z];
    
    %-------- Bring all emitters in Z for the particular row: -------------
    
    [newTab,Circuit]=put_emitters_in_Z(n,newTab,Circuit,emitters_in_X,emitters_in_Y,Store_Gates);
    
    %---------- Loop through all cases of choosing emitters ---------------
    
    for mm=1:length(possible_emitters)
        
        thisTab        = newTab;
        thisCirc       = Circuit;
        thesegraphs    = graphs;
        emitter        = possible_emitters(mm);
        other_emitters = possible_emitters;
        other_emitters(mm) = [];
        
        [thisTab,thisCirc,thesegraphs]=free_emitter_for_PA(n,thisTab,thisCirc,thesegraphs,Store_Graphs,emitter,other_emitters,Store_Gates);
        
        photon_Gate = photon_flag_Gate{ll};
        emitter_flag_Gate='Z';
        
        [thisTab,thisCirc,thesegraphs]=PA_subroutine(n,thisTab,thisCirc,thesegraphs,photon,emitter,emitter_flag_Gate,photon_Gate,Store_Graphs,Store_Gates);
        
        cnt                  = cnt+1;
        TabOut{cnt}          = thisTab;
        CircuitOut{cnt}      = thisCirc;
        graphsOut{cnt}       = thesegraphs;       
        
    end
    
end


%--------------------------------------------------------------------------
%              Allow LC operations and repeat the same:  
%--------------------------------------------------------------------------
if try_LC
    
    [newTab,newCirc,newGraphs]=LC_and_PA_subroutine(fixedTab,fixedCircuit,fixedGraphs,n,np,ne,photon,Store_Graphs,Store_Gates,LC_Rounds);
    
    TabOut          = [TabOut,newTab];
    CircuitOut      = [CircuitOut,newCirc];
    graphsOut       = [graphsOut,newGraphs];
    
end

%--------------------------------------------------------------------------
%           Allow row multiplications and repeat the same.
%--------------------------------------------------------------------------

all_rows = row_ids_photon; %Stabilizer rows of photon (max 2)

if length(all_rows)==1
    return
end

for j1=1:length(all_rows)
    
    row1 = all_rows(j1);
    
    for j2=1:length(all_rows)
        
        if j1~=j2 
            
            row2        = all_rows(j2);
            graphs      = fixedGraphs;
            newfixedTab = update_Tab_rowsum(fixedTab,n,row1,row2);
            
            %Now, find again the photon state, the emitters state, and loop over all choices.
            [row_ids_photon,photon_flag_Gate] = detect_Stabs_start_from_photon(newfixedTab,photon,n);
            
            INDX = row1==row_ids_photon;
            
            newTab=newfixedTab;

            [emitters_in_X,emitters_in_Y,emitters_in_Z] = emitters_Pauli_in_row(newTab,row1,np,ne); %row_ids_photon(ll)
            possible_emitters                           = [emitters_in_X,emitters_in_Y,emitters_in_Z];

            %---Put emitters in Z.------------------------------------
            [newTab,Circuit]=put_emitters_in_Z(n,newTab,fixedCircuit,emitters_in_X,emitters_in_Y,Store_Gates);
                
            for mm=1:length(possible_emitters)

                thisTab        = newTab;
                thisCirc       = Circuit;
                thesegraphs    = graphs;
                emitter        = possible_emitters(mm);

                other_emitters = possible_emitters;
                other_emitters(mm) = [];

                [thisTab,thisCirc,thesegraphs]=free_emitter_for_PA(n,thisTab,thisCirc,thesegraphs,Store_Graphs,emitter,other_emitters,Store_Gates);                    

                %------ Bring the photon into Z -----------------------------------

                photon_Gate = photon_flag_Gate{INDX}; 

                emitter_flag_Gate='Z';

                [thisTab,thisCirc,thesegraphs]=PA_subroutine(n,thisTab,thisCirc,thesegraphs,photon,emitter,emitter_flag_Gate,photon_Gate,Store_Graphs,Store_Gates);

                cnt                  = cnt+1;
                TabOut{cnt}          = thisTab;
                CircuitOut{cnt}      = thisCirc;
                graphsOut{cnt}       = thesegraphs;       

            end
            
        end
        
    end
    
end


end