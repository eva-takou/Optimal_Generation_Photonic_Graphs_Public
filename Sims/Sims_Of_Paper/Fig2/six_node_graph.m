%% Graph evolution and circuit of a 6-node graph

clear;
close all;
clc;

Adj = [0 0 0 0 1 0;...
       0 0 1 0 1 1;...
       0 1 0 1 1 1;...
       0 0 1 0 1 0;...
       1 1 1 1 0 0;...
       0 1 1 0 0 0];

n = length(Adj);

Store_Graphs   = true;
Store_Gates    = false;
BackSubsOption = false;
Verify_Circuit = false;
return_cond    = true;

   
figure(1)   
plot(graph(Adj))   


%------------ Generation (Naive)  -----------------------------------------


temp=Tableau_Class(Adj,'Adjacency');
temp=temp.Generation_Circuit(1:n,Store_Graphs,Store_Gates,...
                        BackSubsOption,Verify_Circuit,return_cond);


np             = n;                    
graphs         = temp.Photonic_Generation_Graph_Evol;                    
emitters       = np+1:np+temp.Emitters;
emitters_Color = [0.9290 0.6940 0.1250];
fignum         = 2;

plot_graph_evol(graphs,emitters,fignum,emitters_Color)        

%% Plot the optimal circuit found by Heuristics #1 (Appendix)
close all;

Verify_Circuit = true;
Store_Graphs   = false;
Store_Gates    = true;
BackSubsOption = true;
return_cond    = true;

%-------- Options for the simplification ----------------------------------

CircOrder           = 'backward';
ConvertToCZ         = false;
pass_X_photons      = true;                             
pass_emitter_Paulis = false;
Init_State_Option   = '0';
monitor_update      = false;
pause_time          = 0.001;
fignum              = 100;
%--------------------------------------------------------------------------

temp = Tableau_Class(Adj,'Adjacency');
temp = temp.Generation_Circuit_Heu1(1:n,Store_Graphs,Store_Gates,...
               BackSubsOption,Verify_Circuit,return_cond);

ne      = temp.Emitters;           
Circuit = temp.Photonic_Generation_Gate_Sequence;
Circuit = fix_potential_phases_forward_circuit(Circuit,Adj,ne,CircOrder);
Circuit = Simplify_Circuit(Circuit,np,ne,CircOrder,ConvertToCZ,pass_X_photons,...
                             pass_emitter_Paulis,Init_State_Option,...
                             monitor_update,pause_time,fignum);


draw_circuit(np,ne,Circuit,CircOrder,1,Init_State_Option)
