function [str_sols]=verify_LC_sol_Tab(G1,G2,str_sols)
%Function to verify the LC test, by inspecting if we generate the same
%graph.
%
%Sometimes, due to having to apply again local gates, we might not recover
%exactly the same matrix.
%
%
close all;
n=length(G1);

conds=false(1,length(str_sols));

for jj=1:length(str_sols)
    
    temp2=Tableau_Class(G2,'Adjacency');
    
    this_sol = str_sols{jj}; %A list of operations to apply
   
    %could be 1, H, P, HP, PH, HPH.
   
    for k=1:n

       oper=this_sol{k};

       if strcmpi(oper,'H') || strcmpi(oper,'P')

           temp2 = temp2.Apply_Clifford(k,oper,n);

       elseif strcmpi(oper,'HP') %First P, then H

           temp2 = temp2.Apply_Clifford(k,'P',n);
           temp2 = temp2.Apply_Clifford(k,'H',n);

       elseif strcmpi(oper,'PH')

           temp2 = temp2.Apply_Clifford(k,'H',n);
           temp2 = temp2.Apply_Clifford(k,'P',n);

       elseif strcmpi(oper,'HPH')

           temp2 = temp2.Apply_Clifford(k,'H',n);
           temp2 = temp2.Apply_Clifford(k,'P',n);
           temp2 = temp2.Apply_Clifford(k,'H',n);
       %or 1, so we apply nothing.

       end


    end
    
    G2_test=Get_Adjacency(temp2.Tableau);
    
    if all(all(G2_test==G1))
       
        conds(jj)=true;
    else
        conds(jj)=false;
        
    end
    
    
end

% figure(1)
% subplot(3,1,1)
% plot(graph(G1))
% subplot(3,1,2)
% plot(graph(G2))
% subplot(3,1,3)
% plot(graph(G2_test))

if ~any(conds)
    
   %Try the sequence in reverse:
    for jj=1:length(str_sols)

        temp2=Tableau_Class(G2,'Adjacency');

        this_sol = str_sols{jj}; %A list of operations to apply
        
        for k=1:n
           
            if strcmpi(this_sol{k},'HP')
                this_sol{k}='PH';
            elseif strcmpi(this_sol{k},'PH')
                this_sol{k}='HP';
                
            end
            
        end
        
        %Could be 1, H, P, HP, PH, HPH.

        for k=1:n

           oper=this_sol{k};

           if strcmpi(oper,'H') || strcmpi(oper,'P')

               temp2 = temp2.Apply_Clifford(k,oper,n);

           elseif strcmpi(oper,'HP') %First P, then H

               temp2 = temp2.Apply_Clifford(k,'P',n);
               temp2 = temp2.Apply_Clifford(k,'H',n);

           elseif strcmpi(oper,'PH')

               temp2 = temp2.Apply_Clifford(k,'H',n);
               temp2 = temp2.Apply_Clifford(k,'P',n);

           elseif strcmpi(oper,'HPH')

               temp2 = temp2.Apply_Clifford(k,'H',n);
               temp2 = temp2.Apply_Clifford(k,'P',n);
               temp2 = temp2.Apply_Clifford(k,'H',n);
           %or 1, so we apply nothing.

           end


        end

        G2_test=Get_Adjacency(temp2.Tableau);

        if all(all(G2_test==G1))

            conds(jj)=true;
        else
            conds(jj)=false;

        end


    end
   
    if ~any(conds)
    
        error('Application of local gates does not give rise to correct adjacency.') 
        
    end
   
   
end

%--------- Otherwise, post-select 1 solution: -----------------------------
indx=find(conds,1);

str_sols=str_sols{indx};
temp2=Tableau_Class(G2,'Adjacency');

for k=1:n

   oper=str_sols{k};

   if strcmpi(oper,'H') 

       temp2 = temp2.Apply_Clifford(k,'H',n);
   elseif strcmpi(oper,'P')

       temp2 = temp2.Apply_Clifford(k,'P',n);
       
   elseif strcmpi(oper,'HP') %First P, then H

       temp2 = temp2.Apply_Clifford(k,'P',n);
       temp2 = temp2.Apply_Clifford(k,'H',n);

   elseif strcmpi(oper,'PH')

       temp2 = temp2.Apply_Clifford(k,'H',n);
       temp2 = temp2.Apply_Clifford(k,'P',n);

   elseif strcmpi(oper,'HPH')

       temp2 = temp2.Apply_Clifford(k,'H',n);
       temp2 = temp2.Apply_Clifford(k,'P',n);
       temp2 = temp2.Apply_Clifford(k,'H',n);
   %or 1, so we apply nothing.

   end


end

G2_test=Get_Adjacency(temp2.Tableau);



%--------------------------------------------------------------------------

G1=double(G1);
G2=double(G2);
G2_test=double(G2_test);
subplot(3,1,1)
plot(graph(G1))
title('G1')
subplot(3,1,2)
plot(graph(G2))
title('G2')
subplot(3,1,3)
plot(graph(G2_test))
title('After application of LCs on G2')





end