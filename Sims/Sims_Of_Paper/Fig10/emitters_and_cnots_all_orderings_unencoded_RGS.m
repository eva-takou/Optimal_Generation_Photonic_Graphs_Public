function [ne,CNOT_Best]=emitters_and_cnots_all_orderings_unencoded_RGS(nmax)

close all;
nmin  = 3;
order = cell(1,nmax);
L     = zeros(1,nmax);

for n=nmin:nmax
    
    Adj      = double(create_RGS(n,1:2*n,n,'Adjacency'));
    order{n} = perms(1:2*n);
    L(n)     = size(order{n},1);
    
    for l=1:size(order{n},1)
    
        temp    = Tableau_Class(Adj,'Adjacency');
        temp    = temp.Get_Emitters(order{n}(l,:)); %Below we assume 1:2n ordering, because otherwise we shuffle twice.
        ne(n,l) = temp.Emitters;    
        
    end
    
end

Lmax = max(L);

parfor n=nmin:nmax
    
    [CNOT_Best{n}]=run_for_single_n(n,Lmax,L);
    
end

for k=nmin:nmax

    [~,indx_sort] = sort(ne(k,1:L(k)));
    
    nexttile
    
    h=bar(ne(k,indx_sort));
    h.EdgeColor='k';
    h.EdgeAlpha=0.5;
    hold on
    
    temp = CNOT_Best{k};
    temp = temp(indx_sort);
    
    bar(temp)
    
    xlabel('Index of permuation')
    ylabel('Counts')
    set(gcf,'color','w')
    set(gca,'fontsize',20,'fontname','Microsoft Sans Serif')
    legend('$\#$ of emitters','$\#$ of emitter CNOTs','interpreter','latex',...
        'color','none','edgecolor','none','location','best')
    title(['$K_{',num2str(k),'}^{',num2str(k),'}$'],'interpreter','latex')
    
end


end

function [CNOT_Best]=run_for_single_n(n,Lmax,L)

Store_Graphs   = false;
Store_Gates    = false;
Verify_Circuit = false;
BackSubsOption = false;
return_cond    = false;

Adj0  = double(create_RGS(n,1:2*n,n,'Adjacency'));
order = perms(1:2*n);

%--------------------- Heu 1 --------------------------------------

for l=1:Lmax

    if l<=L(n)

        P               = eye(2*n);
        P(:,order(l,:)) = P(:,1:2*n);
        Adj             = P*Adj0*P';     
        temp            = Tableau_Class(Adj,'Adjacency');
        
        temp         = temp.Generation_Circuit_Heu1(1:2*n,Store_Graphs,Store_Gates,BackSubsOption,Verify_Circuit,return_cond);
        temp         = temp.Count_emitter_CNOTs;
        CNOT_Best(l) = temp.Emitter_CNOT_count;
        
    end

end


end
