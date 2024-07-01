function Verify_Circuit_Forward_Order(Circ,Adj0,ne,CircuitOrder)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 1, 2024
%
%Function to verify that a circuit produces a target photonic graph. We
%verify the circuit in forward order.
%
%Input: Circ: A struct with fields .Gate.name and .Gate.qubit
%       Adj0: The target adjacency matrix
%       ne: # of emitter qubits
%       CircuitOrder: The order of the input circuit

Gates  = Circ.Gate.name;
Qubits = Circ.Gate.qubit;

if strcmpi(CircuitOrder,'backward')
    
    for k=1:length(Gates)
        
        if strcmpi(Gates{k},'P')
           
            Gates{k}='Pdag';
            
        end
        
    end
    
    %Need to also add an H gate on the control emitter after the 'Measure'
    
    Gates  = flip(Gates);
    Qubits = flip(Qubits);
    
    loc_TRM = [];
    
    for k=1:length(Gates)
        
       if strcmpi(Gates{k},'Measure')
          
           loc_TRM = [loc_TRM,k];
           
       end
        
    end
    
    for l = 1:length(loc_TRM)
       
        Gates   = [Gates(1:loc_TRM(l)),'H',Gates(loc_TRM(l)+1:end)];
        Qubits  = [Qubits(1:loc_TRM(l)),Qubits{loc_TRM(l)}(1),Qubits(loc_TRM(l)+1:end)];
        loc_TRM = loc_TRM+1;
        
    end
    
    Gates  = flip(Gates);
    Qubits = flip(Qubits);
    
    Lstart = length(Gates);
    Lstep  = -1;
    Lend   = 1;
    
else    
    
    Lstart = 1;
    Lstep  = 1;
    Lend   = length(Gates);
    
end

np = length(Adj0);
n  = np+ne;

temp0 = Tableau_Class(zeros(np,np),'Adjacency'); %Sx=1, Sz=0

for k=1:np
   
    temp0=temp0.Apply_Clifford(k,'H',np);  %Sz=1, Sx=0.
    
end

temp0.Tableau = AugmentTableau(temp0.Tableau,ne); %Sz=1, Sx=0. (Augmented with emitters)

for k=Lstart:Lstep:Lend
   
    G = Gates{k};
    Q = Qubits{k};
    
    if strcmpi(G,'Measure')
       
        [temp0,outcome] = temp0.Apply_SingleQ_Meausurement(Q(1),'Z'); %qubit,basis
        
        if outcome == 1
           
            temp0 = temp0.Apply_Clifford(Q(2),'X',n);
            
        end
        
    else
        
        temp0 = temp0.Apply_Clifford(Q,G,n); %qubit,Oper,n
        
    end
    
end

Adj_T     = Get_Adjacency(temp0.Tableau);
to_remove = [];

for k=1:length(Adj_T)
   
    if all(Adj_T(k,:)==0)
       
        to_remove=[to_remove,k];
    end
    
end

Adj_T(to_remove,:) = [];
Adj_T(:,to_remove) = [];

if ~all(all(Adj_T==Adj0))
   
    error('The circuit does not produce the target graph.')
    
end

end