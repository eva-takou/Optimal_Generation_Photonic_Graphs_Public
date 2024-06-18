function run_CNOT_counts_random_LC_orbits(graph_size)

if graph_size==7
        
        load('Data_Random_Graph_7.mat')
        
elseif graph_size==8
        
        load('Data_Random_Graph_8.mat')
        
elseif graph_size==9
        
        load('Data_Random_Graph_9.mat')
            
end


clearvars -except CNOTs_Heu1 CNOTs_Heu2 AdjLC CNOTs_Opt CNOTs_Best graph_size Adj

node_ordering  = 1:graph_size;
Store_Graphs   = false;
Store_Gates    = false;
Verify_Circuit = false;

%-------  Options for brute-force Optimizer -------------------------------
prune          = true;
tryLC          = false;
LC_Rounds      = 1;
LCsTop         = false;

%-------- Options for Heuristics #2 Optimizer -----------------------------
EXTRA_OPT_LEVEL  = true;
BackSubsOption   = true;
recurse_further  = true;
emitter_cutoff0  = 4;
future_step      = 4;


adj=AdjLC;  
AdjLC=adj;

parfor k=1:length(AdjLC)
    
    temp     = Tableau_Class(full(AdjLC{k}),'Adjacency');
    
    return_cond=false;
    
    
    temp=temp.Generation_Circuit_Heu1(node_ordering,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond);
    
    temp     = temp.Count_emitter_CNOTs;
    CNOTs_Heu1(k) = temp.Emitter_CNOT_count;
    
    return_cond=false;
    
    temp=temp.Generation_Circuit_Heu2(node_ordering,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,...
                                      EXTRA_OPT_LEVEL,return_cond,...
                                      emitter_cutoff0,future_step,recurse_further);
                                  
    temp          = temp.Count_emitter_CNOTs;
    CNOTs_Heu2(k) = temp.Emitter_CNOT_count;
    
    
    
    ne(k)    = temp.Emitters;
    
    
    temp     = temp.Optimize_Generation_Circuit(node_ordering,Store_Graphs,Store_Gates,prune,tryLC,LC_Rounds,Verify_Circuit,...
                                                LCsTop,BackSubsOption,return_cond);
    CNOTs_Opt(k) = temp.Emitter_CNOT_count;
    
end

for k=1:length(AdjLC)
   
    CNOTs_Best(k) = min([CNOTs_Opt(k),CNOTs_Heu1(k),CNOTs_Heu2(k)]);
    
end

%CNOTs_Best=CNOTs_Opt;

[~,indx]=find(CNOTs_Best~=min(CNOTs_Best));

if ~isempty(indx)
    
    tryLC       =true;
    return_cond =true;
    
    if graph_size==9
        
        prune =true;
        
    else
        
        prune =false;


        BackSubsOption=true;
        tic
        parfor k=1:length(indx)

            temp        = Tableau_Class(full(AdjLC{indx(k)}),'Adjacency');
            temp        = temp.Optimize_Generation_Circuit(node_ordering,Store_Graphs,Store_Gates,prune,tryLC,LC_Rounds,Verify_Circuit,...
                                                           LCsTop,BackSubsOption,return_cond);
            newCNOTs(k) = temp.Emitter_CNOT_count;

        end

        CNOTs_Best(indx)=newCNOTs;
    
    end    
    
end



if ~isempty(indx)
   
    tot_figs=4;
else
    tot_figs=3;
    
    
end

close all
clc

subplot(tot_figs,1,1)

plot(graph(double(Adj)),'EdgeColor','k','NodeFontSize',13,'MarkerSize',8,'linewidth',1.2);
set(gcf,'color','w')

title(['$n_e=$',num2str(ne(1))],'interpreter','latex')
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')




subplot(tot_figs,1,2)
bar(CNOTs_Heu1,'facecolor',[0.8500 0.3250 0.0980])
hold on
bar(CNOTs_Heu2,0.5,'facecolor','c')
hold on

xlabel('LC index')
ylabel({'$\#$ of emitter','CNOTs'},'interpreter','latex')
legend('Heur. $\#1$','Heur. $\#2$','interpreter','latex',...
    'color','none','edgecolor','none','location','best',...
    'numcolumns',3)       
set(gcf,'color','w')
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')

subplot(tot_figs,1,3)
bar(CNOTs_Opt,'facecolor',[0.9290 0.6940 0.1250],'edgecolor','k')

legend('Brute-force (no LCs, w/ prune)','interpreter','latex',...
    'color','none','edgecolor','none','location','best',...
    'numcolumns',3)     
xlabel('LC index')
ylabel({'$\#$ of emitter','CNOTs'},'interpreter','latex')

set(gcf,'color','w')
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')


if isempty(indx)
    return
    
end
subplot(tot_figs,1,4)


bar(indx,CNOTs_Best(indx),'facecolor',[0.9290 0.6940 0.1250])
if prune
    legend('Brute-force (1 LC Round,w/ prune)','edgecolor','none','color','none','interpreter','latex')
else
    legend('Brute-force (1 LC Round,w/o prune)','color','none','edgecolor','none','interpreter','latex')
end
xlim([0,length(AdjLC)+1])
xlabel('LC index')
ylabel({'$\#$ of emitter','CNOTs'},'interpreter','latex')
set(gcf,'color','w')
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')


end