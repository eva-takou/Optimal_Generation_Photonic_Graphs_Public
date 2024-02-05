function flag=isbinary(A)

flag = all( all(A==0 | A==1) );



end