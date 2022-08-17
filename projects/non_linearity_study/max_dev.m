function [max_dev] = max_dev(v_start,dz,res,params,err)

beta_start = fabian_original_beta(params,v_start(1),v_start(2));
% dz = dir*(10^-28);
v_end = v_start +dz;
beta_end = fabian_original_beta(params,v_end(1),v_end(2));

max_dev = 0;
min_dev = 0;
% res = 1000;
eta_plot = zeros(res,1);
b_plot = zeros(res,1);
beta_plot = zeros(res,1);

eta_max = 0;
eta_min = 0;

for i = 1:res
    test_dev_pts = req_v1v2points(v_start,v_end,res);
    
    beta = fabian_original_beta(params,test_dev_pts(i,1),test_dev_pts(i,2));
    beta_plot(i) = beta;
    
    b = b_terminalbase(v_start,beta_start,v_end,beta_end,test_dev_pts(i,:));
    b_plot(i) = b;
    
    
    eta = sqrt((test_dev_pts(i,2) - v_start(2))^2 + (test_dev_pts(i,1) - v_start(1))^2);
    eta_plot(i) = eta;
    
    dev_b = (beta-b)/( beta_end - beta_start);
    
    
    if(dev_b > max_dev)
        max_dev = dev_b;
        max_beta = beta;
        eta_max = eta;
    elseif(dev_b<min_dev)
        min_dev = dev_b;
        eta_min = eta;
    end


end
if(strcmp(err,'check_error'))
    hold on
    plot(eta_plot(:),b_plot(:),'-',eta_plot(:),beta_plot(:),'o')
    plot(eta_max,max_beta,'xc')
%     ,eta_min,min_dev,'xc')
    
    input('check error'); 
end
max_dev = abs(max_dev) + abs(min_dev);

end

