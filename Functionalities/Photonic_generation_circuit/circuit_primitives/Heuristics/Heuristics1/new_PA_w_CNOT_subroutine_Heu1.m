function [Tab,Circuit,graphs,flag,number_conn_comp_after]=...
    new_PA_w_CNOT_subroutine_Heu1(Adj0,Tab0,Circuit0,graphs0,Store_Graphs,...
    Store_Gates,np,ne,photon,number_of_sub_G,number_conn_comp_before,varargin)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 15, 2024
%--------------------------------------------------------------------------
%
%
%Main subroutine of Heuristics #1 Optimizer.
%
%Input: Adj0
%       Tab0: Input Stabilizer Tableau
%       Circuit0: Input circuit
%       graphs0: Input graph evolution we have so far
%       Store_Graphs: True or False to store the graph updates
%       Store_Gates: True or False to store the gate updates
%       np: # of photons
%       ne: # of emitters
%       photon: index of photon to absorb
%       number_of_sub_G: handle for finding the number of disconnected
%       components i.e., @(G) length(unique(conncomp(graph(G))))
%       number_conn_comp_before: # of disconnected components when entering
%       this script.
%
%Output: Tab: Updated stabilize Tableau
%        Circuit: Updated circuit
%        graphs: Update graphs
%        flag: true or false whether the pattern succeeded
%        number_conn_comp_after: # of disconnected components when exiting
%        this script.
%
%TODO: Make a bit more efficient the search for disconnected components
%      by applying only local gates based on the existing Paulis on the
%      given row (?), such that the subsequent CNOT creates the 2  
%      disconnected stabilizer Tableaux.

flag      = false;
n         = np+ne;
BackTab   = Back_Subs_On_RREF_Tab(Tab0,n,np); %Next calls probably should not back-substitute till row-np

%----------------- Check for weigth 2 emitter pair: -----------------------

row_indx_Stabs = Stabs_with_support_on_emitters(BackTab,np,ne);

