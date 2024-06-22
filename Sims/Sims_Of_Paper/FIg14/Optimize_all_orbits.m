function Optimize_all_orbits(orbit_index_min,orbit_index_max,fntsize)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 22, 2024
%--------------------------------------------------------------------------
%
%Optimize emitter CNOT counts within orbits of n=6 order graphs.
%
%Input: orbit_index_min: index from 1-312 to select starting LC family
%       orbit_index_max: index from 1-312 to select final LC family
%       fntsize: fontsize of the plots

%These are the optimal CNOT counts for all 312 families (obtained from a
%different run).
Min_CNOTs=[0,1,1,1,0,...   5
           1,1,1,1,2,...   10
           1,1,2,1,1,...   15
           1,1,1,0,0,...   20
           1,1,1,2,1,...   25
           1,2,1,1,1,...   30
           1,1,2,1,2,...   35
           1,1,1,1,1,...   40
           2,1,1,2,1,...   45
           1,1,1,1,1,...   50
           1,1,1,1,2,...   55
           1,1,2,0,1,...   60
           0,1,0,0,1,...   65
           1,1,1,1,2,...   70
           1,2,1,1,1,...   75
           2,2,1,1,2,...   80
           1,1,2,1,1,...   85
           1,1,1,1,1,...   90
           2,2,2,2,1,...   95
           1,1,1,1,1,...   100
           1,1,1,1,1,...   105
           2,1,1,2,1,...   110
           1,1,2,2,2,...   115
           2,2,1,1,1,...   120
           2,1,1,2,1,...   125
           2,1,1,2,2,...   130
           2,2,2,1,2,...   135
           1,1,2,2,1,...   140
           2,2,1,2,2,...   145
           2,2,2,2,1,...   150
           2,1,1,2,1,...   155
           2,2,1,1,2,...   160
           1,1,2,2,2,...   165
           2,2,1,2,1,...   170
           1,2,2,2,1,...   175
           2,2,2,2,2,...   180
           1,2,2,2,1,...   185
           2,1,2,1,1,...   190
           1,2,2,1,1,...   195
           1,2,1,1,2,...   200
           2,2,1,2,2,...   205
           1,1,2,2,2,...   210
           1,2,1,1,1,...   215
           2,2,1,1,2,...   220
           2,2,2,2,2,...   225
           1,3,1,2,3,...   230
           2,1,1,1,2,...   235
           2,2,2,2,1,...   240
           3,1,2,3,1,...   245
           1,2,2,2,1,...   250
           3,1,3,1,2,...   255
           2,2,2,2,2,...   260
           2,2,2,2,2,...   265
           2,2,2,2,2,...   270
           2,2,2,2,2,...   275
           2,2,2,2,2,...   280
           2,2,2,2,3,...   285
           2,3,2,3,3,...   290
           3,3,3,3,3,...   295
           2,3,2,3,3,...   300
           3,3,3,2,3,...   305
           2,3,3,4,4,...   310
           4,5];          %312


parfor orbit_index=orbit_index_min:round(orbit_index_max/2)

    for Opt_ID=0:10
    
        [CNOTs{orbit_index},color{orbit_index},legs{orbit_index}]=Optimize_Single_Orbit(orbit_index,Opt_ID);
        
        if all(CNOTs{orbit_index}==Min_CNOTs(orbit_index)) %all(CNOTs{orbit_index}==min(CNOTs{orbit_index}))
            
           break
           
        else
            
            if Opt_ID==10
                error(['No optimizer succeded for ',num2str(orbit_index)])
            end
            
        end
        
        
    end
    
end


parfor orbit_index=round(orbit_index_max/2)+1:orbit_index_max

    for Opt_ID=0:10
    
    
        [CNOTs{orbit_index},color{orbit_index},legs{orbit_index}]=Optimize_Single_Orbit(orbit_index,Opt_ID);
        
        if all(CNOTs{orbit_index}==Min_CNOTs(orbit_index)) 
            
           break
           
        else
            
            if Opt_ID==10
                error(['No optimizer succeded for ',num2str(orbit_index)])
            end
            
        end
        
        
    end
    
end


clc;
disp('--------------- Done. ----------------------------------------')

close all
figure(1)
tiledlayout('flow')


for jj=orbit_index_min:orbit_index_max 
    
    nexttile
    h=bar(CNOTs{jj},'facecolor',color{jj});
    hold on


    if color{jj}=='k'
       h.EdgeColor='w';
       h.EdgeAlpha=0.2;
        
    end
    
    if length(CNOTs{jj})==10
       set(gca,'xtick',0:5:10) 
    elseif length(CNOTs{jj})==6
        set(gca,'xtick',0:2:6) 
    end


    xlabel('LC index')
    ylabel('$\#$ of CNOTs','interpreter','latex')
    title(['LC family #',num2str(jj)])
    set(gcf,'color','w')
    set(gca,'fontsize',fntsize,'fontname','Microsoft Sans Serif')
    
end



end