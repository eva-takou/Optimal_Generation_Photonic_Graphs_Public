% Plot the graph evolution after application of 2 qubit gates

clear; close all; clc;

np       = 8;
Adj      = create_random_graph(np);
ordering = 1:np;

Store_Graphs    = true;
Store_Gates     = false;
BackSubsOption  = false;
Verify_Circuit  = false;
return_cond     = true;



%----- Naive optimizer ---------------------------------------------------
obj = Tableau_Class(Adj,'Adjacency');
obj = obj.Generation_Circuit(ordering,Store_Graphs,Store_Gates,BackSubsOption,...
                             Verify_Circuit,return_cond);
                         
                         
ne     = obj.Emitters;                         
graphs = obj.Photonic_Generation_Graph_Evol;


emitter_Color = [0.9290 0.6940 0.1250];
fignum        = 1;
emitters      = np+1:np+ne;
plot_graph_evol(graphs,emitters,fignum,emitter_Color)

