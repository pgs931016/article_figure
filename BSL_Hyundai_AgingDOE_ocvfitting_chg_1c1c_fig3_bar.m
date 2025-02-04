clc;clear;close all

%% VERSION SUMMARY
% 24-03-17
% 1) Use ocpn_chg 
% 2) Moving Average: i. moving average in ocv, not in dvdq (also have speed-up effect)
% 3) Moving Average: ii. define by number of points 
% 4) Weighting: i. relative rmse is used (diverging part is naturally de-weighted). Deleted codes finding the minimum dvdq points.

data_folder = "G:\공유 드라이브\GSP_Data\1C1C";

%% Config
% hyperparameters
    n_points = 100; % 95 for coincells 400 for NE cell data
    w_ocv_scale = 1;
    w_dvdq_scale = 5;
    N_iter = 100;
    N_multistart = 24;
    t_pause_plot = 0;
Crate_Q = [56.2549, 54.9090, 54.3720, 53.7353, 52.9119];

% load OCP datas
    load ("G:\공유 드라이브\BSL-Data\Processed_data\Hyundai_dataset\Coin_cell\OCV\AHC_(5)_OCV_C20.mat")
    ocpn_raw = OCV_golden.OCVchg;
    x_raw = ocpn_raw(:,1);
    x = linspace(min(x_raw),max(x_raw),n_points)';
    ocpn_raw = ocpn_raw(:,2);
    ocpn_mva = movmean(ocpn_raw,round(length(ocpn_raw)/n_points));
    ocpn = interp1(x_raw,ocpn_mva,x);
    ocpn = [x ocpn];
    clear OCV_golden OCV_all Q_cell x_raw x ocpn_raw ocpn_mva

    load ("G:\공유 드라이브\BSL-Data\Processed_data\Hyundai_dataset\Coin_cell\OCV\CHC_(5)_OCV_C20.mat")
    ocpp_raw = OCV_golden.OCVchg;
    y_raw = ocpp_raw(:,1);
    y = linspace(min(y_raw),max(y_raw),n_points)';
    ocpp_raw = ocpp_raw(:,2);
    ocpp_mva = movmean(ocpp_raw,round(length(ocpp_raw)/n_points));
    ocpp = interp1(y_raw,ocpp_mva,y);
    ocpp = [y ocpp];
    clear OCV_golden OCV_all Q_cell y_raw y ocpp_raw ocpp_mva

% load Merged data
    % see BSL_hyundai_agingDOE_merge.m
    load("G:\공유 드라이브\BSL-Data\Processed_data\Hyundai_dataset\현대차파우치셀 (rOCV,Crate)\1C1C\NE_OCV_Merged.mat")
    %load('G:\Shared drives\BSL_Data2\HNE_AgingDOE_Processed\HNE_FCC\4CPD 1C (25-42)\25degC\HNE_FCC_4CPD 1C (25-42)_25degC_s01_3_6_Merged.mat')

% check data
    % figure(1)
    % yyaxis left
    % plot(ocpn(:,1),ocpn(:,2)); hold on7
    % yyaxis right
    % plot(ocpp(:,1),ocpp(:,2)); hold on

j_count = 0; % to count OCV steps
tic;

