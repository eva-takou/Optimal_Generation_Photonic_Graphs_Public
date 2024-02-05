function Tab=Had_Gate(Tab,qubit,n)
%Implementation of the Hadamard gate on the stabilizer Tableau.
%Inputs: Tab: The Tableau
%        qubit: an array of 2 qubits (first one is control)
%        n: the # of qubits represented by the Tableau.
%Output: The updated Tableau.


XZ         = Tab(:,qubit).*Tab(:,qubit+n);
Tab(:,end) = bitxor(XZ,Tab(:,end));         

% locsX = Tab(:,qubit)==1;
% locsZ = Tab(:,qubit+n)==1;
% locsY = XZ==1; %we know these from multiplication XZ
% locsX = locsX & ~locsY;
% locsZ = locsZ & ~locsY;

%testTab=Tab;
% Tab(locsX,qubit)=0;
% Tab(locsX,qubit+n)=1;
% Tab(locsZ,qubit+n)=0;
% Tab(locsZ,qubit)=1;


%Tab(:,[qubit,qubit+n]) = Tab(:,[qubit+n,qubit]); %This is slow...

temp = Tab(:,qubit+n); %For some reason this is better..
Tab(:,qubit+n)=Tab(:,qubit);
Tab(:,qubit)=temp;



end