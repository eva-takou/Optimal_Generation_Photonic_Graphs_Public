function [encountered_warning,Tab_new]=Verify_Circuit_Forward_Order(Circ,Adj0,ne,CircuitOrder)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 16, 2024
%
%Function to verify that a circuit produces a target photonic graph. We
%verify the circuit in forward order. The Measurement is simulated as an
%actual measurement.
%
%Input: Circ: A struct with fields .Gate.name and .Gate.qubit
%       Adj0: The target adjacency matrix
%       ne: # of emitter qubits
%       CircuitOrder: The order of the input circuit

if strcmpi(CircuitOrder,'backward')
    
    Circ = put_circuit_forward_order(Circ);
    
end

Gates  = Circ.Gate.name;
Qubits = Circ.Gate.qubit;
Lstart = 1;
Lstep  = 1;
Lend   = length(Gates);

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

        [temp0,outcome] = temp0.Apply_SingleQ_Meausurement(Q(1),'Z');
         
        if outcome==1
           
            temp0 = temp0.Apply_Clifford(Q(1),'X',n); %Put emitter in |0> again
            temp0 = temp0.Apply_Clifford(Q(2),'X',n); %Feed-forward correction on photon
            
        end
        
    else
        
        temp0 = temp0.Apply_Clifford(Q,G,n); %qubit,Oper,n
        
    end
    
end

Tab = temp0.Tableau;

%------- Check that emitters are decoupled, whereas photons are not -------

for photon=1:np
   
    cond_prod = qubit_in_product(Tab,n,photon);
    
    if cond_prod
        error('Photon was found decoupled at the end of the forward generation.')
    end
    
    
end

for emitter = np+1:n
   
    [cond_prod,state_flag] = qubit_in_product(Tab,n,emitter);
    
    if ~cond_prod
       error('Emitter was found still coupled to photons at the end of the forward generation.') 
    end
    
    if ~strcmpi(state_flag,'Z')
       error('The emitter was not found in |0> state at the end of the forward generation.') 
    end
    
end

Tab_new = to_Canonical_Form(Tab);
Tab_new = Gauss_elim_GF2_with_rowsum(Tab_new,n);
S       = Tab_To_String(Tab_new);

for l=1:np
   
    if ~strcmpi(S{l}(1),'+')
       
        encountered_warning = true;
        warning('Negative phase detected. To fix the phase call fix_potential_phases_forward_circuit.')
        break

    else
        
        encountered_warning = false;
        
    end
    
end

%------- Check the adjacency matrix ---------------------------------------

Adj_T     = Get_Adjacency(Tab);
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