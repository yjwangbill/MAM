function [ projy ] = proj_box( y ,a,b)
%See "Fast Projection onto the Simplex and the ?1 Ball", Laurent Condat, 2015

for i =1 : size(y,2)

    low_ind = y(:,i)<a;
    up_ind = y(:,i)>b;
    y(low_ind,i)=a;
    y(up_ind,i)=b;
    projy = y;
end

end

