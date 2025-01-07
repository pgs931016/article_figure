clc;clear;close all;

format shortG

% hyperparameters
    n_points = 100; % 95 for coincells 400 for NE cell data
    w_ocv_scale = 1;
    w_dvdq_scale = 5;
    N_iter = 100;
    N_multistart = 24;
    t_pause_plot = 0;
slash = filesep;
data_folder = 'G:\공유 드라이브\Battery Software Lab\0_Group Meeting\개인별_미팅자료\허성욱\사용 후 배터리 용량 재생\OCV fitting\Processed_Data\241219 OCV(D)-DCIR-Aging-OCV(C)';

for h =1:4
% load OCP datas
    load ('G:\공유 드라이브\Battery Software Lab\0_Group Meeting\개인별_미팅자료\허성욱\사용 후 배터리 용량 재생\OCV fitting\Processed_Data\Output data\AHC_OCV\AHC_OCV.mat')
    ocpn_raw = OCV_golden.OCVchg;
    x_raw = ocpn_raw(:,1);
    x = linspace(min(x_raw),max(x_raw),n_points)';
    ocpn_raw = ocpn_raw(:,2);
    ocpn_mva = movmean(ocpn_raw,round(length(ocpn_raw)/n_points));
    ocpn = interp1(x_raw,ocpn_mva,x);
    ocpn = [x ocpn];
    ocpn_cap = OCV_all(h).Qchg; 
    clear OCV_golden OCV_all Q_cell x ocpn_mva
    

    load ("G:\공유 드라이브\Battery Software Lab\0_Group Meeting\개인별_미팅자료\허성욱\사용 후 배터리 용량 재생\OCV fitting\Processed_Data\Output data\CHC_OCV\CHC_OCV.mat")
    ocpp_raw = OCV_golden.OCVchg;
    y_raw = ocpp_raw(:,1);
    y = linspace(min(y_raw),max(y_raw),n_points)';
    ocpp_raw = ocpp_raw(:,2);
    ocpp_mva = movmean(ocpp_raw,round(length(ocpp_raw)/n_points));
    ocpp = interp1(y_raw,ocpp_mva,y);
    ocpp = [y ocpp];
    ocpp_cap = OCV_all(h).Qchg; 
    clear OCV_golden OCV_all Q_cell y ocpp_mva
   

% load Merged data
    % see BSL_hyundai_agingDOE_merge.m
    load(fullfile("G:\공유 드라이브\Battery Software Lab\0_Group Meeting\개인별_미팅자료\허성욱\사용 후 배터리 용량 재생\OCV fitting\Processed_Data\241219 OCV(D)-DCIR-Aging-OCV(C)",sprintf('OCV_merged(%d).mat',h)))
    %load('G:\Shared drives\BSL_Data2\HNE_AgingDOE_Processed\HNE_FCC\4CPD 1C (25-42)\25degC\HNE_FCC_4CPD 1C (25-42)_25degC_s01_3_6_Merged.mat')


% check data
    figure(1)
    yyaxis left
    plot(ocpn(:,1),ocpn(:,2)); hold on
    yyaxis right
    plot(ocpp(:,1),ocpp(:,2)); hold on

j_count = 0; % to count OCV steps
tic;

for i = 1:size(data_merged,1) % loop over steps
    data_merged(i).Q_cell = abs(data_merged(i).OCVchg(end,3));
 

    data_merged(i).step = i; % add step number field
    
    j_count = j_count+1; % number of OCV now

    
    ocv_raw = data_merged(i).OCVchg(:,2); % OCV
    i_cc2cv = find(ocv_raw >= max(ocv_raw),1,'first');
    ocv_cc = ocv_raw(1:i_cc2cv);
    ocv_mva = movmean(ocv_cc,round(length(ocv_cc)/n_points));

    q_raw = data_merged(i).OCVchg(:,3); % cum-capacity **charging
    q_cc = q_raw(1:i_cc2cv);
    q = linspace(min(q_cc),max(q_cc),n_points)';
    
    ocv = interp1(q_cc,ocv_mva,q);
    data_merged(i).q_ocv = [q ocv];
  


 
   %% Initial guess

   if j_count == 1 % first RPT
     
      x_guess = [0,data_merged(i).Q_cell,1,data_merged(i).Q_cell]; % x0, Qn, y0, Qp
      x_lb = [0,  data_merged(i).Q_cell*0.5, 0.8,  data_merged(i).Q_cell*0.5];
      x_ub = [0.2, data_merged(i).Q_cell*2,   1,  data_merged(i).Q_cell*3];

   else 

       % detect the first and the last OCV results

       Qp_first = data_merged(1).ocv_para_hat(4);
       Qn_first = data_merged(1).ocv_para_hat(2);

       x_guess =   data_merged(1).ocv_para_hat; % initial guess from the last RPT
       x_lb =      [0,     data_merged(i).Q_cell*0.5,          0.5,     data_merged(i).Q_cell*0.5];
       x_ub =      [0.2,   Qn_first,    1,      Qp_first];

   end

    
    % OCV weighting
    w_ocv = w_ocv_scale*ones(size(q)); 

    % dvdq weighting
    w_dvdq = w_dvdq_scale*ones(size(q));


    options = optimoptions(@fmincon,'MaxIterations',N_iter, 'StepTolerance',1e-10,'ConstraintTolerance', 1e-10, 'OptimalityTolerance', 1e-10);

    problem = createOptimProblem('fmincon', 'objective', @(x)func_ocvdvdq_cost(x,ocpn,ocpp,[q ocv],w_dvdq,w_ocv), ...
            'x0', x_guess, 'lb', x_lb, 'ub', x_ub, 'options', options);

    ms = MultiStart('Display','iter','UseParallel',true,'FunctionTolerance',1e-100,'XTolerance',1e-100);

        [x_hat, f_val, exitflag, output] = run(ms,problem,N_multistart);
        [cost_hat, ocv_hat, dvdq_mov, dvdq_sim_mov] = func_ocvdvdq_cost(x_hat,ocpn,ocpp,[q ocv],w_dvdq,w_ocv);



    % save the result to the struct
        data_merged(i).ocv_para_hat = x_hat;
        data_merged(i).ocv_hat = ocv_hat;
        data_merged(i).dvdq_mov = dvdq_mov;
        data_merged(i).dvdq_sim_mov = dvdq_sim_mov;
