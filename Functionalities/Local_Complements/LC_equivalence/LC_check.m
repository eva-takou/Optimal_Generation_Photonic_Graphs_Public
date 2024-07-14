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
%        m: a word of LC nodes such that G2*m = G1 (when bool=true).

[Anew,free_variables] = Construct_LC_matrix(G1,G2);

NullVecMatrix = GF2_Null_Space(Anew,free_variables);  %Unconstrained Nullspace
sols          = Constrained_NullSpace(NullVecMatrix); %Solutions of nullspace that satisfy det(Qi)=1
%each cell has a vector v=XYZT with elements in GF2
if isempty(sols)
   
    Q_transf=[];
    strSols=[];
    flag=false;
    %m=[];
    return
else
    
    
%     n  = length(G1);
%     v1 = ones(1,n);
%     w1 = 3*ones(1,n); %Take 2 sup vectors of K^V (no entry is 0)
%     
%     X = sols{1}(1:n);      
%     T = sols{1}(3*n+1:end); 
%     
%     Y = sols{1}(n+1:2*n);  
%     Z = sols{1}(2*n+1:3*n); 
%     
%     verify_XYZT(X,Y,Z,T,G1,G2)
    %X \intersect T + Y \intersect Z = V
    %{1,4} + {2,3,5} =V
    
    %Can we do multiplication of v1 and w1 which are in F4
    %with a vector which is defined in F2?
    %0-> [0,0]
    %1-> [1,0]
    %omega-> [0,1]
    %omega^2-> [1,1]
    %
    %1+omega=omega^2.
    %v1 is now 1 x n
    %the other vector is also 1 x n
    %if we make it 2 x n then how do we perform the multiplication?
    %then 1 x 
    
%     v2_Alt = mod( v1 .* single(Z)' + w1 .* single(X)' ,3);
%     w2_Alt = mod( v1 .* single(T)' + w1 .* single(Y)' ,3);
%     
%     
%     v2_Alt = add_F4( mult_F4(v1,single(Z)), mult_F4(w1,single(X)));
%     w2_Alt = add_F4( mult_F4(v1,single(T)), mult_F4(w1,single(Y)));
%     v2_Alt = add_F4( mult_F4(v1,single(X)), mult_F4(w1,single(Y)));
%     w2_Alt = add_F4( mult_F4(v1,single(Z)), mult_F4(w1,single(T)));
    
%     if any(v2_Alt==0)  || any(w2_Alt==0) 
%        
%         warning('Expect incorrect result. Not complete vectors.') 
%        
%     end
    %for v2_Alt to be complete, it is necessary and sufficient
    %that Z \cup T = V (or Z+T = all ones for the binary rep)
    
%     m  = [];
%     d  = zeros(1,n); %Divergence of vectors according to Bouchet
%     
%     F2 = G2;
%     while true
%         
%         for x=1:n
% 
%             if v2_Alt(x)==v1(x)
% 
%                 d(x)=0;
%                 
%             elseif v2_Alt(x)==add_F4(v1(x),w1(x))  
% 
%                 d(x) = 1;
%                 Nx   = Get_Neighborhood(F2,x);
%                 F2   = Local_Complement(F2,x);
%                 
%                 m    = [m,x];
%                 d(x) = 1-d(x);
% %                 d(Nx)= 3-d(Nx);
%                 
%                 VEC    = zeros(1,n);
%                 VEC(x) = 1;
%                 NVEC   = zeros(1,n);
%                 NVEC(Nx)   = NVEC(Nx) ;
%                 
%                 v2_Alt
%                 [v2_Alt,w2_Alt]=update_v2w2(v2_Alt,w2_Alt,VEC,NVEC);
%                 v2_Alt
%                 [];
%                 
%             elseif v2_Alt(x)==w1(x)
% 
%                 d(x)=2;
%                 
%             end
%             
% 
%         end        
%         
%         %check if for xy there is an edge xy in F2 such that d(x)=d(y)=2
%         
%         [];    
%         for x=1:n
% 
%            for y=x+1:n
% 
%                if F2(x,y)==1 && d(x)==2 && d(y)==2
% 
%                    Nx = Get_Neighborhood(F2,x);
%                    Ny = Get_Neighborhood(F2,y);
%                    
%                    VEC    = zeros(1,n);
%                    VEC(x) = 1;
%                    NVEC(x) = zeros(1,n);
%                    NVEC(Nx) = 1;
% 
%                    F2 = Local_Complement(F2,x);
% 
%                    
%                    [v2_Alt,w2_Alt]=update_v2w2(v2_Alt,w2_Alt,VEC,NVEC);
%                    %v2_Alt=add_F4(v2_Alt,mult_F4(w2_Alt,VEC));
% 
%                    for p=1:length(Nx)
% 
%                        if d(Nx(p))~=0
%                           d(Nx(p))= 3-d(Nx(p));
%                        end
%                    end
% 
%                    
%                    F2 = Local_Complement(F2,y);
% 
%                    VEC = zeros(1,n);
%                    VEC(y) = 1;      
%                    NVEC = zeros(1,n);
%                    NVEC(Ny) = 1;
%                    
% 
%                    [v2_Alt,w2_Alt]=update_v2w2(v2_Alt,w2_Alt,VEC,NVEC);
% 
%                    for p=1:length(Ny)
% 
%                        if d(Ny(p))~=0
%                           d(Ny(p))= 3-d(Ny(p));
%                        end
%                    end        
% 
%                    %Nx = Get_Neighborhood(F2,x);
%                    F2 = Local_Complement(F2,x);
% 
%                    for p=1:length(Nx)
% 
%                        if d(Nx(p))~=0
%                           d(Nx(p))= 3-d(Nx(p));
%                        end
%                    end                       
%                    d([x,y])=0;
% 
% 
%                    VEC = zeros(1,n);
%                    VEC(x) = 1;       
%                    NVEC = zeros(1,n);
%                    NVEC(Nx) = 1;
%                    [v2_Alt,w2_Alt]=update_v2w2(v2_Alt,w2_Alt,VEC,NVEC);
%                    
%                    
%                    m=[m,x,y,x];
%                end
% 
%            end
% 
%         end
%             
%             
%             
%         
%         [];
%             if all(d==0) %|| sum(d==0,'all')==n-1
%                break 
%             end        
%         
%     end
%     
%     if ~all(F2==G1)
%         
%        warning('not correct again.') 
%     end
    
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

