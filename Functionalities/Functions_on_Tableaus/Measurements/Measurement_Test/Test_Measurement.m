clear;
close all;
clc;
warning('on')

repeat_test    = 100;
Gates_Iter_Max = 100;
n              = 8;
ketP           = [1;1]/sqrt(2);

for K=1:repeat_test


    Adj = create_random_graph(n);

    %---------- Create corresponding graph state -------------------------
    psi = ketP;
    for l=1:n-1

        psi = kron(ketP,psi);

    end

    for m=1:n

        for l=m+1:n

            if Adj(m,l)==1

                psi = CZ(m,l,n)*psi;
                
            end
            
        end

    end
    %----------------------------------------------------------------------

    %-------------- Act with random Clifford Gates -----------------------
    
    
    Gates  = {'H','P','CNOT'};
    Qubits = 1:n;

    temp = Tableau_Class(Adj,'Adjacency');

    for iter=1:Gates_Iter_Max

        indx_G = randi([1,3]);
        Oper   = Gates{indx_G};

        if indx_G == 3

            indx_Q1 = randi([1,n]);

            indx_Q2 = randi([1,n]);

            while indx_Q2==indx_Q1

                indx_Q2 = randi([1,n]);

            end

            if indx_Q2==indx_Q1
               error('check again') 

            end

            qubit = [indx_Q1,indx_Q2];


        else

            qubit = randi([1,n]);


        end    

        if strcmpi(Oper,'CNOT')

            psi = CNOT(qubit(1),qubit(2),n)*psi;

        else
            psi = single_gate(qubit,n,Oper,psi);

        end

        temp = temp.Apply_Clifford(qubit,Oper,n); 

    end

    %----------------------------------------------------------------------

    %---------- Measure all qubits sequentially in random bases -----------
    
    for l=1:n

        p = randi([1,3]);

        if p==1

            basis='Z';

        elseif p==2

            basis = 'Y';

        elseif p == 3

            basis = 'X';

        end

        Qubit = l;

        [temp,outcome,type_of_outcome] = temp.Apply_SingleQ_Meausurement(Qubit,basis);

        if strcmpi(type_of_outcome,'Random')

            [prob_P,prob_M,Proj1,Proj2]=measure_state(psi,n,Qubit,basis);

            if abs(prob_P-1/2)>1e-9 || abs(prob_M-1/2)>1e-9
               error('Some error in random outcome') 
            end

            if outcome==0

                psi = Proj1*psi;

            else

                psi = Proj2*psi;

            end

            psi = psi/norm(psi);

        end


        if strcmpi(type_of_outcome,'determinate')

            [prob_P,prob_M,Proj1,Proj2]=measure_state(psi,n,Qubit,basis);

            if prob_P==prob_M
               error('Probabilities found equal') 
            end

            if abs(prob_P-1)<1e-9

                disp(['------ Outcome from state vec:',num2str(0)])

            else
                disp(['------ Outcome from state vec:',num2str(1)])
            end

            if (isnan(prob_P) && abs(prob_M-1)<1e-9) || (isnan(prob_M) && abs(prob_P-1)<1e-9)

                disp('Deterministic prob ok.')

            else
                error('Deterministic prob not ok.')

            end

            if outcome == 0 && abs(prob_M-1)<1e-9

                error('Outcome from stabs is incorrect')

            elseif outcome ==1 && abs(prob_P-1)<1e-9

                error('Outcome from stabs is incorrect')

            end


        end

    end


end
