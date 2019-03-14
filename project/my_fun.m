function res = my_fun(v)
    H_r = 0.7792;
    H_g = 0.7549;
    H_b = 0.7160;
    B_r = 0.4513;
    B_g = 0.3987;
    B_b = 0.3575;
    x = v(1);
    y = v(2);
%     funxy = @(x,y)(abs(x) + abs(y) - abs(x*(H_r-B_r)+y*((H_g-B_g))+(1-x-y)*((H_b-B_b))));
    funxy = @(x,y)(abs(x) + abs(y) - abs(x*B_r+y*B_g+(1-x-y)*B_b));
    res = funxy(x, y);
end