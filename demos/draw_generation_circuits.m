% Draw the photonic generation circuit

clear; close all; clc;

np       = 14;
Adj      = create_random_graph(np);
ordering = 1:np;

Store_Graphs    = false;
Store_Gates     = true;
BackSubsOption  = false;
Verify_Circuit  = false;
return_cond     = true;



%----- Naive optimizer ---------------------------------------------------
obj = Tableau_Class(Adj,'Adjacency');
obj = obj.Generation_Circuit(ordering,Store_Graphs,Store_Gates,BackSubsOption,...
                             Verify_Circuit,return_cond);
obj         = obj.Count_emitter_CNOTs;
CNOTs_Naive = obj.Emitter_CNOT_count;
ne  = obj.Emitters;                         
                         
Circ_Naive   = obj.Photonic_Generation_Gate_Sequence;                         
Circ_Naive   = put_circuit_forward_order(Circ_Naive);
CircuitOrder = 'forward';
Circ_Naive   = fix_potential_phases_forward_circuit(Circ_Naive,Adj,ne,CircuitOrder);


%----- Heur 1 ---------------------------------------------------
BackSubsOption = true;
return_cond    = false;

obj = Tableau_Class(Adj,'Adjacency');
obj = obj.Generation_Circuit_Heu1(ordering,Store_Graphs,Store_Gates,BackSubsOption,...
                                      Verify_Circuit,return_cond);
                                  
obj        = obj.Count_emitter_CNOTs;
CNOTs_Heu1 = obj.Emitter_CNOT_count;
                                  
                                  
Circ_Heu1    = obj.Photonic_Generation_Gate_Sequence;
Circ_Heu1    = put_circuit_forward_order(Circ_Heu1);
CircuitOrder = 'forward';
Circ_Heu1    = fix_potential_phases_forward_circuit(Circ_Heu1,Adj,ne,CircuitOrder);


%------ Options for the simplification rules ----------------------------
ConvertToCZ         = false;
pass_X_photons      = true;
pass_emitter_Paulis = false;
Init_State_Option   = '0';
monitor_update      = false;
pause_time          = 0.001;
fignum              = 1;

Circ_Naive   = Simplify_Circuit(Circ_Naive,np,ne,CircuitOrder,...
                                ConvertToCZ,pass_X_photons,pass_emitter_Paulis,...
                                Init_State_Option,monitor_update,pause_time,fignum);

Circ_Heu1   = Simplify_Circuit(Circ_Heu1,np,ne,CircuitOrder,...
                                ConvertToCZ,pass_X_photons,pass_emitter_Paulis,...
                                Init_State_Option,monitor_update,pause_time,fignum);

%------ Draw the circuits -------------------------------------------------
clc;                        
layer_shift = 1;

figure(1)                            
subplot(2,1,1)
draw_circuit(np,ne,Circ_Naive,CircuitOrder,layer_shift,Init_State_Option)
title('Naive')                
subplot(2,1,2)
draw_circuit(np,ne,Circ_Heu1,CircuitOrder,layer_shift,Init_State_Option)
title('Heuristics #1')      

disp(['CNOTs (Naive), CNOTs (Heur. #1):',num2str([CNOTs_Naive,CNOTs_Heu1])])
