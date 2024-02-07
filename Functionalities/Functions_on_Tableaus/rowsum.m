function Tab=rowsum(Tab,n,H_replace,I)
%Function to add 2 rows together in the Tableau.
%Input: Tab: Tableau
%       H_replace: The row to replace
%       I: The row to add to H_replace
%Output: The updated Tableau.
%--------------------------------------------------------------------------
%Rowsum operates as Rh -> Rh*Ri
%--------------------------------------------------------------------------

rH = Tab(H_replace,end);
rI = Tab(I,end);


Tab = g(H_replace,I,rH,rI,Tab,n);


end


%My version:
function Tab=g(rowH,rowI,rH,rI,Tab,n)
%Rh->Rh*Ri

TabrowH = (Tab(rowH,:));
TabrowI = (Tab(rowI,:));
cnt_p   = 0;


anti_comm = xor(bitand(TabrowH(1:n),TabrowI(n+1:2*n)),bitand(TabrowI(1:n),TabrowH(n+1:2*n))); %Anticommuting relations

indices = 1:n;
indices = indices(anti_comm);
L       = length(indices);

for l=1:L
    
    k=indices(l);
    
    if TabrowH(k)==1 && TabrowH(k+n)==0 %X

        if TabrowI(k)==1 %&& z2(k)==1 %Y

            cnt_p=cnt_p+1;

        end

    elseif bitand(TabrowH(k),TabrowH(k+n))==1 %TabrowH(k)==1 && TabrowH(k+n)==1 %Y

        if TabrowI(k)==0 %&& z2(k)==1  %Z

            cnt_p=cnt_p+1;

        end

    else  %has to be Z   %if x1(k)==0 && z1(k)==1 %Z  

        if TabrowI(k+n)==0 %&& x2(k)==1  %X

            cnt_p=cnt_p+1;

        end

    end

    
    
end

cnt_m = L-cnt_p;    

temp = (+1i)^cnt_p * (-1i)^cnt_m;
rH   = mod(rH+rI-1/2*(temp-1),2);


Tab(rowH,:)     = bitxor(TabrowH, TabrowI);
Tab(rowH,end)   = rH;


end



%This is based on gotesman and aaronson
function rH=oldg(rowH,rowI,rH,rI,Tab,n)
%This is still faster than the code above....
%Can we speed this up? Q: Can this be vectorized?

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


