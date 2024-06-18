function optimization_pattern
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 18, 2024
%--------------------------------------------------------------------------
%
%Script to compare the graph evolution of Naive and Brute-force for 
%a 7-node photonic graph.

Adj = [0 1 1 1 0 0 1;...
       1 0 0 0 0 0 0;...
       1 0 0 0 1 1 0;...
       1 0 0 0 1 0 1;...
       0 0 1 1 0 0 1;...
       0 0 1 0 0 0 0;...
       1 0 0 1 1 0 0];

np             = length(Adj);   
Store_Graphs   = true;
Store_Gates    = false;
BackSubsOption = false;
Verify_Circuit = false;
return_cond    = true;
   
temp = Tableau_Class(Adj,'Adjacency');
temp = temp.Generation_Circuit(1:np,Store_Graphs,Store_Gates,BackSubsOption,...
                             Verify_Circuit,return_cond);
                         
                         
graphs_Naive = temp.Photonic_Generation_Graph_Evol;

prune     = false;
tryLC     = false;
LC_Rounds = [];
LCsTop    = false;

temp=temp.Optimize_Generation_Circuit(1:np,Store_Graphs,Store_Gates,prune,...
                                      tryLC,LC_Rounds,Verify_Circuit,LCsTop,...
                                      BackSubsOption,return_cond);

emitters      = np+1:np+temp.Emitters;
emitter_Color = [0.9290 0.6940 0.1250];
graphs_Brute  = temp.Photonic_Generation_Graph_Evol;

plot_graph_evol(graphs_Naive,emitters,1,emitter_Color) %fignum=1
plot_graph_evol(graphs_Brute,emitters,2,emitter_Color) %fignum=2


end