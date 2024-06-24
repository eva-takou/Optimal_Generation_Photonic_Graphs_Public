%Produce the multigraphs of RGS

clear; close all; clc;

n   = 3; %number of core nodes
Adj = create_RGS(n,1:2*n,n,'Adjacency');
m=double_occurrence_RGS(n); %Word for RGS


EdgeList = double_occur_words_to_multigraph_edges(m);
s        = EdgeList{1}(:,1);
t        = EdgeList{1}(:,2);
G        = graph(s,t);

plot(G,'layout','circle')