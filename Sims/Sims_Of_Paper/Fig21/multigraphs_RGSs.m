%Produce the multigraphs of RGS

clear; close all; clc;

nmin = 3;
nmax = 6;

for n=nmin:nmax %number of core nodes

    Adj = create_RGS(n,1:2*n,n,'Adjacency');
    m   = double_occurrence_RGS(n); %Word for RGS

    EdgeList = double_occur_words_to_multigraph_edges(m);
    s        = EdgeList(:,1);
    t        = EdgeList(:,2);
    G        = graph(s,t);

    nexttile
    plot(G,'layout','circle')
    hold on
    
end

set(gcf,'color','w')