%Plot the graph representatives of the order n=6 non-LC equivalent graphs


close all; clc;
load('n_6_orbit.mat')

clearvars -except Adj_non_LC

figure(1)
tiledlayout('flow')


for k=1:length(Adj_non_LC)
    
    
    nexttile 
    plot(graph(Adj_non_LC{k}),'NodeColor','k',...
        'linewidth',1.5)
    hold on
   
end