function [Gamma,store_opers]=Get_Adjacency(varargin) %(Tab)
%Function to obtain the adjacency matrix from a Stabilizer Tableau.
%Input:  Tableau and 
%        option: true or false, to store or not the operations that transform
%        the Tableau in canonical form.
%Output: Gamma: Adjacency matrix
%        store_opers: The operations that transform the Sz part of the
%        tableau to the canonical form.

%To speed up the computation, discard the phase information.
%Instead of rowsum do bitxor_rows

Tab = varargin{1};
cnt = 0;

if nargin>1
    
    flag_opers = true;
    
else
    
    flag_opers  = false;
    store_opers = [];
    
end

n  = size(Tab,2);
n  = (n-1)/2;
Sx = Tab(:,1:n);


if all(diag(Sx)>0) %faster than all(all(Sx==eye(n,'int8'))) 
   
    Gamma=Tab(:,n+1:2*n);
    
    if ~flag_opers
        
        Gamma = Gamma - diag(diag(Gamma));
        
        
    else
        
        for ll=1:size(Gamma,1)

            if Gamma(ll,ll)==1 
                %There is a Y operator, which can be removed with a phase gate.
                %disp('There is a Y operator, I will <<perform>> a phase gate.')

                    cnt=cnt+1;
                    store_opers(cnt).qubit=ll;
                    store_opers(cnt).gate='P';

                    Gamma(ll,ll)=0;

            end
        end        
        
    end
    
    %mustBeValidAdjacency(Gamma)
    return
    
end


if flag_opers
    
    for qubit=1:n

        Tq    = Tab(:,qubit);
        locs  = Tq(qubit:end)>0;
        %locs  = find(Tq(qubit:n));    %Check the columns to see if we have X
        %locs  = locs+qubit-1;

        if ~any(locs) %isempty(locs)  %|| isempty(locs(locs>=qubit)) %If there is no X, do a Had

           %Tab=Had_Gate(Tab,qubit,n); %Do not call Had gate, we don't need the phase information

           temp           = Tab(:,qubit+n); 
           Tab(:,qubit+n) = Tab(:,qubit);
           Tab(:,qubit)   = temp;       

           cnt=cnt+1;
           store_opers(cnt).qubit=qubit;    
           store_opers(cnt).gate='H';

        end


        if Tab(qubit,qubit)~=1

            SliceTab = Tab(:,qubit);

            for jj=qubit+1:n

                if SliceTab(jj)==1 %Tab(jj,qubit)==1  %SWAP rows

                    temp         = Tab(jj,:);
                    Tab(jj,:)    = Tab(qubit,:);
                    Tab(qubit,:) = temp;

                    break

                end

            end

        end

        SliceTab = Tab(:,qubit);

        for jj=qubit+1:n %Remove Xs appearing below the diagonal entry

            if SliceTab(jj)==1 %Tab(jj,qubit)==1

                Tab(jj,:)=bitxor(Tab(jj,:),Tab(qubit,:));

            end

        end

    end
    
else
    
    for qubit=1:n

        Tq    = Tab(:,qubit);
        locs  = Tq(qubit:end)>0; %Check the columns to see if we have X
        %locs  = find(Tq(qubit:n));    
        %locs  = locs+qubit-1;
        
        if ~any(locs) %isempty(locs)  || isempty(locs(locs>=qubit)) %If there is no X, do a Had

           %Tab=Had_Gate(Tab,qubit,n); %Do not call Had gate, we don't need the phase information

           temp           = Tab(:,qubit+n); 
           Tab(:,qubit+n) = Tab(:,qubit);
           Tab(:,qubit)   = temp;       

        end


        if Tab(qubit,qubit)~=1

            SliceTab = Tab(:,qubit);

            for jj=qubit+1:n

                if SliceTab(jj)==1 %Tab(jj,qubit)==1  %SWAP rows

                    temp         = Tab(jj,:);
                    Tab(jj,:)    = Tab(qubit,:);
                    Tab(qubit,:) = temp;

                    break

                end

            end

        end

        SliceTab = Tab(:,qubit);
        
        for jj=qubit+1:n %Remove Xs appearing below the diagonal entry

            if SliceTab(jj)>0 %Tab(jj,qubit)==1

                Tab(jj,:)=bitxor(Tab(jj,:),Tab(qubit,:));

            end

        end
        

    end
    
end

%------------------ Back-substitution -------------------------------------

for qubit=1:n 
    
   SliceTab = Tab(:,qubit); 
    
   for k=qubit-1:-1:1
       
       if SliceTab(k)>0 %Tab(k,qubit)==1 
           
           Tab(k,:)=bitxor(Tab(k,:),Tab(qubit,:));
           
       end
       
   end
   
end

%------------------ Remove self-loops -------------------------------------

if flag_opers
   
    for ll=1:n
        
        if Tab(ll,ll+n)==1 %Eliminate Ys (remove self-loops)

            %Tab = Clifford_Gate(Tab,ll,'P',n); 
            %Tab=Phase_Gate(Tab,ll,n);

            %Tab(:,ll+n) = bitxor(Tab(:,ll),Tab(:,ll+n));                    

            Tab(ll,ll+n)=0;

            cnt=cnt+1;
            store_opers(cnt).qubit=ll;
            store_opers(cnt).gate='P';

        end
        
        
        
    end
    
    Gamma = Tab(:,n+1:2*n);
    
else
    
    Gamma = Tab(:,n+1:2*n);
    Gamma = Gamma - diag(diag(Gamma));
    
end

%This is for debugging.
% Sx    = Tab(:,1:n);
% 
% if ~all(diag(Sx)>0) %~all(all(eye(n,'int8')==Sx))
%     error('At the end of Gauss elimination, the Sx part of the Tableau is not identity')
% end


%mustBeValidAdjacency(Gamma)
Gamma=single(Gamma);


end