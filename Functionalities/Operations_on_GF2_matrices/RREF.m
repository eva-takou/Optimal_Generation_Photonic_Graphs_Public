function Tab=RREF(Tab,n)
%Function to put the matrix into RREF (w/o backsubstitution)
%Input: Tab:Tableau
%       n: # of qubits
%Output: The updated Tableau.


Active_Region_Start_Row = 1;
Active_Region_Start_Col = 1;
Active_Region_End_Row   = n;
Active_Region_End_Col   = n;

KU = Active_Region_Start_Row;   %This counter changes
NL = Active_Region_Start_Col;   %and this counter changes
K  = Active_Region_End_Row; 
N  = Active_Region_End_Col; 

FLAG=0;


while FLAG==0

    
    if NL>N || KU>K

        break

    end                
                                 
    %Fastest way to access the active region is first column-wise and then
    %row-wise.
    subTabZ = Tab(:,NL+n);
    subTabX = Tab(:,NL);
    
    subTabZ = subTabZ(KU:K);
    subTabX = subTabX(KU:K);
    
    flag    = [false,false];
    
    Zpos = subTabZ>0; %Fast comparison for int8
    Xpos = subTabX>0;
    
    if sum(subTabZ)==0 
        
        
        Pauli_Pos_Z=[];
        flag(1)=true;
        
    else %there are Zs

        
        %Pauli_Pos_Z = find(subTabX==0   &  subTabZ==1,1);
        
        Pauli_Pos_Z = find(~Xpos  &  Zpos,1);
        
    end
    
    if sum(subTabX)==0 
        
        Pauli_Pos_X=[];
        flag(2)=true;
        
        
    else
       
        %Pauli_Pos_X = find( subTabX==1   & subTabZ==0,1);
    
        Pauli_Pos_X = find( Xpos   & ~Zpos,1);
        
    end
    
    if all(flag)
        
        NL=NL+1;
        continue
        
    else
        

        Pauli_Pos_Y = find( Xpos   &  Zpos,1); 
        %Pauli_Pos_Y = find( subTabX   &  subTabZ,1); 
        onlyY       = isempty([Pauli_Pos_X,Pauli_Pos_Z]);   
        
    end

    
    if any(flag) || onlyY   %onlyX || onlyY || onlyZ %Only 1 kind of Pauli Operator for this qubit
        
        %The above is true if we have true,false  -> onlyX
        %                             false,true  -> onlyZ
        %If it is false,false, we need to also test onlyY
        
        k = [Pauli_Pos_X;Pauli_Pos_Y;Pauli_Pos_Z]; %only 1 out of 3 kinds will be non-empty
        k = k + (KU-1); %We redefine k because in the find command the first row is KU.
                        %e.g. if KU=4 and k=2, then k is actually 4+(2-1)=5th row of the stabs
                 
        if k~=KU  %SWAP if necessary:

            Tab = SWAP_rows(Tab,k,KU); %SWAP stabs 
            
        end
        
        for ll=(KU+1):K %Multiply row KU with all other rows in the active
                                  %region that have the same Pauli in column NL.
                                  
            xi = Tab(ll,NL);  zi=Tab(ll,NL+n);

            if  xi>0 || zi>0
                
                Tab = rowsum(Tab,n,ll,KU); %Stab update
                
            end
            
        end
        

        NL = NL+1;
        KU = KU+1;
        
    
        

    else %>=2 kinds of operators XY, YZ, XZ or XZY.

        temp    = [Pauli_Pos_X;Pauli_Pos_Z;Pauli_Pos_Y];
        %temp    = sort(temp); %If we don't sort, we might exchange k1 with k2 positions.
        %k1      = temp(1);    %Pick 1st occurence of non-trivial pauli
        %k2      = temp(2);
        k1 = min(temp); %For unsorted we need to pick min/max
        k2 = max(temp);
        
        if (k1==Pauli_Pos_X) %ismember(k1,indx_X)
            
            flag1 = 'X';
            
            if (k2==Pauli_Pos_Y) %ismember(k2,indx_Y)
                
                flag2='Y';
                
            else
                
                flag2='Z';
                
            end
            

        elseif (k1==Pauli_Pos_Y) %ismember(k1,indx_Y)
            
            flag1='Y';
            
            if (k2==Pauli_Pos_X) %ismember(k2,indx_X)
                
                flag2='X';
                
            else
                
                flag2='Z';
                
            end
                
        elseif (k1==Pauli_Pos_Z) %ismember(k1,indx_Z)
            
            flag1='Z';
            
            if (k2==Pauli_Pos_X) %ismember(k2,indx_X)
                
                flag2='X';
                
            else
                
                flag2='Y';
                
            end
            
            
        end

        k1=k1+(KU-1); 
        k2=k2+(KU-1);

        if k1~=KU %SWAP if necessary:

            Tab = SWAP_rows(Tab,k1,KU);
            

        end


        if k2~=(KU+1)

            Tab = SWAP_rows(Tab,k2,(KU+1));
            

        end

    
        
        for row=KU+2:K %Multiply all other rows in the active region either 
                       %with row KU,row KU+1, both or none, depending on their element
                       
            xi = Tab(row,NL); 
            zi = Tab(row,NL+n);

            if xi==1 && zi==0 

                if flag1=='X'

                    
                    Tab=rowsum(Tab,n,row,KU);  %Stab update

                elseif flag2=='X'

                    
                    Tab=rowsum(Tab,n,row,(KU+1)); %Stab update

                elseif flag1=='Y' && flag2=='Z' %First rowsum with KU and then with KU+1
                    
                    
                    Tab=rowsum(Tab,n,row,KU);
                    Tab=rowsum(Tab,n,row,(KU+1));

                elseif flag1=='Z' && flag2=='Y' %First rowsum with KU+1 and then with KU

                    Tab=rowsum(Tab,n,row,(KU+1));                    
                    Tab=rowsum(Tab,n,row,KU);

                end

            elseif xi==1 && zi==1

                if flag1=='Y'

                    Tab=rowsum(Tab,n,row,KU);

                elseif flag2=='Y'

                    
                    Tab=rowsum(Tab,n,row,(KU+1));

                elseif (flag1=='X' && flag2=='Z')  || (flag1=='Z' && flag2=='X')

                    
                    Tab=rowsum(Tab,n,row,KU);
                    Tab=rowsum(Tab,n,row,(KU+1));

                end


            elseif xi==0 && zi==1

                if flag1=='Z'

                    
                    Tab=rowsum(Tab,n,row,KU);
                    
                elseif flag2=='Z'

                    Tab=rowsum(Tab,n,row,(KU+1));

                elseif flag1=='X' && flag2=='Y'  %First with Y and then with X
                
                    Tab = rowsum(Tab,n,row,(KU+1));
                    Tab = rowsum(Tab,n,row,KU);

                elseif flag1=='Y' && flag2=='X' %First with Y and then with X

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