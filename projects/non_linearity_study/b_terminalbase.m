function [b] = b_terminalbase(v_start,b_1,v_end,b_2,v_query)
L = sqrt((v_end(2) - v_start(2))^2 + (v_end(1) - v_start(1))^2 );  

eta = sqrt((v_query(2) - v_start(2))^2 + (v_query(1) - v_start(1))^2);

b = ((b_2 - b_1)/L)*eta + b_1;

end

