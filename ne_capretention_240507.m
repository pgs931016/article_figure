% figure(1)
% data_D = data_merged(([data_merged.type]=='D')&(abs([data_merged.Q])>0.002)&([data_merged.rptflag]==0)|([data_merged.OCVflag])==2);
% scatter([data_D.cycle],abs([data_D.Q])*1000)
% ylim([2 5]);
% xlabel('Cycle (n)');
% ylabel('Cap (mAh)');
% legend(newNamePart); hold on
clc;clear;close all


% figure()
% Q_D_max = data_merged(([data_merged.type]=='D')&([data_merged.OCVflag])==2);
% data_D.Q = [57.2223 55.8310 55.4425 54.7317 53.6671];
% Crate_Q = [56.2549 54.9090 54.3720 53.7353 52.9119]; 
 
% data_D.Q = [57.3160 56.5940 56.0390 55.4 54.3880 51.6260 30.6680];
% Crate_Q = [56.5790 55.9170 55.5610 55.0090 54.1250 51.4230 25.1460];

% data_D.Q = [57.2223 51.6740 42.7568 44.1603];
% Crate_Q = [56.255 50.856 39.418 40.595];

data_C_Q = [56.9 56.0 55.3 54.7 53.9];
Crate_Q = [56.3 54.9 54.4 53.7 52.9];

data_C_Q = [56.9 56.6 56.3 55.7 54.8 51.8];
Crate_Q = [56.6 55.9 55.6 55.0 54.1 51.4];

Q_D_max = 56.9;

X = {'NE-BOL', '200-2', '350-2', '400-2'}; % X를 셀 배열로 변환
X_numeric = [0, 100, 200, 300, 400, 500, 600];

% X = {'NE-BOL', '200-2', '350-2', '400-2'}; % X를 셀 배열로 변환
% X_numeric = [1, 200, 350, 400];


Q_norm  = abs([data_D.Q]) / abs(Q_D_max);
C_Q_norm = abs([Crate_Q]) / abs(Q_D_max);
plot(X_numeric, Q_norm,'-s', 'LineWidth', 2);
 hold on;
ylim([0 1.2]);
xlabel('Cycle (n)');
ylabel('Cap / Cap0');
plot(X_numeric,C_Q_norm,'-s', 'LineWidth', 2)
legend({'C/20','C/3'})

title('Slow charge Capacity Retention', 'FontSize', 16);
    
fig1 = sprintf('G:\\공유 드라이브\\GSP_Data\\QC1C cycles\\capretention.fig');
saveas(gcf, fig1);


% figure();
% bar([data_ocv.cycle], [data_ocv.dQ_LLI; data_ocv.dQ_LAMp; data_ocv.Q_resistance]', 'stacked');
% hold on;
% plot([data_ocv.cycle], [data_ocv.dQ_data], '-sc', 'LineWidth', 2); % Cyan
% plot([data_ocv.cycle], [data_ocv.dQ_data] + [data_ocv.Q_resistance], '-sm', 'LineWidth', 2); % Magenta
% legend({'Loss by LLI', 'Loss by LAMp', 'Loss by resistance', 'Loss data (c/10)', 'Loss data (c/3)'}, 'Location', 'northwest');
% title('4CPD 4C (25-42) s01 25degC');