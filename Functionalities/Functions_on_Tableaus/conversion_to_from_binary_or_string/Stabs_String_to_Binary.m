function Stabs=Stabs_String_to_Binary(S)
%Input should be a cell array of strings containing I,X,Y,Z.
%Each element of the cell array is a stabilizer generator.
%Output: The stabilizer representation in binary.

if ~iscell(S)
    
   error('Please provide the stabs as a cell of strings.') 

end

n=length(S);

Stabs = zeros(n,2*n,'int8');

for ii=1:n %loop through stabs

   for jj=1:length(S{ii})  %loop through opers

       if strcmpi(S{ii}(jj),'X')

           Stabs(ii,jj)=1;

       elseif strcmpi(S{ii}(jj),'Y')

           Stabs(ii,jj)=1;
           Stabs(ii,jj+n)=1;

       elseif strcmpi(S{ii}(jj),'Z')

           Stabs(ii,jj+n)=1;

       end


   end

end



end
