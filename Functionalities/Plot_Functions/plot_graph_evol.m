function plot_graph_evol(graphs,emitters,fignum,emitter_Color)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 6, 2024
%--------------------------------------------------------------------------
%
%Plot the graph evolution during the photonic generation (shows the update
%only after the application of 2 qubit gates).
%
%Input: graphs: a struct with fields 'Adjacency' and 'identifier'. The
%               identifier describes the process that happened in the
%               generation [e.g., time-reversed measurement (TRM), 
%               disentanglement (DE), photon absorption (PA)]. It is the
%               output property of the tableau class object
%               'Photonic_Generation_Graph_Evol'.
%       emitters: a vector of node labels of emitters
%       fignum: the index of figure to plot
%       emitter_Color: the node color of emitters        
%
%By default, the node color of photons is black.

figure(fignum) 

for jj=1:length(graphs.Adjacency)
   
    nexttile
    hold on
    h=plot(graph(double(graphs.Adjacency{jj})));
    h.NodeColor='k';
    h.EdgeAlpha=0.9;
    h.LineWidth=0.9;
    h.NodeFontSize=12;
    h.MarkerSize=6;
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    if jj>=1
        highlight(h, emitters, 'NodeColor', emitter_Color);
    end
    
    title(graphs.identifier{jj},'fontsize',14)
    
end
set(gcf,'color','w')


end