for l=1:length(row_indx_Stabs)

    [emitters_in_X,emitters_in_Y,emitters_in_Z] = emitters_Pauli_in_row(BackTab,row_indx_Stabs(l),np,ne);
    temp_emitters                               = [emitters_in_X,emitters_in_Y,emitters_in_Z];

    if length(temp_emitters)==2  %Succeeds 100% in eliminating emitter when this is true

       em1 = temp_emitters(1);
       em2 = temp_emitters(2);

       number_conn_comp_after =  number_conn_comp_before+1;

       if isempty([emitters_in_X,emitters_in_Z]) %YY

           Tab     = Phase_Gate(Tab0,em2,n);
           Circuit = store_gate_oper(em2,'P',Circuit0,Store_Gates);
           Tab     = CNOT_Gate(Tab,[em1,em2],n);

           Circuit         = store_gate_oper([em1,em2],'CNOT',Circuit,Store_Gates);
           Circuit.EmCNOTs = Circuit.EmCNOTs+1;

            if Store_Graphs

                graphs = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',int2str(em1),',',int2str(em2),'} [DE]'),graphs0);                    

            else

                graphs=graphs0;

            end

            flag=true;

            return       

       end

       if isempty([emitters_in_Z,emitters_in_Y]) %XX

           Tab     = CNOT_Gate(Tab0,[em1,em2],n);

           Circuit         = store_gate_oper([em1,em2],'CNOT',Circuit0,Store_Gates);
           Circuit.EmCNOTs = Circuit.EmCNOTs+1;

            if Store_Graphs

                graphs = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',int2str(em1),',',int2str(em2),'} [DE]'),graphs0);                    

            else

                graphs=graphs0;

            end

            flag=true;


            return
            
       end

       if isempty([emitters_in_X,emitters_in_Y]) %ZZ

           Tab     = CNOT_Gate(Tab0,[em1,em2],n);

           Circuit         = store_gate_oper([em1,em2],'CNOT',Circuit0,Store_Gates);
           Circuit.EmCNOTs = Circuit.EmCNOTs+1;

            if Store_Graphs

                graphs = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',int2str(em1),',',int2str(em2),'} [DE]'),graphs0);                    

            else

                graphs=graphs0;

            end

            flag=true;

            return
       end

       if ~isempty(emitters_in_X) && ~isempty(emitters_in_Z)  %X_1Z_2  -> X_1 X_2   -> XI  (Had on target, then CNOT)
                                                              %em1->X, em2->Z

           Tab     = Had_Gate(Tab0,em2,n);
           Circuit = store_gate_oper(em2,'H',Circuit0,Store_Gates);
           Tab     = CNOT_Gate(Tab,[em1,em2],n);

           Circuit         = store_gate_oper([em1,em2],'CNOT',Circuit,Store_Gates);
           Circuit.EmCNOTs = Circuit.EmCNOTs+1;

            if Store_Graphs

                graphs = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',int2str(em1),',',int2str(em2),'} [DE]'),graphs0);                    

            else

                graphs=graphs0;

            end

            flag=true;

            return       

       end

       if ~isempty(emitters_in_Y) && ~isempty(emitters_in_X)  %Y_1X_2 -> CNOT -> YI
                                                              %em1->X, em2->Y
           Tab     = CNOT_Gate(Tab0,[em2,em1],n);

           Circuit         = store_gate_oper([em2,em1],'CNOT',Circuit0,Store_Gates);
           Circuit.EmCNOTs = Circuit.EmCNOTs+1;

            if Store_Graphs

                graphs = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',int2str(em1),',',int2str(em2),'} [DE]'),graphs0);                    

            else

                graphs=graphs0;

            end

            flag=true;

            return       

       end

       if ~isempty(emitters_in_Z) && ~isempty(emitters_in_Y)  %Z_1Y_2 -> CNOT -> IY
                                                              %em2->Z, em1->Y
           Tab             = CNOT_Gate(Tab0,[em2,em1],n); 
           Circuit         = store_gate_oper([em2,em1],'CNOT',Circuit0,Store_Gates);
           Circuit.EmCNOTs = Circuit.EmCNOTs+1;

            if Store_Graphs

                graphs = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',int2str(em1),',',int2str(em2),'} [DE]'),graphs0);                    

            else

                graphs=graphs0;

            end

            flag=true;

            return       

       end
       
       error('Did not consider some combination.')

    end

end

%---- Once above pattern is false enter the pattern below: ----------------


%Get all emitter pairs, of particular photonic stabilizer row & apply local 
%gates from the set {I,H,P,HP,PH,HPH,PHP} before testing CNOT_{ij} vs CNOT_{ji}.
%After checking every combination, see if we increase # of connected 
%components and select this choice as optimal.

%ID:     0,1,2,3, 4,  5,  6
%Gates={'I,H,P,HP,PH,HPH,PHP'};
%Rest choices 3 & 5  seem to not be selected. Also 6 is equivalent to 5 and we drop it. 
Gates              = combs([0,1,2,4],2);  
[potential_rows,~] = detect_Stabs_start_from_photon(Tab0,photon,n);  %Here we could choose Tab0, or BackTab
[Stabrow,~]        = detect_Stab_rows_of_minimal_weight(Tab0,potential_rows,np,n);

[emitters_in_X,emitters_in_Y,emitters_in_Z] = emitters_Pauli_in_row(Tab0,Stabrow(1),np,ne); %Ignores emitters in product state
all_emitters                                = [emitters_in_X,emitters_in_Y,emitters_in_Z];

if n>=30
    
    emitter_cutoff = round(length(all_emitters)/3);
    
else
    
    emitter_cutoff = length(all_emitters);
    
end


