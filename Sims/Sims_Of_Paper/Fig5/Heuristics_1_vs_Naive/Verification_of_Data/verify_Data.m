function verify_Data(AdjTest,CNOT_Best,CNOT_Naive,nmin,nmax,nstep,iterMax)

Adj = AdjTest;
BackSubsOption  = false;
return_cond     = true;
Store_Graphs    = false;
Store_Gates     = true;
Verify_Circuit  = true;



parfor iter=1:iterMax
    
    
    for n=nmin:nstep:nmax
        
        temp=Tableau_Class(Adj{iter,n},'Adjacency');
        temp=temp.Generation_Circuit(1:n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond) ;
        temp=temp.Count_emitter_CNOTs;
        CNOT_Naive_Verify(iter,n) = temp.Emitter_CNOT_count;
        ne(iter,n)=temp.Emitters;
        
        
        temp=temp.Generation_Circuit_Heu1(1:n,Store_Graphs,Store_Gates,false,Verify_Circuit,true);
        temp=temp.Count_emitter_CNOTs;
        CNOT_Heu1(iter,n) = temp.Emitter_CNOT_count;
        
        temp=temp.Generation_Circuit_Heu1(1:n,Store_Graphs,Store_Gates,true,Verify_Circuit,false);
        temp=temp.Count_emitter_CNOTs;
        CNOT_Heu1_Alt(iter,n) = temp.Emitter_CNOT_count;
        
        temp=temp.Generation_Circuit_Heu1(1:n,Store_Graphs,Store_Gates,false,Verify_Circuit,false);
        temp=temp.Count_emitter_CNOTs;
        CNOT_Heu1_Alt_2(iter,n) = temp.Emitter_CNOT_count;
        
    end
    
end


for iter=1:iterMax
    
    
    for n=nmin:nstep:nmax
        
        CNOT_Best_Verify(iter,n) = min([CNOT_Heu1(iter,n),CNOT_Heu1_Alt(iter,n),...
            CNOT_Heu1_Alt_2(iter,n),CNOT_Naive(iter,n)]);
        
        
        
    end
    
end

nrange=nmin:nstep:nmax;


if any(any(CNOT_Best(1:iterMax,nrange)<CNOT_Best_Verify(1:iterMax,nrange)))
    
    CNT_worst  = sum(CNOT_Best(1:iterMax,nrange)<CNOT_Best_Verify(1:iterMax,nrange),'all');
    CNT_better = sum(CNOT_Best(1:iterMax,nrange)>CNOT_Best_Verify(1:iterMax,nrange),'all');
    CNT_tie    = sum(CNOT_Best(1:iterMax,nrange)==CNOT_Best_Verify(1:iterMax,nrange),'all');
    
    indx=10;
    
    minX = 1;
    maxX = 10;
    
    close all
    bar(CNOT_Best(minX:maxX,nrange(indx)),'k')
    hold on
    bar(CNOT_Best_Verify(minX:maxX,nrange(indx)),0.4,'y')
    legend('old','new')
    
    
    error('New results gave a case of worst performance.')
    
    
    
end




% if ~all(all(CNOT_Best_Verify(1:iterMax,nrange)==CNOT_Best(1:iterMax,nrange)))
% 
%     close all
%     indx=4;
%     bar(CNOT_Best(1:iterMax,nrange(indx)))
%     hold on
%     bar(CNOT_Best_Verify(1:iterMax,nrange(indx)),0.3)
%     legend('old data','new data')
%     
%     %[]
%     %error('Results do not agree') 
% end

if ~all(all(CNOT_Naive_Verify(1:iterMax,nrange)==CNOT_Naive(1:iterMax,nrange)))
    [];
    error('Results do not agree') 
end





end