clc; clear; close all;

Adj = [0 1 1 1 1;...
       1 0 0 0 1;...
       1 0 0 1 1;...
       1 0 1 0 1;...
       1 1 1 1 0];

np = length(Adj);
   
plot(graph(Adj),'nodecolor','k','markersize',7,...
    'linewidth',1.5,'nodefontsize',15)  


% ---------- Simulate with the Naive: ---------------------------
Store_Graphs = true;
Store_Gates  = true;
BackSubsOption = false;
Verify_Circuit = true;
return_cond    = true; %early exit from free PA

obj = Tableau_Class(Adj,'Adjacency');
obj = obj.Generation_Circuit(1:np,Store_Graphs,Store_Gates,...
                             BackSubsOption,Verify_Circuit,return_cond);
h   = obj.height;

figure(2)
plot(0:np,h,'linewidth',2,'marker','o','markerfacecolor','k',...
    'markeredgecolor','k','color',[0.9290 0.6940 0.1250])
xlabel('$x$','interpreter','latex')
ylabel('$h$','interpreter','latex')
set(gcf,'color','w')
set(gca,'fontsize',24,'fontname','microsoft sans serif')
          
% --------- Extract the output: -----------------------------------                         
Circuit = obj.Photonic_Generation_Gate_Sequence;
graphs  = obj.Photonic_Generation_Graph_Evol;
ne      = obj.Emitters;


%-------- Post-process the circuit: -------------------------------

Circuit = put_circuit_forward_order(Circuit);

layer_shift = 1;
Init_State  = '0';
circuitOrder = 'forward';

%-------- Plot the circuit: ---------------------------------------

figure(3)
draw_circuit(np,ne,Circuit,circuitOrder,layer_shift,Init_State)



ConvertToCZ         = false;
pass_X_Photons      = true;
pass_emitter_Paulis = true;
monitor_update      = false;
pause_time          = 0.001;
fignum              = 4;

Circuit = Simplify_Circuit(Circuit,np,ne,circuitOrder,ConvertToCZ,...
                          pass_X_Photons,pass_emitter_Paulis,Init_State,...
                          monitor_update,pause_time,fignum);
                      
%-------- Plot a simplified circuit: --------------------------------


figure(4)                      
draw_circuit(np,ne,Circuit,circuitOrder,layer_shift,Init_State)

%-------- Plot graph evolution: -------------------------------------

fignum = 5;
color  = [0.9290 0.6940 0.1250];
emitters = np+1:np+ne;
plot_graph_evol(graphs,emitters,fignum,color)

