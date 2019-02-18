function [c,ceq] = q_norm(x)
    c = [];
    ceq = sqrt(x(1)^2 + x(2)^2 + x(3)^2 + x(4)^2) - 1;
end