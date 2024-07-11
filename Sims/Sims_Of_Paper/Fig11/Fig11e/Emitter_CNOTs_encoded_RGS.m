function [CNOT_H2,T]=Emitter_CNOTs_encoded_RGS(nmin,nmax,leaves)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 17, 2024
%--------------------------------------------------------------------------
%
%Script to evaluate the optimal number of emitter CNOTs for an encoded RGS.
%The core nodes are replaced by a tree with branching parameters b0 and b1
%(b1 are the leaf nodes). We use the Heuristics #2 optimizer.
%In the condition of search for disconnected components, we make it always
%true. (This is needed to find the min value of CNOTs).
%
%Input: nmin: min # of nodes for branching parameter b0
%       nmax: max # of nodes for branching parameter b0
%       leaves: leaf nodes per core qubit of b0
%Output: CNOT_H2: CNOT counts obtained by Heuristics #2
%        T: Total computational time

%the paper has nmin:4, nmax=50, leaves=4

close all;

nstep  = 2;             
nrange = nmin:nstep:nmax; %Number of nodes for branching parameter b0 

%--------- Options for the optimization via Heuristics #2 -----------------
Verify_Circuit  = true;
Store_Graphs    = false;
Store_Gates     = true;

BackSubsOption  = false;
return_cond     = false;
EXTRA_OPT_LEVEL = true;
recurse_further = false;
emitter_cutoff0 = 2;
future_step     = 3;

parfor L=1:length(nrange)
    
    k      = nrange(L);
    Adj{L} = create_encoded_RGS_Opt_Ordering(k,leaves);
    
end


tic
parfor L=1:length(nrange)
    
    n       = length(Adj{L});
    temp    = Tableau_Class(Adj{L},'Adjacency');
    temp    = temp.Generation_Circuit_Heu2(1:n,Store_Graphs,Store_Gates,...
                                           BackSubsOption,Verify_Circuit,...
                                           EXTRA_OPT_LEVEL,return_cond,...
                                           emitter_cutoff0,future_step,recurse_further);
                                       
    temp       = temp.Count_emitter_CNOTs;
    CNOT_H2(L) = temp.Emitter_CNOT_count;
    
end
T=toc;

%-------- Plot of CNOT counts ---------------------------------------------
figure(1)

plot(nrange,CNOT_H2,'marker','s','linewidth',2,'markersize',8,'color','c')

xlabel('$n$','interpreter','latex')
ylabel('$\#$ of emitter CNOTs','interpreter','latex')
set(gcf,'color','w')
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')
title(['$T=$',num2str(T),' (s)'],'interpreter','latex')
xlim([nmin,nmax])
hold on

y=nrange-2;
plot(nrange,y,'linestyle','--','linewidth',2,'color','k')
legend('Heuristics $\#2$','$y=n-2$','interpreter','latex','location','best',...
    'color','none','edgecolor','none')

%-------- Plot of one graph representative --------------------------------
figure(2)
k=6;
Adj     = double(create_encoded_RGS_Opt_Ordering(k,leaves));

h=plot(graph(Adj),'linewidth',2,'MarkerSize',8,'NodeFontSize',13,...
    'NodeColor','k');

G     = graph(Adj);
degs  = degree(G);
nodes = 1:length(Adj);
nodes = nodes(degs==max(degs)); %Get the node labels for b0 branching parameter

highlight(h,nodes,'NodeColor',[0.4940 0.1840 0.5560]) %Plot the nodes with purple color

title('$n=6$','interpreter','latex')
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')
set(gcf,'color','w')


end