function Tab=RREF(Tab,n)
%Function to put the matrix into RREF (w/o backsubstitution)
%Input: Tab:Tableau
%       n: # of qubits
%Output: The updated Tableau.


KU = 1; %Active_Region_Start_Row
NL = 1; %Active_Region_Start_Col
K  = n; %Active_Region_End_Row
N  = n; %Active_Region_End_Col

while true
    
    if NL>N || KU>K

        break

    end                
                                 
    %Fastest way to access the active region is first column-wise and then
    %row-wise.
    
    subTabX = Tab(:,NL);
    subTabZ = Tab(:,NL+n);
    
    subTabX = subTabX(KU:end);
    subTabZ = subTabZ(KU:end);
    
    Ys          = bitand(subTabZ,subTabX);
    Pauli_Pos_Y = find(Ys,1);
    
    %Remove Ys
    subTabZ = bitxor(subTabZ,Ys); 
    subTabX = bitxor(subTabX,Ys);
      
   if sum(subTabX)==0
      
       Pauli_Pos_X=[];
       
   else
       
       Pauli_Pos_X=find(subTabX,1);
       
   end
    
    
   if sum(subTabZ)==0
        
        Pauli_Pos_Z=[];
        
   else
       
        Pauli_Pos_Z=find(subTabZ,1);
        
    end

    k = [Pauli_Pos_X,Pauli_Pos_Y,Pauli_Pos_Z];
    
    if isempty(k)
        NL=NL+1;
        continue
    end

    if length(k)==1 %Only 1 kind of Pauli Operator for this qubit

        k = k + (KU-1); %We redefine k because in the find command the first row is KU.
                        %e.g. if KU=4 and k=2, then k is actually 4+(2-1)=5th row of the stabs
                        
        if k~=KU  %SWAP if necessary:

            temp = Tab(k,:);
            Tab(k,:)=Tab(KU,:);
            Tab(KU,:)=temp;

        end
        
        for ll=(KU+1):K %Multiply row KU with all other rows in the active
                                  %region that have the same Pauli in column NL.
                                  
            xi = Tab(ll,NL);  zi=Tab(ll,NL+n);

            if  xi+zi>0 %non-identity 
                
                Tab = rowsum(Tab,n,ll,KU); %Stab update
                
            end
            
        end
       
        NL = NL+1;
        KU = KU+1;
    
    else %>=2 kinds of operators XY, YZ, XZ or XZY.

        %temp    = [Pauli_Pos_X;Pauli_Pos_Z;Pauli_Pos_Y];
        %temp    = sort(temp); %If we don't sort, we might exchange k1 with k2 positions.
        %k1      = temp(1);    %Pick 1st occurence of non-trivial pauli
        %k2      = temp(2);
        k1 = min(k); %For unsorted we need to pick min/max
        k2 = max(k);
        
        if (k1==Pauli_Pos_X) 
            
            flag1 = 'X';
            
            if (k2==Pauli_Pos_Y) 
                
                flag2='Y';
                
            else
                
                flag2='Z';
                
            end
            

        elseif (k1==Pauli_Pos_Y) 
            
            flag1='Y';
            
            if (k2==Pauli_Pos_X) 
                
                flag2='X';
                
            else
                
                flag2='Z';
                
            end
                
        elseif (k1==Pauli_Pos_Z) 
            
            flag1='Z';
            
            if (k2==Pauli_Pos_X) 
                
                flag2='X';
                
            else
                
                flag2='Y';
                
            end
            
            
        end

        k1=k1+(KU-1); 
        k2=k2+(KU-1);

        if k1~=KU %SWAP if necessary:

            temp = Tab(k1,:);
            Tab(k1,:)=Tab(KU,:);
            Tab(KU,:)=temp;
            
        end


        if k2~=(KU+1)

            
            temp = Tab(k2,:);
            Tab(k2,:)=Tab(KU+1,:);
            Tab(KU+1,:)=temp;
        
        end

        for row=KU+2:K %Multiply all other rows in the active region either 
                       %with row KU,row KU+1, both or none, depending on their element
                       
            xi = Tab(row,NL); 
            zi = Tab(row,NL+n);

            if xi==1 && zi==1 %Ylocation detected

                if flag1=='Y'

                    Tab=rowsum(Tab,n,row,KU);

                elseif flag2=='Y'

                    
                    Tab=rowsum(Tab,n,row,(KU+1));

                else %if (flag1=='X' && flag2=='Z')  || (flag1=='Z' && flag2=='X')

                    
                    Tab=rowsum(Tab,n,row,KU);
                    Tab=rowsum(Tab,n,row,(KU+1));

                end


            elseif xi==1 %X location detected

                if flag1=='X'

                    
                    Tab=rowsum(Tab,n,row,KU);  %Stab update

                elseif flag2=='X'

                    
                    Tab=rowsum(Tab,n,row,(KU+1)); %Stab update

                elseif flag1=='Y' %&& flag2=='Z' %First rowsum with KU and then with KU+1
                    
                    
                    Tab=rowsum(Tab,n,row,KU);
                    Tab=rowsum(Tab,n,row,(KU+1));

                elseif flag1=='Z' %&& flag2=='Y' %First rowsum with KU+1 and then with KU

                    Tab=rowsum(Tab,n,row,(KU+1));                    
                    Tab=rowsum(Tab,n,row,KU);

                end



            elseif zi==1 %Z location detected

                if flag1=='Z'

                    
                    Tab=rowsum(Tab,n,row,KU);
                    
                elseif flag2=='Z'

                    Tab=rowsum(Tab,n,row,(KU+1));

                elseif flag1=='X' %&& flag2=='Y'  %First with Y and then with X
                
                    Tab = rowsum(Tab,n,row,(KU+1));
                    Tab = rowsum(Tab,n,row,KU);

                elseif flag1=='Y' %&& flag2=='X' %First with Y and then with X

                    Tab = rowsum(Tab,n,row,KU);
                    Tab = rowsum(Tab,n,row,(KU+1));                                

                end


            end
            
        end

        NL=NL+1; %next qubit
        KU=KU+2; %+2 rows.

    end


end



end