for i = 1:size(data_merged,1) % loop over steps
    
    data_merged(i).step = i; % add step number field


    % detect OCV step (**charging)
    if data_merged(i).OCVflag == 1
    
    j_count = j_count+1; % number of OCV now

    
    ocv_raw = data_merged(i).V; % OCV
    i_cc2cv = find(ocv_raw >= max(ocv_raw),1,'first');
    ocv_cc = ocv_raw(1:i_cc2cv);
    ocv_mva = movmean(ocv_cc,round(length(ocv_cc)/n_points));

    q_raw = data_merged(i).cumQ; % cum-capacity **charging
    q_cc = q_raw(1:i_cc2cv);
    q = linspace(min(q_cc),max(q_cc),n_points)';
    
    ocv = interp1(q_cc,ocv_mva,q);
 
    data_merged(i).q_ocv = [q ocv]; % add a field for later use

    
    %% Initial guess
     
            if j_count == 1 % first RPT
                Q_cell = abs(data_merged(i).Q); 
                x_guess = [0,Q_cell,1,Q_cell]; % x0, Qn, y0, Qp
                x_lb = [0,  Q_cell*0.5, 0.8,  Q_cell*0.5];
                x_ub = [0.2,Q_cell*2,   1,  Q_cell*2];

            else % non-first RPT

                % detect the first and the last OCV results
                i_first = find([data_merged(1:i-1).OCVflag] ==1,1,'first'); % firt OCV result -> for upper bounds
                i_last = find([data_merged(1:i-1).OCVflag] ==1,1,'last'); % last OCV result -> for initial guess

                Qp_first = data_merged(i_first).ocv_para_hat(4);
                Qn_first = data_merged(i_first).ocv_para_hat(2);

                Q_cell = abs(data_merged(i).Q); % 1**
                x_guess =   data_merged(i_last).ocv_para_hat; % initial guess from the last RPT
                x_lb =      [0,     Q_cell*0.5,          0.5,     Q_cell*0.5];
                x_ub =      [0.2,   Qn_first,    1,      Qp_first];
                
            end


    %% Weighting

        % OCV weighting
        w_ocv = w_ocv_scale*ones(size(q)); 

        % dvdq weighting
        w_dvdq = w_dvdq_scale*ones(size(q)); %


        %--------- 삭제 부분 적으로 다른 웨이팅 -----------%
        % 부분적으로 웨이팅 주는 부분 삭제. 대신 코스트 함수내에서 relative residual로 코스트 계산. 
        %{
        
        dvdq = diff(ocv)./diff(q);
        dvdq = [dvdq; dvdq(end)];
        dvdq_mov = movmean(dvdq, window_size);

        soc_min1 = 0.1;
        soc_max1 = 0.2;
        soc_min2 = 0.8;
        soc_max2 = 0.9;
        
        soc_range1 = soc(soc >= soc_min1 & soc <= soc_max1);
        dvdq_range1 = dvdq_mov(soc >= soc_min1 & soc <= soc_max1);
        [ocv_min1, ind_min1] = min(dvdq_range1);
        soc_min1 = soc_range1(ind_min1);
        ind_min1_tot = find(soc == soc_min1);
    
        soc_range2 = soc(soc >= soc_min2 & soc <= soc_max2);
        dvdq_range2 = dvdq_mov(soc >= soc_min2 & soc <= soc_max2);
        [ocv_min2, ind_min2] = min(dvdq_range2);
        soc_min2 = soc_range2(ind_min2);
        ind_min2_tot = find(soc == soc_min2);        
        w_dvdq(ind_min1_tot:ind_min2_tot) = dvdq_mov(ind_min1_tot:ind_min2_tot); 
        %}

%         figure()
%         plot(soc,w_dvdq,'-g');
%         xlabel('SOC');
%         ylabel('Weight');
%         xlim([0 1]);
%         title('w1(dvdq)');
%         ylim([0 2])

        %% Fitting 
     
        options = optimoptions(@fmincon,'MaxIterations',N_iter, 'StepTolerance',1e-10,'ConstraintTolerance', 1e-10, 'OptimalityTolerance', 1e-10);

        problem = createOptimProblem('fmincon', 'objective', @(x)func_ocvdvdq_cost(x,ocpn,ocpp,[q ocv],w_dvdq,w_ocv), ...
            'x0', x_guess, 'lb', x_lb, 'ub', x_ub, 'options', options);
        ms = MultiStart('Display','iter','UseParallel',true,'FunctionTolerance',1e-100,'XTolerance',1e-100);

        [x_hat, f_val, exitflag, output] = run(ms,problem,N_multistart);
        [cost_hat, ocv_hat, dvdq_mov, dvdq_sim_mov] = func_ocvdvdq_cost(x_hat,ocpn,ocpp,[q ocv],w_dvdq,w_ocv);

        
%         figure()
%         plot(soc,ocv); hold on
%         plot(soc,ocv_hat); hold on
% 
%         figure()
%         plot(soc,dvdq_mov); hold on
%         plot(soc,dvdq_sim_mov); hold on
        % Set Y lim
%         ylim_top = 2*max(dvdq_mov((soc > 0.2) & (soc < 0.8)));
%         ylim([0 ylim_top])

        % save the result to the struct
        data_merged(i).ocv_para_hat = x_hat;
        data_merged(i).ocv_hat = ocv_hat;
        data_merged(i).dvdq_mov = dvdq_mov;
        data_merged(i).dvdq_sim_mov = dvdq_sim_mov;


    end
