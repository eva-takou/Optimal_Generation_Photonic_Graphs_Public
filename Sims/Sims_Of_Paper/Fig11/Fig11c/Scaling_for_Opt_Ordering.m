%Plot the CNOT counts for RGSs with multiple leaves

clearvars;
close all;
clc;

Store_Graphs   = false;
Store_Gates    = false;
Verify_Circuit = false;
BackSubsOption = false;
return_cond    = true;

nmin=3;
nmax=30;

num_leaves_min = 2;
num_leaves_max = 20;

tic
parfor n=nmin:nmax
    
    for num_leaves=num_leaves_min:num_leaves_max
        
        Adj=create_opt_ordering_RGS_many_leaves(n,num_leaves);

        node_ordering=1:length(Adj);

        temp  = Tableau_Class((Adj),'Adjacency');
        temp  = temp.Generation_Circuit_Heu1(node_ordering,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond,false)

        temp                = temp.Count_emitter_CNOTs;
        CNOTs(n,num_leaves) = temp.Emitter_CNOT_count;
        ne(n,num_leaves)    = temp.Emitters;
         
    end
    
end
T=toc

%%
close all
clc
x=nmin:nmax;
y=num_leaves_min:num_leaves_max;
[X,Y]=meshgrid(x,y);
Z=CNOTs(nmin:nmax,num_leaves_min:num_leaves_max);
h=surf(X,Y,Z','linewidth',2,'MarkerSize',4)
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
h=colorbar

title(['$T=$',num2str(T),' (s)'],'interpreter','latex')

%% Plot one graph representative
close all
n=30;
num_leaves=20;
Adj=create_opt_ordering_RGS_many_leaves(n,num_leaves);
plot(graph(Adj),'EdgeColor','k','MarkerSize',4,'linewidth',1,...
    'layout','circle','NodeFontSize',5)
set(gcf,'color','w')
title(['$n=$',num2str(n),', $\#$ of leaves=',num2str(num_leaves)],...
    'interpreter','latex')
set(gca,'fontsize',24)
