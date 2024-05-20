function [Q_transf,flag,strSols]=LC_check(G1,G2)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: May 19, 2024
%--------------------------------------------------------------------------
%
%Function to check if two graphs are LC equivalent.
%Solve the problem Ax=0, where x is the vector:
%x = [c_1 ... c_n a_1 ... a_n d_1 ... d_n b_1 ... b_n]^T
%given the constraints a_i d_i + b_i c_i = 1 (i.e., det[Q_i]=1)

%Inputs: Adjacency matrices of G1 and G2 graphs
%Output: Q_transf: The solution to the LC equivalence test if it exists.
%        flag: true or flase if G1 and G2 are LC equivalent
%        strSols: solutions as a string of operations

[Anew,free_variables] = Construct_LC_matrix(G1,G2);

NullVecMatrix = GF2_Null_Space(Anew,free_variables);  %Unconstrained Nullspace
sols          = Constrained_NullSpace(NullVecMatrix); %Solutions of nullspace that satisfy det(Qi)=1

if isempty(sols)
   
    Q_transf=[];
    strSols=[];
    flag=false;
    return
    
end

Q_i = Reconstruct_Qis(sols);

%Each of the sols corresponds to a local gates on qubits because we know that we 
%have one Q_i which is supposed to act on the ith qubit.

for l=1:length(Q_i)
    
    for jj=1:length(Q_i{l})
        
        strSols{l}{jj} = Recognize_Qi_s(Q_i{l}{jj});
        
    end
    
end

%Inspect that we recover the 2nd adjacency matrix:
n  = size(G1,2);
Sx = eye(n,'int8');

Stabs1 = [G1; Sx]; %2n x n matrix
Stabs2 = [G2; Sx];
P      = [zeros(n,'int8') eye(n,'int8');...
          eye(n,'int8')    zeros(n,'int8')];

%Need to extend each Qi in total space
%
%1st row of Qi tells us how the Sz part changes
%2nd row of Qi tells us how the Sx part changes
%
%[a b][Sz]    -> [aSz+bSx]
%[c d][Sx]    -> [cSz+dSx]
%
%So, we have:
%Qi=[a_i b_i
%    c_i d_i]
%
%and Q is formed as (example n=3):
%Q=[a_1  0  0 | b1  0  0]
%    0  a2  0 |  0  b2 0]
%    0   0 a3 |  0  0 b3]
%    --------------------
%    c1  0  0 | d1  0  0]
%    0   c2 0 | 0  d2  0]
%    0   0 c3 | 0  0  d3]

Q_transf=cell(1,length(Q_i));

for jj=1:length(Q_i) %Loops over all solutions

    current_Q = Q_i{jj}; %The Q^(i) of the current solution (2x2 matrix)
    %Q         = sparse(2*n,2*n);
    Q         = zeros(2*n,2*n,'int8');

    for qubit=1:length(current_Q)

        q = current_Q{qubit};

        for entry_i = 1:2

            for entry_j = 1:2

                Q(qubit+n*(entry_i-1),qubit+n*(entry_j-1))=q(entry_i,entry_j);
                
                %Q = Q + sparse(qubit+n*(entry_i-1), qubit+n*(entry_j-1) ,q(entry_i,entry_j),2*n,2*n);
                              %row position         column position       value
            %Example: n=2
            % qubit=1, i=1, j=1:     sparse(1,1,q(1,1))=sparse(1,1,a_1)
            %          i=1, j=2:     sparse(1,3,q(1,2))=sparse(1,3,b_1)
            %          i=2, j=1:     sparse(3,1,q(2,1))=sparse(3,1,c_1)
            %          i=2, j=2:     sparse(3,3,q(2,2))=sparse(3,3,d_1)
            % so far:                [a1 0 | b1 0]
            %                        [0  0 |  0 0]
            %                        [c1 0 | d1 0]
            %                        [0  0 |  0 0]
            %qubit=2, i=1, j=1       sparse(2,2,q(1,1))=sparse(2,2,a_2)
            %         i=1, j=2       sparse(2,4,q(1,2))=sparse(2,4,b_2)
            %         i=2, j=1       sparse(4,2,q(2,1))=sparse(4,2,c_2)
            %         i=2, j=2       sparse(4,4,q(2,2))=sparse(4,4,d_2)
            %Total:
            %                        [a1 0 | b1 0]
            %                        [0  a2| 0 b2]
            %                        [c1  0| d1 0]
            %                        [0  c2| 0 d2]
            
            end 
            
        end

        Q_transf{jj} = Q;

    end

    %LC equivalence condition up to basis change:
    test_cond = mod(double(Stabs1)' * double(Q)' * double(P) * double(Stabs2),2);
    
    if ~all(all(test_cond==zeros(n,'int8')))

        error('Q does not satisfy the LC equivalence test. The solution is wrong.')
    end

    if ~all(all((mod(double(Q)'*double(P)*double(Q),2)==P)))
       error('The transformation is not symplectic.') 
    end
    
    AA = Q(1:n,1:n);
    BB = Q(1:n,n+1:2*n);
    CC = Q(n+1:2*n,1:n);
    DD = Q(n+1:2*n,n+1:2*n);
    
    if ~isdiag(double(AA)) || ~isdiag(double(BB)) || ~isdiag(double(CC)) || ~isdiag(double(DD))
        
        error('The submatrices of Q are not diagonal.')
        
    end
    
end


flag=true;


end
