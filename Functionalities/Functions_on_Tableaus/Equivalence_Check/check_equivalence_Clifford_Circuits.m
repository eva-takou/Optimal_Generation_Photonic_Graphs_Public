function bool=check_equivalence_Clifford_Circuits(Circuit1,Circuit2,CircuitOrder)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 4, 2024
%
%Script to test if two Clifford circuits are equivalent up to a global
%phase. Method based on: https://arxiv.org/abs/2308.01206.
%
%Input: Circuit1: A struct with field Gate and subfield name and qubit.
%       Circuit2: A struct with field Gate and subfield name and qubit.  
%Output: bool: true or false answer for the equivalence check

Qubits1 = Circuit1.Gate.qubit;
Qubits2 = Circuit2.Gate.qubit;

n1 = max([Qubits1{:}]);
n2 = max([Qubits2{:}]);

if n1~=n2 %Circuits do not contain the same # of qubits
    
    bool=false;
    return
end

if strcmpi(CircuitOrder,'backward')
    
    Circuit1 = put_circuit_forward_order(Circuit1);
    Circuit2 = put_circuit_forward_order(Circuit2);
    
end

Qubits1 = Circuit1.Gate.qubit;
Qubits2 = Circuit2.Gate.qubit;
Gates1  = Circuit1.Gate.name;
Gates2  = Circuit2.Gate.name;


n = n1;

Stabs_Zs = [zeros(n,n,'int8'),eye(n,'int8')]; %Initial state of |0>^{\otimes n}
temp0    = Tableau_Class(Stabs_Zs,'Stabs');

temp1_Z = temp0;
temp2_Z = temp0;

for k=1:length(Gates1)
    
    G = Gates1{k};
    Q = Qubits1{k};
    
    if strcmpi(G,'Measure')
       
        [temp1_Z,outcome] = temp1_Z.Apply_SingleQ_Meausurement(Q(1),'Z');
        
        if outcome==1
           
            temp1_Z = temp1_Z.Apply_Clifford(Q(2),'X',n);
            
        end        
        
    else
        
        temp1_Z = temp1_Z.Apply_Clifford(Q,G,n);
        
    end
    
end


for k=1:length(Gates2)
    
    G = Gates2{k};
    Q = Qubits2{k};
    
    if strcmpi(G,'Measure')
       
        [temp2_Z,outcome] = temp2_Z.Apply_SingleQ_Meausurement(Q(1),'Z');
        
        if outcome==1
           
            temp2_Z = temp2_Z.Apply_Clifford(Q(2),'X',n);
            
        end          
        
    else
        
        temp2_Z = temp2_Z.Apply_Clifford(Q,G,n);
        
    end
    
end


Tab1 = temp1_Z.Tableau;
Tab2 = temp2_Z.Tableau;

for m=1:n
   
    check_Z = all(Tab1(m,1:2*n)==Tab2(m,1:2*n));
    
    if ~check_Z
       
        bool=false;
        return
        
    end
    
end

%---- Uncomment this if you want to visualize the graphs ------------------
% Adj1 = Get_Adjacency(Tab1);
% Adj2 = Get_Adjacency(Tab2);
% 
% figure(1)
% subplot(2,1,1)
% plot(graph(Adj1))
% subplot(2,1,2)
% plot(graph(Adj2))
% pause(1)


%----------- Test of the X string -----------------------------------------


Stabs_Xs = [eye(n,'int8'),zeros(n,n,'int8')]; %Initial state of |+>^{\otimes n}
temp0    = Tableau_Class(Stabs_Xs,'Stabs');

temp1_X = temp0;
temp2_X = temp0;




for k=1:length(Gates1)
    
    G = Gates1{k};
    Q = Qubits1{k};
    
    if strcmpi(G,'Measure')
       
        [temp1_X,outcome] = temp1_X.Apply_SingleQ_Meausurement(Q(1),'Z');
        
        if outcome==1
           
            temp1_X = temp1_X.Apply_Clifford(Q(2),'X',n);
            
        end
        
    else
        
        temp1_X = temp1_X.Apply_Clifford(Q,G,n);
        
    end
    
end


for k=1:length(Gates2)
    
    G = Gates2{k};
    Q = Qubits2{k};
    
    if strcmpi(G,'Measure')
       
        [temp2_X,outcome] = temp2_X.Apply_SingleQ_Meausurement(Q(1),'Z');
        
        if outcome==1
           
            temp2_X = temp2_X.Apply_Clifford(Q(2),'X',n);
            
        end
        
    else
        
        temp2_X = temp2_X.Apply_Clifford(Q,G,n);
        
    end
    
end


Tab1 = temp1_X.Tableau;
Tab2 = temp2_X.Tableau;

for m=1:n
   
    check_X = all(Tab1(m,1:2*n)==Tab2(m,1:2*n));
    
    if ~check_X
       
        bool=false;
        return
        
    end
    
end

bool = true;


end