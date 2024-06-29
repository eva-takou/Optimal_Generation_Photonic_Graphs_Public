function [Gates,Qubits]=cancel_out_gates(Gates,Qubits,n)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: June 29, 2024

%Script to cancel out consecutive gates that give rise to identity, or 
%to transform consecutive P gates to Z.
%
%Input: Gates: A cell array with the gate names as char e.g. 'H', 'CNOT' etc
%       Qubits: A cell array with the indices of the qubits on which the
%       gates act
%       n: # of qubits

for jj = 1:n 
   
    locs_Q = [];

    for kk = 1:length(Gates)

        if any(Qubits{kk}==jj)
            
            locs_Q=[locs_Q,kk];

        end

    end

    %If we have \sigma_j^2 or H^2, this gives 1.
    %If we have P^2, this gives Z.
    
    %----------- Check two subsequent gates -------------------------------
    for p = 1:length(locs_Q)-1

        gate1 = Gates{locs_Q(p)};  
        gate2 = Gates{locs_Q(p+1)};
        
        if length(Qubits{locs_Q(p)})==1 %Single qubit gate: (X,Y,Z,P,H)
            
            if strcmpi(gate1,gate2) && ~strcmpi(gate2,'P') %Identity

                Gates{locs_Q(p)}    = [];
                Gates{locs_Q(p+1)}  = [];
                Qubits{locs_Q(p)}   = [];
                Qubits{locs_Q(p+1)} = [];
                
            elseif (strcmpi(gate1,'P') && strcmpi(gate2,'Pdag')) ...
                                      || ...
                   (strcmpi(gate1,'Pdag') && strcmpi(gate2,'P'))                   
                
                Gates{locs_Q(p)}    = [];
                Gates{locs_Q(p+1)}  = [];
                Qubits{locs_Q(p)}   = [];
                Qubits{locs_Q(p+1)} = [];
                
            elseif strcmpi(gate1,gate2) && strcmpi(gate2,'P') %Z

                Gates{locs_Q(p)}    = [];
                Qubits{locs_Q(p)}   = [];
                Gates{locs_Q(p+1)}  = 'Z'; 
                
            elseif strcmpi(gate1,gate2) && strcmpi(gate2,'Pdag') %Z

                Gates{locs_Q(p)}    = [];
                Qubits{locs_Q(p)}   = [];
                Gates{locs_Q(p+1)}  = 'Z';                 
                
            end
            
        end

    end

    
    [Gates,Qubits] = remove_empty_slots(Gates,Qubits);
    
    locs_Q = [];

    for kk = 1:length(Gates)

        if any(Qubits{kk}==jj)
            
            locs_Q=[locs_Q,kk];

        end

    end
    
    %We could also have: 1) (IP)*CZ*(IP)=CZ*IZ
    %                    2) (PI)*CZ*(PI)=CZ*ZI
    %                    3) (ZI)*CZ*(ZI)=CZ
    %                    4) (IZ)*CZ*(IZ)=CZ
    %                    5) (ZI)*CNOT*(ZI)=CNOT
    %                    6) (PI)*CNOT*(PI)=CNOT
    %                    7) (IX)*CNOT*(IX)=CNOT
    
    %----------- Check three subsequent gates -----------------------------
    for p = 1:length(locs_Q)-2

        gate1 = Gates{locs_Q(p)};
        gate2 = Gates{locs_Q(p+1)};
        gate3 = Gates{locs_Q(p+2)};

        if strcmpi(gate1,'P') && strcmpi(gate2,'CZ') && strcmpi(gate3,'P') %covers 1 and 2

            Gates{locs_Q(p)}   = [];
            Qubits{locs_Q(p)}  = [];
            Gates{locs_Q(p+2)} = 'Z';
            
        elseif strcmpi(gate1,'Pdag') && strcmpi(gate2,'CZ') && strcmpi(gate3,'Pdag')

            Gates{locs_Q(p)}   = [];
            Qubits{locs_Q(p)}  = [];
            Gates{locs_Q(p+2)} = 'Z';
            
        elseif strcmpi(gate1,'Z') && strcmpi(gate2,'CZ') && strcmpi(gate3,'Z') %covers 3 and 4

            Gates{locs_Q(p)}   = [];
            Qubits{locs_Q(p)}  = [];

            Gates{locs_Q(p+2)}   = [];
            Qubits{locs_Q(p+2)}  = [];
            
        elseif (strcmpi(gate1,'Z') && strcmpi(gate2,'CNOT') && strcmpi(gate3,'Z')) ...
                                            || ...
               (strcmpi(gate1,'P') && strcmpi(gate2,'CNOT') && strcmpi(gate3,'P')) ... %covers 5 and 6
                                            || ...
               (strcmpi(gate1,'Pdag') && strcmpi(gate2,'CNOT') && strcmpi(gate3,'Pdag'))                                        \
           
            if Qubits{locs_Q(p+1)}(1)==jj %qubit (jj) has to be the control
               
                Gates{locs_Q(p)}   = [];
                Qubits{locs_Q(p)}  = [];

                Gates{locs_Q(p+2)}   = [];
                Qubits{locs_Q(p+2)}  = [];
                
            end
    
        elseif strcmpi(gate1,'X') && strcmpi(gate2,'CNOT') && strcmpi(gate3,'X') %covers 7
            
            if Qubits{locs_Q(p+1)}(2)==jj %qubit (jj) has to be the target

                Gates{locs_Q(p)}   = [];
                Qubits{locs_Q(p)}  = [];

                Gates{locs_Q(p+2)}   = [];
                Qubits{locs_Q(p+2)}  = [];
                
            end
            
        end

    end

    [Gates,Qubits]=remove_empty_slots(Gates,Qubits);

end

end