function z=mult_int8(x,y)
%To multiply int8 inputs.
m=size(x,1);
n=size(x,2);

if n~=size(y,1)
   error('Incorrect dimensions for matrix multiplication.') 
end


p=size(y,2);

z=zeros(m,p,'int8');

for i=1:m
   
     z(i,1:p) = sum(bsxfun(@times, reshape(x(i,:),n,1), y), 1);
    
end



end