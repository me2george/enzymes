% By Paulo Abelha
% returns or plots a superellipse
function [ pcl, thetas ] = superellipse( a, b, eps1, D, plot_fig, not_unif )
    if ~exist('D','var') || D < 0
        D = (a+b)/100; %0.0005;
    end
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    if ~exist('not_unif','var')
        not_unif = 0;
    end
    N = 10^5;
    if not_unif
        thetas = -pi:1/N:pi;
        X = a*signedpow(cos(thetas),eps1);
        Y = b*signedpow(sin(thetas),eps1);
    else
        thetas = unif_sample_theta(a, b, eps1, D);
        thetas(thetas>pi/2) = pi/2;
        thetas(thetas<0) = 0;
        X = a*signedpow(cos(thetas),eps1);
        Y = b*signedpow(sin(thetas),eps1);
        X = [X -X X -X];        
        Y = [Y Y -Y -Y];
    end    
    pcl = [X' Y'];
    if plot_fig
       scatter(X,Y,1); axis equal; 
    end
end

function thetas = unif_sample_theta(a, b, eps1, D)
    pi_over_4 = pi/4;
    max_iter = 10^6;
    thetas(1) = 0;
    i = 0;
    while true
        if i > max_iter
            error(['First theta sampling reach the maximum number of iterations ' num2str(max_iter)]);
        end
        theta_next = update_theta(a, b, eps1, thetas(end), D);
        new_theta = thetas(end) + theta_next;
        if new_theta > pi_over_4
            break;
        end
        thetas(end+1) = new_theta;
        i = i +1;
    end
    thetas2(1) = 0;
    while true
        if i > max_iter
            error(['Second theta sampling reach the maximum number of iterations ' num2str(max_iter)]);
        end
        thetas2_next = update_theta(b, a, eps1, thetas2(end), D);
        new_theta = thetas2(end) + thetas2_next;
        if new_theta > pi_over_4
            break;
        end
        thetas2(end+1) = new_theta;
        i = i +1;
    end
    thetas = [thetas pi/2-thetas2];
end

% By Paulo Abelha (p.abelha at abdn ac uk )
% based on [PiluFisher95] Pilu, Maurizio, and Robert B. Fisher. �Equal-distance sampling of superellipse models.� DAI RESEARCH PAPER (1995)
% 
% Update u based on the combinations of models in the paper
function [ theta_next ] = update_theta( a1, a2, eps1, theta_prev, D )
    theta_eps = 1e-2;
    if theta_prev <= theta_eps
        % equation (8)
        theta_next = power(abs((D/a2)+power(theta_prev,eps1)),1/eps1)-theta_prev;
%         ns(1) = ns(1) + 1;
    else
        if pi/2 - theta_prev < theta_eps
            % equation (9)
            theta_next = power((D/a1)+power(pi/2-theta_prev,eps1),1/eps1)-(pi/2-theta_prev);      
%             ns(2) = ns(2) + 1;
        else
%             ns(3) = ns(3) + 1;
            % equation (5)
            theta_next = (D / eps1) * cos (theta_prev) * sin (theta_prev) * sqrt (1/ (a1^2  * power(cos(theta_prev), 2*eps1) * power(sin(theta_prev), 4.) + a2^2 * power(sin(theta_prev), 2*eps1) * power(cos(theta_prev), 4.)));
        end
    end
end