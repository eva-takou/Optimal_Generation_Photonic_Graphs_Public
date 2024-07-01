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


if strcmpi(CircuitOrder,'backward')
   
    Gates  = Circ.Gate.name;
    Qubits = flip(Circ.Gate.qubit);
    
    for k=1:length(Gates)
        
        if strcmpi(Gates{k},'P')
           
            Gates{k}='Pdag';
            
        end
        
    end
    
    Gates = flip(Gates);
    
else
    
    Gates  = Circ.Gate.name;
    Qubits = Circ.Gate.qubit;
    
end

np = length(Adj0);
n  = np+ne;

temp0 = Tableau_Class(zeros(np,np),'Adjacency'); %Sx=1, Sz=0

for k=1:np
   
    temp0=temp0.Apply_Clifford(k,'H',np);  %Sz=1. Sx=0.
    
end

temp0.Tableau=AugmentTableau(temp0.Tableau,ne);

for k=1:length(Gates)
   
    G = Gates{k};
    Q = Qubits{k};
    
    if strcmpi(G,'Measure')
       
        temp0 = temp0.Apply_SingleQ_Meausurement(Q(1),'Z');
        
    else
        
        temp0 = temp0.Apply_Clifford(Q,G,n);
        
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

figure(1)
subplot(1,2,1)
plot(graph(Adj_T))
subplot(1,2,2)
plot(graph(double(Adj0)))

if ~all(all(Adj_T==Adj0))
   
    error('The circuit does not produce the target graph.')
    
end


end