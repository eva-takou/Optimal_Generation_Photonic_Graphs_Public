function plot_graph_evol(graphs,emitters,fignum,emitter_Color)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Input: graphs: a struct with fields 'Adjacency' and 'identifier'. The
%               identifier describes the process that happened in the
%               generation [e.g., time-reversed measurement (TRM), 
%               disentanglement (DE), photon absorption (PA)].
%       emitters: a vector (double) of node labels of emitters
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