end
toc
    
data_ocv = data_merged;
J = size(data_ocv,2);
% c_mat = lines(J);

for j = 1:size(data_ocv,1)
        
        
    if data_ocv(j).q_ocv(1,2) < data_ocv(j).q_ocv(end,2) % charging ocv
        soc_now =  q(:,1)/q(end,1);
    else
        soc_now =  (q(end,1)-q(:,1))/q(end,1);
    end

    ocv_now = data_ocv.q_ocv;
    ocv_sim_now = data_ocv.ocv_hat;
    dvdq_now = data_ocv.dvdq_mov;
    dvdq_sim_now = data_ocv.dvdq_sim_mov;


    figure()
    set(gcf,'position',[100,100,1600,800])
    
    soc_now = soc_now';

    subplot(1,2,1)
    plot(soc_now,ocv_now(:,2),'-','color','k','LineWidth',2); hold on
    plot(soc_now,ocv_sim_now(:,1),'--','color','y','LineWidth',2);
    plot(soc_now,ocv_sim_now(:,3),'-b');
    yyaxis right
    plot(soc_now,ocv_sim_now(:,2),'-r');

    subplot(1,2,2)
    plot(soc_now,dvdq_now(:,1),'-','color','k','LineWidth',2); hold on
    plot(soc_now,dvdq_sim_now(:,1),'--','color','y','LineWidth',2);
    plot(soc_now,-dvdq_sim_now(:,2),'-r');
    plot(soc_now,dvdq_sim_now(:,3),'-b');

    % Set Y lim
    ylim_top = 2*max(dvdq_now((soc_now > 0.2) & (soc_now < 0.8)));
    ylim([0 ylim_top])

    fig1 = fullfile("G:\공유 드라이브\Battery Software Lab\0_Group Meeting\개인별_미팅자료\허성욱\사용 후 배터리 용량 재생\OCV fitting\Processed_Data\241219 OCV(D)-DCIR-Aging-OCV(C)",sprintf("fitting no.%d%d.fig",h,j));

    saveas(gcf, fig1);


    pause(t_pause_plot)

   %% LLI, LAMp
   data_ocv(1).dQ_LLI = 0;
   data_ocv(1).dQ_LAMp = 0;

    data_ocv(j).LAMp = data_ocv(1).ocv_para_hat(4)...
                        -data_ocv(j).ocv_para_hat(4);

    data_ocv(j).LAMn = data_ocv(1).ocv_para_hat(2)...
                        -data_ocv(j).ocv_para_hat(2); 

    data_ocv(j).LLI = (data_ocv(1).ocv_para_hat(4)*data_ocv(1).ocv_para_hat(3) + data_ocv(1).ocv_para_hat(2)*data_ocv(1).ocv_para_hat(1))...
                        -(data_ocv(j).ocv_para_hat(4)*data_ocv(j).ocv_para_hat(3) + data_ocv(j).ocv_para_hat(2)*data_ocv(j).ocv_para_hat(1)); 

    data_ocv(j).dQ_LLI = (data_ocv(1).ocv_para_hat(4)*(data_ocv(1).ocv_para_hat(3)-1))...
                        -(data_ocv(j).ocv_para_hat(4)*(data_ocv(j).ocv_para_hat(3)-1));


    data_ocv(j).dQ_LAMp = (data_ocv(1).ocv_para_hat(4) - data_ocv(j).ocv_para_hat(4))...
                            *(1-data_ocv(1).ocv_para_hat(3)+data_ocv(1).Q_cell/data_ocv(1).ocv_para_hat(4));


    data_ocv(j).dQ_data = data_ocv(1).Q_cell - data_ocv(j).Q_cell;

    dQ_data_now = data_ocv(j).dQ_data;

    dQ_total_now = data_ocv(j).dQ_LLI + data_ocv(j).dQ_LAMp;


    % manipulate loss scale to be consistent with the data Q
    scale_now = dQ_data_now/dQ_total_now;
    data_ocv(j).dQ_LLI = data_ocv(j).dQ_LLI*scale_now;
    data_ocv(j).dQ_LAMp = data_ocv(j).dQ_LAMp*scale_now;

    data_ocv(j).Qn_cell = ocpn_cap;
    data_ocv(j).Qp_cell = ocpp_cap;

    data_ocv(1).x1 = data_ocv(1).ocv_para_hat(1) + (data_ocv(j).Q_cell/(data_ocv(1).ocv_para_hat(2)));
    data_ocv(1).y1 = data_ocv(1).ocv_para_hat(3) - (data_ocv(j).Q_cell/(data_ocv(2).ocv_para_hat(4)));
    
    data_ocv(2).x1 = data_ocv(2).ocv_para_hat(1) + (data_ocv(j).Q_cell/(data_ocv(1).ocv_para_hat(2)));
    data_ocv(2).y1 = data_ocv(2).ocv_para_hat(3) - (data_ocv(j).Q_cell/(data_ocv(2).ocv_para_hat(4)));
