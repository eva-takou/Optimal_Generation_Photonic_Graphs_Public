function [Tab,Circuit,graphs,success_flag]=new_PA_w_CNOT_Heu2...
    (Tab,np,ne,photon,Circuit,graphs,Store_Graphs,Store_Gates,...
     EXTRA_OPT_LEVEL,return_cond,emitter_cutoff0,future_step,...
     recurse_further,BackSubs,varargin)
 
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 15, 2024
%
%Function to perform photon absorption with emitter-emitter CNOTs upfront
%using the Heuristics #2 Optimizer.
%
%Input: Tab: Input stabilizer Tableau
%       np: # of photons
%       ne: # of emitters
%       photon: Index of photon to absorb
%       Circuit: The circuit we have so far
%       graphs: The graphs we have so far
%       Store_Graphs: true or false to store graph evolution after
%       two-qubit gates
%       Store_Gates: true or false to store the gate updates
%       EXTRA_OPT_LEVEL: true or false to enter extra optimization of
%       looping emitter choices
%       return_cond: true for early exit in free PA, false for exhaustive
%       search in free PA
%       emitter_cutoff: upper bound on emitters to inspect
%       future_step: # of subsequent future photon absorption to attempt
%       (recursions)
%       recurse_further: true or false to enable recursions
%       Back_Subs: true or false to enable back-substitution on the
%       stabilizer tableau
%
%Output: Tab: The updated stabilizer Tableau
%        Circuit: The updated circuit
%        graphs: The update graphs
%        success_flag: Always successful because we make some choice and 
%                      absorb the photon

[Tab,Circuit,graphs,success_flag]=attempt_emitter_disentanglement...
    (Tab,Circuit,graphs,Store_Graphs,Store_Gates,...
     np,ne,photon,EXTRA_OPT_LEVEL,return_cond,...
     emitter_cutoff0,future_step,recurse_further,BackSubs,varargin{1});

if success_flag
    
    return

end

end


function [Tab,Circuit,graphs,success_flag]=attempt_emitter_disentanglement...
           (Tab0,Circuit0,graphs0,Store_Graphs,Store_Gates,np,ne,photon,...
            EXTRA_OPT_LEVEL,return_cond,emitter_cutoff0,future_step,...
            recurse_further,BackSubs,varargin)


n                       = np+ne;
number_of_sub_G         = @(G) length(unique(conncomp(graph(G))));
Adj0                    = Get_Adjacency(Tab0);
number_conn_comp_before = number_of_sub_G(Adj0);

while true
 
   [Tab0,Circuit0,graphs0,flag,number_conn_comp_after] = ...
       new_PA_w_CNOT_subroutine_Heu2(Adj0,Tab0,Circuit0,graphs0,Store_Graphs,Store_Gates,...
       np,ne,photon,number_of_sub_G,number_conn_comp_before,emitter_cutoff0,varargin{1});
   
   number_conn_comp_before=number_conn_comp_after;
   
   if ~flag
       break
   end

end

%------ Check if we can now do PA w/o CNOT --------------------------------
[Tab0,Circuit0,graphs0,discovered_emitter,~]=photon_absorption_WO_CNOT(Tab0,np,ne,photon,Circuit0,graphs0,Store_Graphs,Store_Gates,return_cond);

if discovered_emitter
    
    warning('SUCCESS ID:1 AFTER HEURISTICS---Brute_Force_All_Local_Gates')
    
    Tab=Tab0;
    Circuit=Circuit0;
    graphs=graphs0;
    success_flag=true;
    return
end

%---------- Enter new optimization level ----------------------------------
    
[potential_rows,photon_flag_Gate]           = detect_Stabs_start_from_photon(Tab0,photon,n);
[row_id,indx]                               = detect_Stab_rows_of_minimal_weight(Tab0,potential_rows,np,n);
[emitters_in_X,emitters_in_Y,emitters_in_Z] = emitters_Pauli_in_row(Tab0,row_id,np,ne);    
        
all_emitters=[emitters_in_X,emitters_in_Y,emitters_in_Z];
    