if isempty(varargin{1}) %Then do the search
   
    for l1=1:emitter_cutoff 

        for l2=l1+1:emitter_cutoff 

            em1 = all_emitters(l1);
            em2 = all_emitters(l2);
            
            for M=1:size(Gates,1)  %Gates={'I,H,P,HP,PH,HPH,PHP'};

                gate1 = Gates(M,1); gate2 = Gates(M,2);

                testTab = subroutine_gate_application_no_phase_upd(Tab0,em1,em2,gate1,gate2,n);
                testTab = CNOT_Gate_no_phase_upd(testTab,[em1,em2],n);

                number_conn_comp_after = number_of_sub_G(Get_Adjacency(testTab));
                
                if number_conn_comp_after>number_conn_comp_before

                    disp(['!!!!!!!!! Gate comb:',int2str(Gates(M,:))])
                    
                    flag          = true;
                    [Tab,Circuit] = subroutine_gate_application_phase_upd(Tab0,Circuit0,em1,em2,gate1,gate2,n,Store_Gates);
                    Tab           = CNOT_Gate(Tab,[em1,em2],n);

                    Circuit         = store_gate_oper([em1,em2],'CNOT',Circuit,Store_Gates);
                    Circuit.EmCNOTs = Circuit.EmCNOTs+1;

                    if Store_Graphs

                        graphs = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',int2str(em1),',',int2str(em2),'} [DE]'),graphs0);                    

                    else

                        graphs=graphs0;

                    end

                    return

                end

                %Reverse also control target
                if gate1==gate2

                    [testTab] = subroutine_gate_application_no_phase_upd(Tab0,em1,em2,gate1,gate2,n);
                    testTab   = CNOT_Gate_no_phase_upd(testTab,[em2,em1],n);

                    number_conn_comp_after = number_of_sub_G(Get_Adjacency(testTab));

                    if number_conn_comp_after>number_conn_comp_before

                        disp(['!!!!!! Gate comb:',int2str(Gates(M,:))])

                        flag          = true;
                        [Tab,Circuit] = subroutine_gate_application_phase_upd(Tab0,Circuit0,em1,em2,gate1,gate2,n,Store_Gates);
                        Tab           = CNOT_Gate(Tab,[em2,em1],n);

                        Circuit         = store_gate_oper([em2,em1],'CNOT',Circuit,Store_Gates);
                        Circuit.EmCNOTs = Circuit.EmCNOTs+1;

                        if Store_Graphs

                            graphs = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',int2str(em2),',',int2str(em1),'} [DE]'),graphs0);                    

                        else

                            graphs=graphs0;

                        end

                        return

                    end


                end


            end

        end

    end
    
elseif ~varargin{1}{1} %If false, then do not search for this pattern (or search as long as np<=cut_off)
    
    
end


if ~flag %No pattern was successful
    
   Tab                    = Tab0;
   Circuit                = Circuit0;
   graphs                 = graphs0;
   number_conn_comp_after = number_conn_comp_before;
   
end

    
end


function [testTab]=subroutine_gate_application_no_phase_upd(testTab,em1,em2,gate1,gate2,n)


if gate1==1     %H,P,HP,PH,HPH

    testTab  = Had_Gate_no_phase_upd(testTab,em1,n);

elseif gate1==2

    testTab  = Phase_Gate_no_phase_upd(testTab,em1,n);

elseif gate1==3

    testTab = Had_Gate_no_phase_upd(testTab,em1,n);
    testTab = Phase_Gate_no_phase_upd(testTab,em1,n);

elseif gate1==4

    testTab = Phase_Gate_no_phase_upd(testTab,em1,n);
    testTab = Had_Gate_no_phase_upd(testTab,em1,n);

elseif gate1==5

    testTab = Had_Gate_no_phase_upd(testTab,em1,n);
    testTab = Phase_Gate_no_phase_upd(testTab,em1,n);
    testTab = Had_Gate_no_phase_upd(testTab,em1,n);

end

if gate2==1    %H,P,HP,PH,HPH

    testTab  = Had_Gate_no_phase_upd(testTab,em2,n);

elseif gate2==2

    testTab  = Phase_Gate_no_phase_upd(testTab,em2,n);