function verify_XYZT(X,Y,Z,T,F1,F2)

n=length(X);
V=1:n;

X_new = find(X);
Y_new = find(Y);
Z_new = find(Z);
T_new = find(T);

XT=intersect(X_new,T_new);
YZ=intersect(Y_new,Z_new);

test=setxor(XT,YZ);

if ~all(test==V')
   error('Did not satisfy basic condition for solution.') 
end


for x1=1:n
    
    locs1    = Get_Neighborhood(F1,x1);
    Nx1_F1   = zeros(n,1);
    Nx1_F1(locs1) = 1;
    
    v1 = zeros(n,1);
    v1(x1)=1;
    
    for x2=1:n
        
        v2 = zeros(n,1);
        v2(x2)=1;        
        
        locs2    = Get_Neighborhood(F2,x2);
        Nx2_F2   = zeros(n,1);
        Nx2_F2(locs2) = 1;
    
        first = intersect(intersect(X_new,locs1),locs2);
        
        second = intersect(intersect(Y_new,locs1),x2);
        
        third = intersect(intersect(Z_new,locs2),x1);
        
        fourth = intersect(intersect(T_new,x1),x2);
%         
%         P1 = zeros(n,1);
%         P2 = zeros(n,1);
%         P3 = zeros(n,1);
%         P4 = zeros(n,1);
%         
%         P1(first) = 1;
%         P2(second) = 1;
%         P3(third) = 1;
%         P4(fourth) = 1;
        
        %mod(norm(P1)+norm(P2)+norm(P3)+norm(P4),2)
        test_val=mod(mod(length(first),2)+...
            mod(length(second),2)+...
            mod(length(third),2)+...
            mod(length(fourth),2),2);
        
        if test_val~=0
            error('Something is wrong with XYZT solutions.')
        end
        
    end
    
end




end

function [v2,w2]=update_v2w2(v2,w2,VEC,NVEC)

v2fixed=v2;
w2fixed=w2;

v2 = add_F4(v2fixed,mult_F4(w2fixed,VEC));
w2 = add_F4(w2fixed,mult_F4(v2fixed,NVEC));

end

function out=mult_F4(x,y)

[m1,m2]=size(x);
out=zeros(m1,m2);

for p=1:length(x)
    
    out(p) = mult_rules_F4(x(p),y(p));
end

end

function out=add_F4(x,y)

[m1,m2]=size(x);
out=zeros(m1,m2);

for p=1:length(x)
    
    out(p) = add_rules_F4(x(p),y(p));
end


end

function out=mult_rules_F4(elem1,elem2)

if elem1==0 || elem2==0
    
    out=0;
    
elseif elem1==1 
    
    out=elem2;
    
elseif elem2==1
    
    out=elem1;
    
elseif (elem1==2 && elem2==3) || (elem1==3 && elem2==2)
    
    out=1;
    
elseif elem1==2 && elem2==2
    
    out=3;
    
elseif elem1==3 && elem2==3
    
    out=2;
    
else
    
    error('did not consider some case')
    
end

end

function out=add_rules_F4(elem1,elem2)

if elem1==0 
    
    out=elem2;
    
elseif elem2==0
    
    out=elem1;
    
elseif elem1==elem2
    
    out=0;
    
elseif (elem1==1 && elem2==2) || (elem1==2 && elem2==1)
    
    out=3;
    
elseif (elem1==1 && elem2==3) || (elem1==3 && elem2==1)
    
    out=2;
    
    
elseif (elem1==2 && elem2==3) || (elem1==3 && elem2==2)
    
    out=1;
    
else
    error('Did not consider some case.')
    
end


end