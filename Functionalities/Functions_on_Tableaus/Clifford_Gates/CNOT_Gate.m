function  Tab=CNOT_Gate(Tab,qubit,n)
%Implementation of the CNOT gate on the stabilizer Tableau.
%Inputs: Tab: The Tableau
%        qubit: an array of 2 qubits (first one is control)
%        n: the # of qubits represented by the Tableau.
%Output: The updated Tableau.

% if length(qubit)~=2
%    
%     error('Please provide 2 qubits for the CNOT gate. The first one is the control.')
%     
% end

% control = qubit(1);
% target  = qubit(2);



XC     = Tab(:,qubit(1));
ZC     = Tab(:,qubit(1)+n);
r      = Tab(:,end);

XT     = Tab(:,qubit(2));
ZT     = Tab(:,qubit(2)+n);

Tab(:,qubit(2))    = bitxor(XT,XC);
Tab(:,qubit(1)+n)  = bitxor(ZT,ZC);

temp = mod(ZC+1,2); %for some reason, mod is faster here than bitxor
temp = bitxor(XT,temp);
temp = ZT.*temp;
temp = XC.*temp;

%temp       = XC.*ZT.*( bitxor( XT ,bitxor(ZC,1)) );
Tab(:,end) = bitxor(temp,r); 


end