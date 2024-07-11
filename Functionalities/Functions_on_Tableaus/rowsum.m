function Tab=rowsum(Tab,n,H_replace,I)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: July 3, 2024
%--------------------------------------------------------------------------
%
%Function to add 2 rows together in the Tableau. Rowsum operates as:
%Rh -> Rh*Ri.
%Input: Tab: Input stabilizer Tableau (n x 2n+1 array)
%       H_replace: The row to replace
%       I: The row to add to H_replace
%Output: The updated Tableau.
%--------------------------------------------------------------------------

rH = Tab(H_replace,end);
rI = Tab(I,end);

Tab = g(H_replace,I,rH,rI,Tab,n);

end




function Tab=g(rowH,rowI,rH,rI,Tab,n)
%My version of phase update (Rh->Rh*Ri)

cnt_p   = 0;             %positions where we end up with i^(+1) phase
TabrowH = Tab(rowH,:);
TabrowI = Tab(rowI,:);

anti_comm = xor(bitand(TabrowH(1:n),TabrowI(n+1:2*n)),...
                bitand(TabrowI(1:n),TabrowH(n+1:2*n))); %Anticommuting relations
%anti_comm -> 1st line xh or zi nnz, 2nd line xi or zh nnz
%               bitand                  bitand
%1) xh=1 zi=0 ->  0     | 1) zh=1 xi=0 -> 0
%2) xh=0 zi=1 ->  0     | 2) zh=0 xi=1 -> 0
%3) xh=1 zi=1 ->  1     | 3) zh=1 xi=1 -> 1
%4) xh=0 zi=0 ->  0     | 4) zh=0 xi=0 -> 0

%-------- combs: ----------------------------------------------------------
% 11 : Y_h * I_i  -> xor(0,0) = 0 | 21 : Z_h * Z_i  -> xor(0,0) = 0
% 12 : X_h * X_i  -> xor(0,0) = 0 | 22 : I_h * Y_i  -> xor(0,0) = 0
% 13 : Y_h * X_i  -> xor(0,1) = 1 | 23 : Z_h * Y_i  -> xor(0,1) = 1
% 14 : X_h * I_i  -> xor(0,0) = 0 | 24 : I_h * Z_i  -> xor(0,0) = 0
%
% 31 : Y_h * Z_i  -> xor(1,0) = 1 | 41 : Z_h * I_i  -> xor(0,0) = 0
% 32 : X_h * Y_i  -> xor(1,0) = 1 | 42 : I_h * X_i  -> xor(0,0) = 0
% 33 : Y_h * Y_i  -> xor(1,1) = 0 | 43 : Z_h * X_i  -> xor(0,1) = 1
% 34 : X_h * Z_i  -> xor(1,0) = 1 | 44 : I_h * I_i  -> xor(0,0) = 0 
%
%Anticommuting: YX, XY, ZY, YZ, XZ, ZX
%-------- All the above look correct --------------------------------------
            
indices = find(anti_comm);
L       = length(indices);

for l=1:L
    
    k=indices(l);
    
    if TabrowH(k+n)==0  %X_h (not Z, not Y, cannot be I because it would commute)
        
        if TabrowI(k)==1 %Y_i (cannot be X or I because it would commute, cannot be Z because it has xi=1)

            cnt_p=cnt_p+1;

        end

    elseif bitand(TabrowH(k),TabrowH(k+n))==1 %Y_h 

        if TabrowI(k)==0  %Z (cannot be Y or I or X because it has xi==0)

            cnt_p=cnt_p+1;

        end

    else  %Z_h (cannot be I because it would commute)
        
        if TabrowI(k+n)==0 %X (cannot be Z or Y because it has zi=0, cannot be I because it would commute)

            cnt_p=cnt_p+1;

        end

    end

end


%--- We covered: ZX, YZ, XY -> +i phase -----------------------------------
%--- Remaining : XZ, ZY, YX -> -i phase -----------------------------------

%cnt_p : how many times the +1 power of i appears 
%cnt_m : how many times the -1 power of i appears, i.e., L-cnt_p
%cnt_0 : how many times the  0 power of i appears, i.e., n-L
%General expression: temp = mod( 2*rH + 2*rI + ( 0*cnt_0 + 1*cnt_p + (-1)*cnt_m ),4 );
%Simplified:         temp = mod( 2*rH + 2*rI + 2*cnt_p-L,4)   

temp = 2*rH + 2*rI + 2*cnt_p - L;
temp = mod(temp,4);

if temp==0
    
    rH_new=0;
    
else
    
    rH_new=1;
    
end

% This is a test (passes every time):
% if rH_new~=oldg(rowH,rowI,rH,rI,Tab,n)
%     
%    error('The two methods do not agree.') 
%    
% end

Tab(rowH,:)     = bitxor(TabrowH, TabrowI);
Tab(rowH,end)   = rH_new;

end

function rH=oldg(rowH,rowI,rH,rI,Tab,n)
%Phase update based on Gottesman and Aaronson

%------------------- Old code ---------------------------------------------

indx = find(      ~(Tab(rowH,(1:n))==Tab(rowI,(1:n)) & Tab(rowH,(n+1:2*n))==Tab(rowI,(n+1:2*n))) ....
              &   ~(Tab(rowH,(1:n))==0 & Tab(rowH,(n+1:2*n))==0) ...
              &   ~(Tab(rowI,(1:n))==0 & Tab(rowI,(n+1:2*n))==0)); %Qubit positions


out=0;

for jj=1:length(indx)
    
    x1=Tab(rowH,indx(jj));
    z1=Tab(rowH,indx(jj)+n);
    
    x2=Tab(rowI,indx(jj));
    z2=Tab(rowI,indx(jj)+n);
    
    %if x1==0 && z1==0 %(Identity in RH)
        
    %    continue
        
    if x1==1 && z1==1 %(Y in RH)
                          %If x2=0, z2=0, no change.
                          %If x2=1, z2=0, then Y*X=-i*Z (so -1 power)
                          %If x2=1, z1=1, then Y*Y=1 so 0.
                          %If x2=0, z2=1, then Y*Z=i*X (so +1 power)
        out=out+(z2-x2);
        
    elseif x1==1 && z1==0 %(X in RH)
                          %If x2=0, z2=0, no change.
                          %If x2=1, z2=0, X*X=1, so no change.
                          %If x2=0, z2=1, X*Z=-i*Y (so -1 power).
                          %If x2=1, z2=1, X*Y=i*Z (so +1 power)
        
        out=out+z2*(2*x2-1); 
        
    elseif x1==0 && z1==1 %(Z in RH)
                          %If x2=0, z2=0 no change.
                          %If x2=1, z2=0, Z*X=i*Y (so +1 power)
                          %If x2=1, z2=1, Z*Y=-iX (so -1 power)
                          %If x2=0, z2=1, Z*Z=1, so no change.
        
        out=out+x2*(1-2*z2);
        
    end
        
    
end


if mod(2*rH+2*rI+out,4)==0
   
    rH=0;
else
    rH=1;
    
end

end