elseif gate2==3

    testTab  = Had_Gate_no_phase_upd(testTab,em2,n);
    testTab  = Phase_Gate_no_phase_upd(testTab,em2,n);

elseif gate2==4

    testTab  = Phase_Gate_no_phase_upd(testTab,em2,n);
    testTab  = Had_Gate_no_phase_upd(testTab,em2,n);

elseif gate2==5

    testTab = Had_Gate_no_phase_upd(testTab,em2,n);
    testTab = Phase_Gate_no_phase_upd(testTab,em2,n);
    testTab = Had_Gate_no_phase_upd(testTab,em2,n);

end

end


function [testTab,testCirc]=subroutine_gate_application_phase_upd(testTab,testCirc,em1,em2,gate1,gate2,n,Store_Gates)


if gate1==1     %H,P,HP,PH,HPH

    testTab  = Had_Gate(testTab,em1,n);
    testCirc = store_gate_oper(em1,'H',testCirc,Store_Gates);

elseif gate1==2

    testTab  = Phase_Gate(testTab,em1,n);
    testCirc = store_gate_oper(em1,'P',testCirc,Store_Gates);

elseif gate1==3

    testTab = Had_Gate(testTab,em1,n);
    testTab = Phase_Gate(testTab,em1,n);

    testCirc = store_gate_oper(em1,'H',testCirc,Store_Gates);
    testCirc = store_gate_oper(em1,'P',testCirc,Store_Gates);

elseif gate1==4

    testTab = Phase_Gate(testTab,em1,n);
    testTab = Had_Gate(testTab,em1,n);

    testCirc = store_gate_oper(em1,'P',testCirc,Store_Gates);
    testCirc = store_gate_oper(em1,'H',testCirc,Store_Gates);

elseif gate1==5

    testTab = Had_Gate(testTab,em1,n);
    testTab = Phase_Gate(testTab,em1,n);
    testTab = Had_Gate(testTab,em1,n);

    testCirc = store_gate_oper(em1,'H',testCirc,Store_Gates);
    testCirc = store_gate_oper(em1,'P',testCirc,Store_Gates);
    testCirc = store_gate_oper(em1,'H',testCirc,Store_Gates);

end


if gate2==1    %H,P,HP,PH,HPH

    testTab  = Had_Gate(testTab,em2,n);
    testCirc = store_gate_oper(em2,'H',testCirc,Store_Gates);

elseif gate2==2

    testTab  = Phase_Gate(testTab,em2,n);
    testCirc = store_gate_oper(em2,'P',testCirc,Store_Gates);

elseif gate2==3

    testTab  = Had_Gate(testTab,em2,n);
    testTab  = Phase_Gate(testTab,em2,n);
    testCirc = store_gate_oper(em2,'H',testCirc,Store_Gates);
    testCirc = store_gate_oper(em2,'P',testCirc,Store_Gates);

elseif gate2==4

    testTab  = Phase_Gate(testTab,em2,n);
    testTab  = Had_Gate(testTab,em2,n);
    testCirc = store_gate_oper(em2,'P',testCirc,Store_Gates);
    testCirc = store_gate_oper(em2,'H',testCirc,Store_Gates);

elseif gate2==5

    testTab = Had_Gate(testTab,em2,n);
    testTab = Phase_Gate(testTab,em2,n);
    testTab = Had_Gate(testTab,em2,n);

    testCirc = store_gate_oper(em2,'H',testCirc,Store_Gates);
    testCirc = store_gate_oper(em2,'P',testCirc,Store_Gates);
    testCirc = store_gate_oper(em2,'H',testCirc,Store_Gates);

end


end


function [Stab_row_indx,indx] = detect_Stab_rows_of_minimal_weight(Tab,potential_rows,np,n)

ne               = n-np;
Lp               = length(potential_rows);
weight           = zeros(1,Lp);
emitters_per_row = cell(1,Lp);

for ll=1:Lp

    row = potential_rows(ll);
    
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