end
toc



%% LOOP over OCV Steps 

data_ocv = data_merged([data_merged.OCVflag]' == 1);
J = size(data_ocv,1);
c_mat = lines(J);

for j = 1:size(data_ocv,1)

    % Plot OCV fitting results: OCV and dVdQ plots
    if data_ocv(j).q_ocv(1,2) < data_ocv(j).q_ocv(end,2) % charging ocv
        soc_now =  data_ocv(j).q_ocv(:,1)/data_ocv(j).q_ocv(end,1);
    else
        soc_now =  (data_ocv(j).q_ocv(end,1)-data_ocv(j).q_ocv(:,1))/data_ocv(j).q_ocv(end,1);
    end
    ocv_now = data_ocv(j).q_ocv(:,2);
    ocv_sim_now = data_ocv(j).ocv_hat;
    dvdq_now = data_ocv(j).dvdq_mov;
    dvdq_sim_now = data_ocv(j).dvdq_sim_mov;
    
    % figure()
    % set(gcf,'position',[100,100,1600,800])
    % 
    % subplot(1,2,1)
    % plot(soc_now,ocv_now,'-','color',c_mat(j,:),'LineWidth',2); hold on
    % plot(soc_now,ocv_sim_now(:,1),'--','color',c_mat(j,:),'LineWidth',2);
    % plot(soc_now,ocv_sim_now(:,3),'-b');
    % xlabel('SOC', 'FontSize', 12);  % x축 레이블
    % ylabel('Voltage (V)', 'FontSize', 12);  % y축 레이블
    % yyaxis right
    % plot(soc_now,ocv_sim_now(:,2),'-r');
    % % title('OCV 피팅')
    % 
    % 
    % subplot(1,2,2)
    % plot(soc_now,dvdq_now(:,1),'-','color',c_mat(j,:),'LineWidth',2); hold on
    % plot(soc_now,dvdq_sim_now(:,1),'--','color',c_mat(j,:),'LineWidth',2);
    % plot(soc_now,-dvdq_sim_now(:,2),'-r');
    % plot(soc_now,dvdq_sim_now(:,3),'-b');
    % % plot(soc_now,dvdq_sim_now(:,4),'-g');
    % % title('dV 피팅')
    % 
    % xlabel('SOC', 'FontSize', 12);  % x축 레이블
    % ylabel('dV/dQ (V/Ah)', 'FontSize', 12);  % y축 레이블]
    % 
    %     % Set Y lim
    %     ylim_top = 2*max(dvdq_now((soc_now > 0.2) & (soc_now < 0.8)));
    %     ylim([0 ylim_top])
    % 
    % fig1 = sprintf('G:\\공유 드라이브\\GSP_Data\\1C1C\\%d.fig', j);
    % savefig(gcf, fig1);
    % pause(t_pause_plot)


    %% LLI, LAMp
    data_ocv(j).LAMp = data_ocv(1).ocv_para_hat(4)...
                        -data_ocv(j).ocv_para_hat(4);
    
    data_ocv(j).LAMn = data_ocv(1).ocv_para_hat(2)...
                        -data_ocv(j).ocv_para_hat(2); 
    
    data_ocv(j).LLI = (data_ocv(1).ocv_para_hat(4)*data_ocv(1).ocv_para_hat(3) + data_ocv(1).ocv_para_hat(2)*data_ocv(1).ocv_para_hat(1))...
                        -(data_ocv(j).ocv_para_hat(4)*data_ocv(j).ocv_para_hat(3) + data_ocv(j).ocv_para_hat(2)*data_ocv(j).ocv_para_hat(1)); 
    
    data_ocv(j).dQ_LLI = (data_ocv(1).ocv_para_hat(4)*(data_ocv(1).ocv_para_hat(3)-1))...
                        -(data_ocv(j).ocv_para_hat(4)*(data_ocv(j).ocv_para_hat(3)-1));
    
    
    data_ocv(j).dQ_LAMp = (data_ocv(1).ocv_para_hat(4) - data_ocv(j).ocv_para_hat(4))...
                            *(1-data_ocv(1).ocv_para_hat(3)+data_ocv(1).Q/data_ocv(1).ocv_para_hat(4));
    
    
    data_ocv(j).dQ_data = data_ocv(1).Q - data_ocv(j).Q;
    
    dQ_data_now = data_ocv(j).dQ_data;

    dQ_total_now = data_ocv(j).dQ_LLI + data_ocv(j).dQ_LAMp;
    
    data_ocv(j).R = [abs(data_merged(4).Q)] - [Crate_Q(j)] - [data_ocv(j).dQ_data];
    
    data_ocv(j).Crate_Q = [Crate_Q(j)];

    % manipulate loss scale to be consistent with the data Q
    scale_now = dQ_data_now/dQ_total_now;
    data_ocv(j).dQ_LLI = data_ocv(j).dQ_LLI*scale_now;
    data_ocv(j).dQ_LAMp = data_ocv(j).dQ_LAMp*scale_now;

    data_ocv(1).x1 = data_ocv(1).ocv_para_hat(1) + (data_ocv(j).Q_cell/(data_ocv(1).ocv_para_hat(2)));
    data_ocv(1).y1 = data_ocv(1).ocv_para_hat(3) - (data_ocv(j).Q_cell/(data_ocv(2).ocv_para_hat(4)));
    
    data_ocv(2).x1 = data_ocv(2).ocv_para_hat(1) + (data_ocv(j).Q_cell/(data_ocv(1).ocv_para_hat(2)));
    data_ocv(2).y1 = data_ocv(2).ocv_para_hat(3) - (data_ocv(j).Q_cell/(data_ocv(2).ocv_para_hat(4)));
    
