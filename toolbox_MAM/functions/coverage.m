function [width,cover] = coverage (y,y_pre,alpha)
epsilon = y - y_pre;
N = size(epsilon,1);
epsilon_sort =  sort(epsilon);
n1 = floor(N*alpha/2);
n2 = N - n1;
k1 = n1; 
k2 = n2;
g = ksdensity(epsilon,epsilon_sort);
t=1000;
    while (k1-1)*(k2-N)~=0 
        if g(k1)< g(k2) && g(k1+1)<g(k2+1)
            k1 = k1+1;
            k2 = k2+1;
        end
        if  g(k1)>g(k2) && g(k1-1)>g(k2-1)
 
              k1 = k1-1;
              k2 = k2-1;
        end          
        if t==k1       
            break
        end
        t  = k1;
    end
low =  y_pre + epsilon_sort(k1);
up  =  y_pre + epsilon_sort(k2);

y_low = (y -low)>0;
y_up  = (up-y)>0;
cover = sum(y_low==y_up)/N;
width = abs(epsilon_sort(k2)-epsilon_sort(k1));
end