end  

% 

data_ocv(1).cycle = 1;
data_ocv(2).cycle = 100;
data_ocv(1).dQ_LLI = 0;
data_ocv(1).dQ_LAMp = 0;


figure()

bar([data_ocv.cycle],[[data_ocv.dQ_LAMp];[data_ocv.dQ_LLI]]','stacked');
hold on
plot([data_ocv.cycle],[data_ocv.dQ_data], '-sc', 'LineWidth', 2);

legend({'Loss by LAMp','Loss by LLI', 'Loss data (C/20)'},'Location', 'northwest'); 
% ylim([0 20])
    fig2 = fullfile("G:\공유 드라이브\Battery Software Lab\0_Group Meeting\개인별_미팅자료\허성욱\사용 후 배터리 용량 재생\OCV fitting\Processed_Data\241219 OCV(D)-DCIR-Aging-OCV(C)",sprintf("bar(%d).fig",h));

    saveas(gcf, fig2);

save_path = fullfile(data_folder, sprintf('data_ocv(%d).mat',h));
save(save_path,'data_ocv')

end


function [cost, ocv_sim, dvdq, dvdq_sim] = func_ocvdvdq_cost(x,ocpn,ocpp,ocv,w_dvdq,w_ocv)

    % assign parameters
    x_0 = x(1);
    QN = x(2);
    y_0 = x(3);
    QP = x(4);

    Cap = ocv(:, 1);
    if (ocv(end, 2) < ocv(1, 2)) % Discharge OCV
        x_sto = -(Cap - Cap(1)) / QN + x_0;
        y_sto = (Cap - Cap(1)) / QP + y_0;
    else  % Charge OCV
        x_sto = (Cap - Cap(1)) / QN + x_0;
        y_sto = -(Cap - Cap(1)) / QP + y_0;
    end

    ocpn_sim = interp1(ocpn(:, 1), ocpn(:, 2), x_sto, 'linear', 'extrap');
    ocpp_sim = interp1(ocpp(:, 1), ocpp(:, 2), y_sto, 'linear', 'extrap');
    ocv_sim = ocpp_sim - ocpn_sim;
    ocv_sim = [ocv_sim, ocpn_sim, ocpp_sim];
    
    dvdq = diff(ocv(:,2))./diff(ocv(:,1));
    dvdq = [dvdq; dvdq(end)];
    dvdq_sim = diff(ocv_sim(:,1)) ./diff(ocv(:,1));
    dvdq_ocpn = diff(ocpn_sim)./diff(ocv(:,1));
    dvdq_ocpp = diff(ocpp_sim)./diff(ocv(:,1));    

    dvdq_sim = [dvdq_sim dvdq_ocpn dvdq_ocpp]; %% added ocp's dvdqs
    dvdq_sim = [dvdq_sim; dvdq_sim(end,:)];

    % cost 
    cost_ocv = sum(w_ocv.*((ocv_sim(:,1) - ocv(:,2))./ocv(:,2)).^2); % relative error

    cost_dvdq = sum(w_dvdq.*((dvdq_sim(:,1) - dvdq)./dvdq).^2); %% relative error
            % 송주현 수정: relative residual 사용하면 가장자리 제외할 필요 없음.

    % total cost
    cost = cost_ocv + cost_dvdq;


end