if length(all_emitters)==1

    error('For some reason there was only 1 emitter.')

end

[Tab,Circuit] = put_emitters_in_Z(n,Tab0,Circuit0,emitters_in_X,emitters_in_Y,Store_Gates);

if EXTRA_OPT_LEVEL

    emitter_cutoff=min([length(all_emitters),emitter_cutoff0]);

    for l=1:emitter_cutoff  %Loop emitter choices

        emitter     = all_emitters(l);  
        emitters    = all_emitters;
        emitters(l) = [];  %emitters = setdiff(all_emitters,emitter);
        

        [testTab,testCirc,~] = free_emitter_for_PA(n,Tab,Circuit,graphs0,Store_Graphs,emitter,emitters,Store_Gates);
        CNOT_CNT             = testCirc.EmCNOTs;

        [workingTab,~,~]     = PA_subroutine(n,testTab,testCirc,graphs0,photon,emitter,'Z',photon_flag_Gate{indx},Store_Graphs,Store_Gates);

        Circ   = [];  %Start an empty circuit: will test future part of the circuit
        GG     = graphs0;

        future_cutoff = photon-future_step; %Future photon absorptions

        if future_cutoff<=1

            FLAG_Absorbed_All = true; 
            future_cutoff     = 2; 

        else

            FLAG_Absorbed_All = false;

        end

        for jj = photon:-1:future_cutoff

            next_photon = jj-1;
            workingTab  = RREF(workingTab,n);
            h           = height_function(workingTab,n,true,jj);
            dh          = h(jj)-h(jj-1); 

            if dh<0 %Need TRM--cannot absorb photon yet.

                [workingTab,Circ,GG]=time_reversed_measurement(workingTab,np,ne,next_photon,Circ,GG,Store_Graphs,Store_Gates);

            end

            [workingTab,Circ,GG,discovered_emitter,~]=photon_absorption_WO_CNOT(workingTab,np,ne,next_photon,Circ,GG,Store_Graphs,Store_Gates,return_cond);

            if ~discovered_emitter

                if recurse_further && jj>=(np/2)
                    TEMP=true;
                else
                    TEMP=false;  
                end
                
                [workingTab,Circ,GG]=new_PA_w_CNOT_Heu2(workingTab,np,ne,...
                    next_photon,Circ,GG,Store_Graphs,Store_Gates,TEMP,...
                    return_cond,emitter_cutoff0,future_step,recurse_further,...
                    BackSubs,varargin{1});

            end

            if photon==1 || jj==future_cutoff 

                break

            end

        end
        
        %-------- Collect CNOT counts -------------------------------------
        if FLAG_Absorbed_All

            [~,Circ,~] = disentangle_all_emitters(workingTab,np,ne,Circ,GG,Store_Graphs,Store_Gates,BackSubs);
            CNOTs(l)   = CNOT_CNT + Circ.EmCNOTs;

        else

             if isempty(Circ)
                 CNOTs(l) = CNOT_CNT;
             else
                 CNOTs(l) = CNOT_CNT + Circ.EmCNOTs;
             end
             
        end

    end

    %-------- Make emitter choice -----------------------------------------
    [~,CNOT_INDX] = min(CNOTs);

    emitter  = all_emitters(CNOT_INDX);
    emitters = all_emitters;
    emitters(CNOT_INDX)=[];
    
else

    edges=zeros(1,length(all_emitters));

    for l=1:length(all_emitters)

        emitter     = all_emitters(l);
        emitters    = all_emitters;
        emitters(l) = [];

        testTab    = Tab;

        for m=1:length(emitters)

            testTab = CNOT_Gate_no_phase_upd(testTab,[emitters(m),emitter],n);

        end

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

end

[Tab,Circuit,graphs] = free_emitter_for_PA(n,Tab,Circuit,graphs0,Store_Graphs,emitter,emitters,Store_Gates);
[Tab,Circuit,graphs] = PA_subroutine(n,Tab,Circuit,graphs,photon,emitter,'Z',photon_flag_Gate{indx},Store_Graphs,Store_Gates);

success_flag=true;
return
    
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


