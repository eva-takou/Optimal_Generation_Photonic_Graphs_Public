function Verify_Quantum_Circuit(Circuit,n,ne,Target_Tableau)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 16, 2024
%
%Script to verify that the quantum circuit gives rise to the Target
%tableau. Verification is done by reversing the backwards input circuit
%and the measurement is simulated as a CNOT. P gate is transformed into
%P^\dagger.
%Inputs: Circuit: Generation Circuit (in reverse order)
%        n: number of total qubits
%        ne: # of emitters qubits
%        Target_Tableau: the target tableau in canonical form.


Init_Tab = Initialize_Tab(n); %start from all |0>
Tab      = Init_Tab;
L        = length(Circuit.Gate.name);

for ll=L:-1:1 %Loop in reverse
   
    Oper   = Circuit.Gate.name{ll};
    Qubits = Circuit.Gate.qubit{ll};
    
    if strcmpi(Oper,'Measure') 
        
        Oper = 'CNOT';

    elseif strcmpi(Oper,'P') 

        Oper = 'Pdag';
    
    end
    
    Tab = Clifford_Gate(Tab,Qubits,Oper,n);
 
end

G0 = Get_Adjacency(Target_Tableau);
G1 = Get_Adjacency(Tab);
G1 = G1(1:n-ne,1:n-ne); %Remove the emitters (last positions)

if any(any(G0~=G1))
    
    figure(1)
    clf;
    subplot(2,1,1)
    plot(graph(single(G0)))
    subplot(2,1,2)
    plot(graph(single(G1)))
    error('Found different adjacency matrices.')
    
end

end


function Tab=Initialize_Tab(n)
%Create the trivial tableau: all qubits start from |0>.

Sz = eye(n,'int8');
Sx = zeros(n,n,'int8');


S   = [Sx,Sz];
Tab = S;
Tab = [Tab,zeros(n,1,'int8')];

end