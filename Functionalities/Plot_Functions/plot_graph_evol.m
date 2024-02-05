function plot_graph_evol(graphs,emitters,fignum)

figure(fignum)
for jj=1:length(graphs.Adjacency)
   
    nexttile
    hold on
    h=plot(graph(double(graphs.Adjacency{jj})));
    h.NodeColor='k';
    h.EdgeAlpha=0.9;
    h.LineWidth=0.9;
    h.NodeFontSize=10;
    h.MarkerSize=6;
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    if jj>1
        highlight(h, emitters, 'NodeColor', [0.4940 0.1840 0.5560]);
    end
    
    title(graphs.identifier{jj})
    
end
set(gcf,'color','w')


end