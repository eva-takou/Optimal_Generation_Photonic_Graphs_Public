%Get the CNOT counts across an LC orbit

clear; clc; close all;

np       = 7;
Adj      = create_random_graph(np);
ordering = 1:np;
Adj_LC   = Map_Out_Orbit(Adj,'prune'); %discard isomorphs


%---------- Naive ---------------------------------------------------------
Store_Graphs    = false;
Store_Gates     = false;
BackSubsOption  = false;
Verify_Circuit  = false;
return_cond     = true;

for k=1:length(Adj_LC)
    
    obj = Tableau_Class(Adj_LC{k},'Adjacency');
    obj = obj.Generation_Circuit(ordering,Store_Graphs,Store_Gates,BackSubsOption,...
                                 Verify_Circuit,return_cond);

    obj            = obj.Count_emitter_CNOTs;
    CNOTs_Naive(k) = obj.Emitter_CNOT_count;
    
end

%----------- Heuristics #1 ------------------------------------------------

for k=1:length(Adj_LC)

    BackSubsOption = true;
    return_cond    = false;
    
    
    obj = Tableau_Class(Adj_LC{k},'Adjacency');
    obj = obj.Generation_Circuit_Heu1(ordering,Store_Graphs,Store_Gates,BackSubsOption,...
                                      Verify_Circuit,return_cond);

    obj               = obj.Count_emitter_CNOTs;
    CNOTs_Heur1_V1(k) = obj.Emitter_CNOT_count;
    
    BackSubsOption = false;
    return_cond    = true;
    
    obj = Tableau_Class(Adj_LC{k},'Adjacency');
    obj = obj.Generation_Circuit_Heu1(ordering,Store_Graphs,Store_Gates,BackSubsOption,...
                                      Verify_Circuit,return_cond);

    obj               = obj.Count_emitter_CNOTs;
    CNOTs_Heur1_V2(k) = obj.Emitter_CNOT_count;

    CNOTs_Heur1(k) = min([CNOTs_Heur1_V1(k),CNOTs_Heur1_V1(k)]);
    
end

%----------- Heuristics #2 ------------------------------------------------

EXTRA_OPT_LEVEL = true;
recurse_further = true;
emitter_cutoff0 = 5;
future_step     = 2;

for k=1:length(Adj_LC)

    BackSubsOption = true;
    return_cond    = false;
    
    
    obj = Tableau_Class(Adj_LC{k},'Adjacency');
    obj = obj.Generation_Circuit_Heu2(ordering,Store_Graphs,Store_Gates,BackSubsOption,...
                              Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,...
                              emitter_cutoff0,future_step,recurse_further);

    obj               = obj.Count_emitter_CNOTs;
    CNOTs_Heur2_V1(k) = obj.Emitter_CNOT_count;
    
    BackSubsOption = false;
    return_cond    = true;
    
    obj = Tableau_Class(Adj_LC{k},'Adjacency');
    obj = obj.Generation_Circuit_Heu2(ordering,Store_Graphs,Store_Gates,BackSubsOption,...
                              Verify_Circuit,EXTRA_OPT_LEVEL,return_cond,...
                              emitter_cutoff0,future_step,recurse_further);

    obj               = obj.Count_emitter_CNOTs;
    CNOTs_Heur2_V2(k) = obj.Emitter_CNOT_count;

    
    CNOTs_Heur2(k) = min([CNOTs_Heur2_V1(k),CNOTs_Heur2_V2(k)]);
    
end


%------ Brute force -------------------------------------------------------

LCsTop = false;
BackSubsOption = true;
return_cond    = false;
tryLC          = false;
LC_Rounds      = [];
prune          = true;

for k=1:length(Adj_LC)
    
    obj = Tableau_Class(Adj_LC{k},'Adjacency');
    obj = obj.Optimize_Generation_Circuit(ordering,Store_Graphs,Store_Gates,...
                                          prune,tryLC,LC_Rounds,Verify_Circuit,...
                                          LCsTop,BackSubsOption,return_cond);
    obj                 = obj.Count_emitter_CNOTs;
    CNOTs_BruteForce(k) = obj.Emitter_CNOT_count;
    
end


subplot(2,1,1)
bar(CNOTs_Naive,'facecolor','k')
hold on
bar(CNOTs_Heur1,0.6)
hold on
bar(CNOTs_Heur2,0.4,'facecolor','c')
xlabel('LC index')
ylabel('$\#$ of emit. CNOTs','interpreter','latex')
legend('Naive','Heur. #1','Heur. #2','color','none','edgecolor','none',...
       'location','best')
   
set(gcf,'color','w')   
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')

subplot(2,1,2)
bar(CNOTs_BruteForce,0.4,'facecolor',[0.9290 0.6940 0.1250])
xlabel('LC index')
ylabel('$\#$ of emit. CNOTs','interpreter','latex')
legend('Bruteforce','color','none','edgecolor','none',...
       'location','best')
   
set(gcf,'color','w')   
set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')
