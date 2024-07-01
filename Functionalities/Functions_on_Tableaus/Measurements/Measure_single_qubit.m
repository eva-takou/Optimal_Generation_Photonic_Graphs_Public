function [Tab,outcome]=Measure_single_qubit(Tab,qubit,basis)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 1, 2024
%--------------------------------------------------------------------------
%
%Function to measure a qubit from the tableau. This script applies the
%algorithm of Aaronson and Gottesman
%https://arxiv.org/pdf/quant-ph/0406196.
%Because the Tableau Class does not contain the destabilizers, we cannot
%extract the determinate outcome. The update of stabilizer under the random
%outcome can be done w/o destabilizers.
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
%Input: Tab: The tableau
%       qubit: the qubit to be measured
%       basis: 'X', or 'Y' or 'Z' basis measurement
%Output: Tab: The updated tableau
%        outcome: The outcome (0 or 1) after the measurement.

warning('Tableau does not contain destabs. The determinate outcome cannot be found.')

n=size(Tab,1);

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
    
    disp('Outcome: Random')
    %S=<g_1,...,g_n> and some of them have x=1 for the qubit
    %so the measurement \pm Z anti-commutes with any operator that has X on
    %the qubit. Select just one of these operator g_i that has an X.
    %Do rowsum between g_i and all other g_j which have an X on the qubit.
    %Now, g_j commute with \pm Z. Replace g_i with \pm Z.
    
    q = min(p); %if multiple p exists, choose the smallest one

    j_indx = setdiff(p,q);  %For all other rows where x=1 do rowsum
    
    for I=1:length(j_indx)

       Tab = rowsum(Tab,n,j_indx(I),q); 

    end

   Tab(q,:)        = zeros(1,2*n+1,'int8');    % Set the p-th row to be identically 0.
   Tab(q,qubit+n)  = int8(1);                  % The p-th row will have z=1 if we have Z measurement.
   outcome         = randi([0,1],'int8');      % Flip a coin for the phase, i.e., for + or - outcome.
   Tab(q,end)      = outcome;                  % Put the random outcome as the phase.

   disp(['Outcome was: ',num2str(outcome)])

else 
    
    disp('Outcome: determinate')
    
    %In this case, we need to learn the \pm +1 sign. The \pm Z measurement  
    %commutes with all the stabilizers. For this reason, the state remains
    %invariant.
    
    %Destabilizer procedure:
    
    %dummy_row = zeros(1,2*n+1,'int8');
    
    %Tab_with_dummy_row = [Tab;dummy_row];

%     for jj=1:n %For jj=1,...,n call rowsum(2n+1,jj+n) if xj=1
% 
%         if Tab(jj,qubit)==1 %Destabilizer (j) has X on the qubit
% 
%            Tab=rowsum(Tab,n,2*n+1,jj+n);
% 
%         end
% 
%     end                
% 
%     outcome=(Tab(2*n+1,end));
%     disp(['Outcome was',num2str(outcome)])

    outcome = nan; %Unknown because we do not have destabs

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


