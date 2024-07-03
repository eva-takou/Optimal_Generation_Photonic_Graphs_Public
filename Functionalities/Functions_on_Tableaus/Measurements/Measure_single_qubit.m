function [Tab,outcome,type_of_outcome]=Measure_single_qubit(Tab,qubit,basis)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 3, 2024
%--------------------------------------------------------------------------
%
%Function to measure a qubit from the tableau. This script applies the
%algorithm of Aaronson and Gottesman
%https://arxiv.org/pdf/quant-ph/0406196.
%Because the Tableau Class does not contain the destabilizers, we cannot
%extract the determinate outcome based on the method in the paper. 
%However, for deterministic outcome we know that the measurement operator
%is an element of the Stab group. Thus, by performing Gaussian elimination
%we can recover an operator II...Z...II with a \pm sign and then find the
%outcome.
%
%
%The Pauli basis measurement operators are:
%Pz_{\pm} = 1/2(I2 \pm Z)
%Px_{\pm} = 1/2(I2 \pm X)
%Py_{\pm} = 1/2(I2 \pm Y)
%
%We can write Px and Py in terms of Pz as follows:
%Px_{\pm} = (H)          * Pz_{\pm} * (H)^dagger
%Py_{\pm} = (P.H) * Pz_{\pm} * (P.H)^dagger
%
%
%Input: Tab: The tableau
%       qubit: the qubit to be measured
%       basis: 'X', or 'Y' or 'Z' basis measurement
%Output: Tab: The updated tableau (n x 2n+1 array)
%        outcome: The outcome (0 or 1) after the measurement
%        type_of_outcome: 'determinate' or 'random'


n = (size(Tab,2)-1)/2;

switch basis

    case 'X'

        Tab = Had_Gate(Tab,qubit,n);
        

    case 'Y' %Py_{\pm} = (P.H) * Pz_{\pm} * (P.H)^dagger
        
        Tab = Phase_Gate(Tab,qubit,n); 
        Tab = Pauli_Gate(Tab,qubit,n,'Z'); %Together with the above it is Pdagger
        Tab = Had_Gate(Tab,qubit,n);
        
end
  
%Apply the Aaronson and Gottesman algorithm:

p = find(Tab(:,qubit)); %find if there is nnz X part for that qubit

if ~isempty(p)
    
    type_of_outcome = 'Random';
    outcome         = randi([0,1],'int8');
    q               = p(1);
    
    for l=2:length(p)

        Tab = rowsum(Tab,n,p(l),q);

    end

    %Now only 1 operator anti-commutes with the measurement

    Tab(q,:)       = zeros(1,2*n+1,'int8');
    Tab(q,qubit+n) = int8(1);
    Tab(q,end)     = outcome;
        
else 
    
    disp('Outcome: determinate')
    type_of_outcome = 'determinate';
    
    Tab_test = Gauss_elim_GF2_with_rowsum(Tab,n);
    loc      = find(Tab_test(:,qubit+n));
    
    for l=1:length(loc)
       
        if nnz(Tab_test(loc(l),1:2*n))
            
            outcome = Tab_test(loc(l),end);
            
        end
        
    end
    
    if strcmpi(basis,'Z')
    
        disp(['--------- Outcome for Z basis was: ',num2str(outcome)])

    elseif strcmpi(basis,'X')
        
        disp(['--------- Outcome for X basis was: ',num2str(outcome)])
        
    elseif strcmpi(basis,'Y')
        
        disp(['--------- Outcome for Y basis was: ',num2str(outcome)])
        
    end
end

%Rotate back:

switch basis

    case 'X'

        Tab = Had_Gate(Tab,qubit,n);

    case 'Y' %Py_{\pm} = (P.H) * Pz_{\pm} * (P.H)^dagger
        
        Tab = Had_Gate(Tab,qubit,n);
        Tab = Phase_Gate(Tab,qubit,n);
        
end


end