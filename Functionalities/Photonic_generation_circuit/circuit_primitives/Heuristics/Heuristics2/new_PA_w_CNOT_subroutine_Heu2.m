function [Tab,Circuit,graphs,flag,number_conn_comp_after]=...
    new_PA_w_CNOT_subroutine_Heu2(Adj0,Tab0,Circuit0,graphs0,Store_Graphs,...
    Store_Gates,np,ne,photon,number_of_sub_G,number_conn_comp_before,...
    emitter_cutoff0,varargin)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 15, 2024
%
%
%Main subroutine of Heuristics #2 Optimizer.
%
%Input: Adj0: Input graph of current step
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
%       emitter_cutoff0: upper bound on # of emitters to inspect for the
%       photonic stabilizer row.
%
%Output: Tab: Updated stabilize Tableau
%        Circuit: Updated circuit
%        graphs: Update graphs
%        flag: true or false whether the pattern succeeded
%        number_conn_comp_after: # of disconnected components when exiting
%        this script.



flag    = false;
n       = np+ne;
BackTab = Back_Subs_On_RREF_Tab(Tab0,n,np);

%------------------- Check for weigth 2 emitter stab: ---------------------
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

           Tab     = Had_Gate(Tab0,em2,n);
           Circuit = store_gate_oper(em2,'H',Circuit0,Store_Gates);
           Tab     = CNOT_Gate(Tab,[em1,em2],n);

           Circuit         = store_gate_oper([em1,em2],'CNOT',Circuit,Store_Gates);
           Circuit.EmCNOTs = Circuit.EmCNOTs+1;

           
%            if ~qubit_in_product(Tab,n,em1) && ~qubit_in_product(Tab,n,em2)
%               error('Check again') 
%            end           
            if Store_Graphs

                graphs = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',int2str(em1),',',int2str(em2),'} [DE]'),graphs0);                    

            else

                graphs=graphs0;

            end

            flag=true;

            return       




       end

       if ~isempty(emitters_in_Y) && ~isempty(emitters_in_X)  %Y_1X_2 -> CNOT -> YI

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

       error('Did not consider some combination.')

    end

end

%---------- Enter search for disconnected components ----------------------

%Get all emitter pairs, of particular photonic stabilizer row
%and apply local gates from the set {I,H,P,HP,PH,HPH,PHP}
%before testing CNOT_{ij} and CNOT_{ji}.
%After checking every combination, see if we increase # of connected
%components and select this choice as optimal.
%ID: 0,1,2,3,4,5,6
%Gates={'I,H,P,HP,PH,HPH,PHP'};
Gates=combs([0,1,2,4],2); %Rest choices (3,5) seem to not be selected. Also 6 is equivalent to 5 and we drop it. 

% if photon<np/2
% 
%     Tab = Tab0;
%     Circuit=Circuit0;
%     graphs=graphs0;
%     flag=false;
%     return
%     
% end

if isempty(varargin{1})
   
    [potential_rows,~] = detect_Stabs_start_from_photon(Tab0,photon,n);
    [~,~,emitters_in_X,emitters_in_Y,emitters_in_Z] = detect_Stab_rows_of_minimal_weight(Tab0,potential_rows,np,n);

    %[emitters_in_X,emitters_in_Y,emitters_in_Z]=emitters_Pauli_in_row(Tab0,Stabrow(1),np,ne); %Ignores emitters in product state
    all_emitters=[emitters_in_X,emitters_in_Y,emitters_in_Z];


    %----------- Can make various choices here --------------------------------

    emitter_cutoff = min([length(all_emitters),emitter_cutoff0]);
    
    
    for l1=1:emitter_cutoff 

        for l2=l1+1:emitter_cutoff 

            em1 = all_emitters(l1);
            em2 = all_emitters(l2);

            for M=1:size(Gates,1)

                gate1 = Gates(M,1);
                gate2 = Gates(M,2);

                
                [testTab]=subroutine_gate_application_no_phase_upd(Tab0,em1,em2,gate1,gate2,n);

                testTab = CNOT_Gate_no_phase_upd(testTab,[em1,em2],n);

                number_conn_comp_after = number_of_sub_G(Get_Adjacency(testTab));

                
                
                if number_conn_comp_after>number_conn_comp_before

                    
                    disp(['!!! Gate comb:',int2str(Gates(M,:))])
                    
                    flag    = true;

                    [testTab,testCirc]=subroutine_gate_application_phase_upd(Tab0,Circuit0,em1,em2,gate1,gate2,n,Store_Gates);
                    testTab = CNOT_Gate(testTab,[em1,em2],n);

                    Tab     = testTab;
                    Circuit = store_gate_oper([em1,em2],'CNOT',testCirc,Store_Gates);

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

                    [testTab]=subroutine_gate_application_no_phase_upd(Tab0,em1,em2,gate1,gate2,n);
                    %[testTab,testCirc]=subroutine_gate_application(Tab0,Circuit0,em1,em2,gate1,gate2,n,Store_Gates);

                    testTab = CNOT_Gate_no_phase_upd(testTab,[em2,em1],n);

                    number_conn_comp_after = number_of_sub_G(Get_Adjacency(testTab));

                    if number_conn_comp_after>number_conn_comp_before

                        disp('!!!!!!!!!!!!!')
                        disp(['Gate comb:',int2str(Gates(M,:))])
                        disp('!!!!!!!!!!!!!')
                        flag    = true;

                        [testTab,testCirc]=subroutine_gate_application_phase_upd(Tab0,Circuit0,em1,em2,gate1,gate2,n,Store_Gates);
                        testTab = CNOT_Gate(testTab,[em2,em1],n);

                        Tab     = testTab;
                        Circuit = store_gate_oper([em2,em1],'CNOT',testCirc,Store_Gates);

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
    
    
else %Skip this search for efficiency (or perform the search only if np<=cutoff)
    
    
    
end






if ~flag
    
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

function [Stab_row_indx,indx,em_X,em_Y,em_Z] = detect_Stab_rows_of_minimal_weight(Tab,potential_rows,np,n)

ne               = n-np;
Lp               = length(potential_rows);
weight           = zeros(1,Lp);
%emitters_per_row = cell(1,Lp);
em_X             = cell(1,Lp);
em_Y             = cell(1,Lp);
em_Z             = cell(1,Lp);

for ll=1:Lp

    row = potential_rows(ll);
    
    [emitters_in_X,emitters_in_Y,emitters_in_Z] = emitters_Pauli_in_row(Tab,row,np,ne);
    weight(ll)           = length([emitters_in_X,emitters_in_Y,emitters_in_Z]);
    %emitters_per_row{ll} = [emitters_in_X,emitters_in_Y,emitters_in_Z];
    em_X{ll} = emitters_in_X;
    em_Y{ll} = emitters_in_Y;
    em_Z{ll} = emitters_in_Z;
    
    
end

if min(weight)==0
   error('Error in photonic absorption. Found stab with support on target photon, but no support on any emitter.') 
end

[~,indx]      = min(weight);
em_X          = em_X{indx};
em_Y          = em_Y{indx};
em_Z          = em_Z{indx};
Stab_row_indx = potential_rows(indx);

end
