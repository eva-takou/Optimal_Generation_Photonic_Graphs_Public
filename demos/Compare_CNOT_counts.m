%Compare emitter CNOT counts obtained by 3 different optimizers.

clear; clc; close all;

Store_Graphs    = false;
Store_Gates     = false;
BackSubsOption  = false;
Verify_Circuit  = false;
return_cond     = true;

%--------- Create the graph -----------------------------------------------
np       = 15;
Adj      = create_random_graph(np);
ordering = 1:np;

%--------- Run Naive -----------------------------------------------------
obj = Tableau_Class(Adj,'Adjacency');
obj = obj.Generation_Circuit(ordering,Store_Graphs,Store_Gates,BackSubsOption,...
                             Verify_Circuit,return_cond);
                         
obj         = obj.Count_emitter_CNOTs;
CNOTs_Naive = obj.Emitter_CNOT_count;

%--------- Heuristics #1 --------------------------------------------------
BackSubsOption = true;
return_cond    = false;

obj = obj.Generation_Circuit_Heu1(ordering,Store_Graphs,Store_Gates,BackSubsOption,...
                                  Verify_Circuit,return_cond);
                         
obj         = obj.Count_emitter_CNOTs;
CNOTs_Heur1 = obj.Emitter_CNOT_count;

%--------- Heuristics #2 --------------------------------------------------
%Try 3 variants
EXTRA_OPT_LEVEL = true;
recurse_further = true;
emitter_cutoff0 = 8;
future_step     = 2;

BackSubsOption = true;
return_cond    = false;

obj = obj.Generation_Circuit_Heu2(ordering,Store_Graphs,Store_Gates,BackSubsOption,...
                              Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,...
                              emitter_cutoff0,future_step,recurse_further);

obj            = obj.Count_emitter_CNOTs;
CNOTs_Heur2_V1 = obj.Emitter_CNOT_count;

BackSubsOption = false;
return_cond    = true;

obj = obj.Generation_Circuit_Heu2(ordering,Store_Graphs,Store_Gates,BackSubsOption,...
                              Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,...
                              emitter_cutoff0,future_step,recurse_further);

obj            = obj.Count_emitter_CNOTs;
CNOTs_Heur2_V2 = obj.Emitter_CNOT_count;

BackSubsOption = false;
return_cond    = false;

obj = obj.Generation_Circuit_Heu2(ordering,Store_Graphs,Store_Gates,BackSubsOption,...
                              Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,...
                              emitter_cutoff0,future_step,recurse_further);

obj            = obj.Count_emitter_CNOTs;
CNOTs_Heur2_V3 = obj.Emitter_CNOT_count;

CNOTs_Heur2 = min([CNOTs_Heur2_V1,CNOTs_Heur2_V2,CNOTs_Heur2_V3]);

clc;
disp('--------- Results --------')
disp(['CNOT counts from Naive:',num2str(CNOTs_Naive)])
disp(['CNOT counts from Heur1:',num2str(CNOTs_Heur1)])
disp(['CNOT counts from Heur2:',num2str(CNOTs_Heur2)])

