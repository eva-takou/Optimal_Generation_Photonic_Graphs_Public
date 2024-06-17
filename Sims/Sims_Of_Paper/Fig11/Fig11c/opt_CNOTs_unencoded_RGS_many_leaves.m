function [CNOTs,T]=opt_CNOTs_unencoded_RGS_many_leaves(nmin,nmax,num_leaves_min,num_leaves_max)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 17, 2024
%--------------------------------------------------------------------------
%
%Script to evaluate the optimal number of emitter CNOTs for an un-encoded 
%RGS. We use the Heuristics #1 optimizer.
%In the condition of search for disconnected components, we can set it to
%false (last input of Optimizer).
%
%Input: nmin: min # of core nodes
%       nmax: max # of core nodes
%       num_leaves_min: min # of leaf nodes per core node
%       num_leaves_max: max # of leaf nodes per core node
%Output: CNOT_H2: CNOT counts obtained by Heuristics #2
%        T: Total computational time
%
%Inputs for Fig of the paper: nmin: 3
%                             nmax: 30
%                             num_leaves_min: 2
%                             num_leaves_max: 20

close all; clc;

%---- Options for Heuristics #1 Optimizer ---------------------------------
Store_Graphs   = false;
Store_Gates    = false;
Verify_Circuit = false;
BackSubsOption = false;
return_cond    = true;

tic
parfor n=nmin:nmax
    
    for num_leaves=num_leaves_min:num_leaves_max
        
        Adj           = create_opt_ordering_RGS_many_leaves(n,num_leaves);
        node_ordering = 1:length(Adj);

        temp  = Tableau_Class((Adj),'Adjacency');
        temp  = temp.Generation_Circuit_Heu1(node_ordering,Store_Graphs,...
                                             Store_Gates,BackSubsOption,...
                                             Verify_Circuit,return_cond,false)

        temp                = temp.Count_emitter_CNOTs;
        CNOTs(n,num_leaves) = temp.Emitter_CNOT_count;
        %ne(n,num_leaves)    = temp.Emitters;
         
    end
    
end
T=toc;

%------ Plot the CNOT counts versus core nodes and # of leaf nodes --------
figure(1)

x     = nmin:nmax;
y     = num_leaves_min:num_leaves_max;
[X,Y] = meshgrid(x,y);
Z     = CNOTs(nmin:nmax,num_leaves_min:num_leaves_max);

h=surf(X,Y,Z','linewidth',2,'MarkerSize',4);
xlabel('$n$','interpreter','latex')
zlabel('Optimal $\#$ of emitter CNOTs','interpreter','latex')
ylabel('$\#$ of leaves','interpreter','latex')

hold on
plot(nmin:nmax,[nmin:nmax]-2,'linewidth',3)
set(gcf,'color','w')
set(gca,'fontsize',24,'fontname','Microsoft Sans Serif')
xlim([nmin,nmax])
ylim([num_leaves_min,num_leaves_max])
view(0,90)
colormap bone

h.EdgeColor='none';
oldcmap = colormap;
colormap( flipud(oldcmap) );
h=colorbar;

title(['$T=$',num2str(T),' (s)'],'interpreter','latex')

%----------- Plot one graph representative --------------------------------
figure(2)

n          = 30;
num_leaves = 20;
Adj        = double(create_opt_ordering_RGS_many_leaves(n,num_leaves));

plot(graph(Adj),'NodeColor','k','MarkerSize',4,'linewidth',1,...
    'layout','circle','NodeFontSize',5)
set(gcf,'color','w')
title(['$n=$',num2str(n),', $\#$ of leaves=',num2str(num_leaves)],...
    'interpreter','latex')
set(gca,'fontsize',24)

end