end
data_ocv(1).dQ_LLI = 0;
data_ocv(1).dQ_LAMp = 0;
colors =    [0.572549019607843	0.368627450980392	0.623529411764706;   % LLI
             0.882352941176471	0.529411764705882	0.152941176470588;    % LAMp
             0.937254901960784	0.752941176470588	0];  % 저항
        
      

hBar = bar([data_ocv.cycle],[[data_ocv.dQ_LLI];[data_ocv.dQ_LAMp];[abs(data_merged(4).Q)] - [Crate_Q] - [data_ocv.dQ_data]], 'stacked');

for i = 1:length(hBar)
    hBar(i).FaceColor = 'flat'; 
    hBar(i).CData = repmat(colors(i, :), size(hBar(i).YData', 3), 1);
end

hold on;

plot([data_ocv.cycle],[data_ocv.dQ_data], '-sc', 'LineWidth', 1);
plot([data_ocv.cycle],[data_ocv.dQ_data] + [abs(data_merged(4).Q)] - [Crate_Q]- [data_ocv.dQ_data],'-sm', 'LineWidth', 1)
legend({'Loss by LLI', 'Loss by LAMp', 'Loss by R', 'Loss data (C/10)', 'Loss data (C/3)'},'Location', 'northwest'); 
xlabel('Cycle')
ylabel('$\Delta Q$ [Ah]', 'Interpreter', 'latex','FontName', 'Arial','FontWeight', 'bold')
ylim([0 4.5])
% title('완속층전(1C1C) 대형셀 열화 인자');
% fig2 = sprintf('G:\\공유 드라이브\\BSL-Data\\Processed_data\\Hyundai_dataset\\현대차파우치셀 (rOCV,Crate)\\1C1C\\bar_plot.fig');
% saveas(gcf, fig2);

% save_path = 'G:\공유 드라이브\BSL-Data\Processed_data\Hyundai_dataset\현대차파우치셀 (rOCV,Crate)\1C1C\NE_data_ocv';
% data_merged = data_ocv; 
% save(save_path,'data_merged');

xlabel('Cycle')
ylabel('$\Delta Q$ [Ah]', 'Interpreter', 'latex','FontName', 'Arial','FontWeight', 'bold')

data_folder = "G:\공유 드라이브\GSP_Data\1C1C";
cd(data_folder);
filenames = sprintf('1c1cbar');
figuresettings3a(filenames, 1200);

% save_folder = data_folder; 
% 파일 전체 경로
% fig_path = fullfile(save_folder, fig_name);

% Figure 저장
% savefig(fig_path)
% print(fig_path, '-dpdf', '-r2400')

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