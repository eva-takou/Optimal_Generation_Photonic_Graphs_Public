function [Tab,Circuit,graphs,success_flag]=new_PA_w_CNOT_Heu1(Tab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates,return_cond,varargin)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 15, 2024
%--------------------------------------------------------------------------
%
%Function to perform the photon's absorption with emitter-emitter CNOTs
%upfront, using the Heuristics #1 Optimizer.
%
%Input: Tab: Stabilizer Tableau
%       np: # of photons
%       ne: # of emitters
%       photon: index of photon to absorb
%       Circuit: The circuit we have so far
%       graphs: The graphs we have so far
%       Store_Graphs: True or False to store the graph evolution after
%       two-qubit gates
%       Store_Gates: True or False to store the gate updates
%       return_cond: False to exhaust all conditions for free PA
%                    True for early exit for free PA
%
%Output: Tab: Stabilizer Tableau
%        Circuit: Updated Circuit
%        graphs: Updated graphs
%        success_flag: Always true since we absorb the photon



[Tab,Circuit,graphs,success_flag]=attempt_emitter_disentanglement(Tab,Circuit,graphs,Store_Graphs,Store_Gates,np,ne,photon,return_cond,varargin{1});

if success_flag
    
    return

end

end




function [Tab,Circuit,graphs,success_flag]=attempt_emitter_disentanglement(Tab0,Circuit0,graphs0,Store_Graphs,Store_Gates,np,ne,photon,return_cond,varargin)

n                       = np+ne;
number_of_sub_G         = @(G) length(unique(conncomp(graph(G))));
Adj0                    = Get_Adjacency(Tab0);
number_conn_comp_before = number_of_sub_G(Adj0);

while true
 
   [Tab0,Circuit0,graphs0,flag,number_conn_comp_after] = ...
       new_PA_w_CNOT_subroutine_Heu1(Adj0,Tab0,Circuit0,graphs0,Store_Graphs,Store_Gates,...
       np,ne,photon,number_of_sub_G,number_conn_comp_before,varargin{1});
   
   number_conn_comp_before=number_conn_comp_after;
   
   if ~flag
       break
   end

end

[Tab0,Circuit0,graphs0,discovered_emitter,~]=photon_absorption_WO_CNOT(Tab0,np,ne,photon,Circuit0,graphs0,Store_Graphs,Store_Gates,return_cond);

if discovered_emitter
    
    %warning('SUCCESS ID:1 AFTER HEURISTICS---Brute_Force_All_Local_Gates')
    
    Tab          = Tab0;
    Circuit      = Circuit0;
    graphs       = graphs0;
    success_flag = true;
    return
    
end


%------ Check if we can now do PA w/o CNOT --------------------------------
[Tab0,Circuit0,graphs0,discovered_emitter,~]=photon_absorption_WO_CNOT(Tab0,np,ne,photon,Circuit0,graphs0,Store_Graphs,Store_Gates,return_cond);

if discovered_emitter
    
    %warning('SUCCESS ID:1 AFTER HEURISTICS---Brute_Force_All_Local_Gates')
    
    %This can still succeed because we have an update based on Back-subs
    %inside the photon_absorption_WO_CNOT (although we call the same thing
    %twice).
    
    Tab          = Tab0;
    Circuit      = Circuit0;
    graphs       = graphs0;
    success_flag = true;
    return
    
else %We failed so we proceed with edge minimization after emitter-emitter CNOTs
    
    [potential_rows,photon_flag_Gate]             = detect_Stabs_start_from_photon(Tab0,photon,n);
    [row_id,indx]                                 = detect_Stab_rows_of_minimal_weight(Tab0,potential_rows,np,n);
    [emitters_in_X,emitters_in_Y,emitters_in_Z]   = emitters_Pauli_in_row(Tab0,row_id,np,ne);            
    all_emitters                                  = [emitters_in_X,emitters_in_Y,emitters_in_Z];
    
    if length(all_emitters)==1
       
        error('For some reason there was only 1 emitter.')
        
    end
    
    [Tab,Circuit] = put_emitters_in_Z(n,Tab0,Circuit0,emitters_in_X,emitters_in_Y,Store_Gates);
    
    %Pick emitter such that after the emitter CNOTs we have
    %fewer edges.
    
    edges=zeros(1,length(all_emitters));
        
    for l=1:length(all_emitters)

        testTab     = Tab;        
        emitter     = all_emitters(l);
        emitters    = all_emitters;
        emitters(l) = [];

        for m=1:length(emitters)

            testTab = CNOT_Gate_no_phase_upd(testTab,[emitters(m),emitter],n);

        end

        %I think we can skip the photon's local gates below.
        switch photon_flag_Gate{indx}

            case 'X'
                testTab = Had_Gate_no_phase_upd(testTab,photon,n);
            case 'Y'
                testTab = Phase_Gate_no_phase_upd(testTab,photon,n);
                testTab = Had_Gate_no_phase_upd(testTab,photon,n);
        end

        A        = Get_Adjacency(testTab);
        edges(l) = nnz(A)/2;

    end
        
    [~,Best_INDX]       = min(edges);
    emitter             = all_emitters(Best_INDX);
    emitters            = all_emitters;
    emitters(Best_INDX) = [];

    [Tab,Circuit,graphs] = free_emitter_for_PA(n,Tab,Circuit,graphs0,Store_Graphs,emitter,emitters,Store_Gates);
    [Tab,Circuit,graphs] = PA_subroutine(n,Tab,Circuit,graphs,photon,emitter,'Z',photon_flag_Gate{indx},Store_Graphs,Store_Gates);        
    success_flag=true;
    
    return
    
end


end


function [Stab_row_indx,indx] = detect_Stab_rows_of_minimal_weight(Tab,potential_rows,np,n)

ne               = n-np;
Lp               = length(potential_rows);
weight           = zeros(1,Lp);
emitters_per_row = cell(1,Lp);

for ll=1:Lp

    row                                         = potential_rows(ll);
    [emitters_in_X,emitters_in_Y,emitters_in_Z] = emitters_Pauli_in_row(Tab,row,np,ne);
    weight(ll)           = length([emitters_in_X,emitters_in_Y,emitters_in_Z]);
    emitters_per_row{ll} = [emitters_in_X,emitters_in_Y,emitters_in_Z];
    
end

if min(weight)==0
   error('Error in photonic absorption. Found stab with support on target photon, but no support on any emitter.') 
end

[~,indx]      = min(weight);
Stab_row_indx = potential_rows(indx);

end


