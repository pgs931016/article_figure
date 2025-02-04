clc;clear;close all

%% Variable name change 

% data_folder = "G:\공유 드라이브\GSP_Data\1C1C\NE_data_ocv.mat"; 
save_path = "G:\공유 드라이브\GSP_Data";


% load(data_folder);
% Normalization
data_merged.data(1).cycles = [0,200,400,600,800,1000];
data_merged.data(2).cycles = [0,220,440,660,880,1100,1320,1540];
data_merged.data(3).cycles = [0,100,200,300,400,500,600];
data_merged.data(4).cycles = [0,50,100,150,200,250,300];
data_merged.data(5).cycles = [0,50,100,150,200];
data_merged.data(6).cycles = [0,10,20,30];



data_merged.data(1).SOH = [0 1.4 2.4 3.4 4.5 6; 0 1.3 2 2.9 3.6 4.1; 0 1.4 2.2 3.1 4 5];

data_merged.data(2).SOH = [0 0.6 1.7 3.1 4.6 5.8 8.2 11; 0 0.7 1.7 3 4.4 5.9 8.2 10.9; 0 0.6 1.7 3 4.5 5.8 8.2 11];

data_merged.data(3).SOH = [0 1.2 1.8 2.8 4.4 9.1 59.9];

data_merged.data(4).SOH = [0 -0.7 1.9 4.4 7 11.4 27.6];

data_merged.data(5).SOH = [0 0.8 1.3 2.1 2.9];

data_merged.data(6).SOH = [0 7 17.5 28.7];


% for j = 1:length(data_merged) % sample 01 normalization
%     data_merged(j).NLAMp = data_merged(j).LAMp/data_merged(1).Q;
%     data_merged(j).NLAMn = data_merged(j).LAMn/data_merged(1).Q;
%     data_merged(j).NLLI = data_merged(j).LLI/data_merged(1).Q;
%     data_merged(j).NdQ_LLI = data_merged(j).dQ_LLI/data_merged(1).Q;
%     data_merged(j).NdQ_LAMp = data_merged(j).dQ_LAMp/data_merged(1).Q;
%     data_merged(j).NdQ_data = data_merged(j).dQ_data/data_merged(1).Q;
%     data_merged(j).NR = data_merged(j).R/data_merged(1).Q;
% end

% colors =    [0.572549019607843	0.368627450980392	0.623529411764706;   % LLI
%              0.882352941176471	0.529411764705882	0.152941176470588;    % LAMp
%              0.937254901960784	0.752941176470588	0];  % 저항
% 
% % % Plot the stacked bar
% subplot(1,2,1)
% hBar = bar([data_merged.cycle], [data_merged.NdQ_LLI; data_merged.NdQ_LAMp;data_merged.NR]', 'stacked');
% 
% for i = 1:length(hBar)
%     hBar(i).FaceColor = 'flat'; 
%     hBar(i).CData = repmat(colors(i, :), size(hBar(i).YData', 3), 1);
% end
% 
% hold on;
% plot([data_merged.cycle], [data_merged.NdQ_data] , '-sc', 'LineWidth', 1); % Cyan
% plot([data_merged.cycle], [data_merged.NdQ_data] + [data_merged.NR], '-sm', 'LineWidth', 1); % Magenta
% 
%    yticks(0:0.01:0.08);
%    ylim([0 0.08]);
% 
% h = legend({'Loss by LLI', 'Loss by LAMp', 'Loss by R', 'Loss data (C/10)', 'Loss data (C/3)'}, 'Location', 'northwest');
%     h.ItemTokenSize(1) = 15;
%     h.FontSize = 4;
% 
%     xlabel('cycle');
%     ylabel('$\Delta Q$', 'Interpreter', 'latex');
% title('고속층전(QC1C) 열화인자 분석');


%fig1 = sprintf('G:\\공유 드라이브\\BSL-Data\\Processed_data\\Hyundai_dataset\\현대차파우치셀 (rOCV,Crate)\\1C1C\\Nbar_plot.jpg');
% fig1 = sprintf('G:\\공유 드라이브\\BSL-Data\Processed_data\\Hyundai_dataset\\현대차파우치셀 (rOCV,Crate)\\QC1C\\QC1C셀들(C20)\\Nbar_plot');
% saveas(gcf, fig1);

% save(save_path,'data_merged');
% cd(save_path);
% filenames = sprintf('1c1cbar');
% figuresettings17(filenames, 1200);



%%%%QC
% data_folder = "G:\공유 드라이브\BSL-Data\Processed_data\Hyundai_dataset\현대차파우치셀 (rOCV,Crate)\QC1C\QC1C사이클(C10)\fig_500cyc\NE_data_ocv2.mat"; 
% save_path = "G:\공유 드라이브\GSP_Data\QC1C cycles";
% load(data_folder);
% 
% for j = 1:length(data_merged) % sample 01 normalization
%     data_merged(j).NLAMp = data_merged(j).LAMp/data_merged(1).Q;
%     data_merged(j).NLAMn = data_merged(j).LAMn/data_merged(1).Q;
%     data_merged(j).NLLI = data_merged(j).LLI/data_merged(1).Q;
%     data_merged(j).NdQ_LLI = data_merged(j).dQ_LLI/data_merged(1).Q;
%     data_merged(j).NdQ_LAMp = data_merged(j).dQ_LAMp/data_merged(1).Q;
%     data_merged(j).NdQ_data = data_merged(j).dQ_data/data_merged(1).Q;
%     data_merged(j).NR = data_merged(j).R/data_merged(1).Q;
% end
% 
% 
% subplot(1,2,2)
% hBar = bar([data_merged(1:6).cycle], [data_merged(1:6).NdQ_LLI; data_merged(1:6).NdQ_LAMp; data_merged(1:6).NR]', 'stacked');
% 
% for i = 1:length(hBar)
%     hBar(i).FaceColor = 'flat'; 
%     hBar(i).CData = repmat(colors(i, :), size(hBar(i).YData', 3), 1);
% end
% 
% hold on;
% 
% plot([data_merged(1:6).cycle], [data_merged(1:6).NdQ_data] , '-sc', 'LineWidth', 1); % Cyan
% plot([data_merged(1:6).cycle], [data_merged(1:6).NdQ_data] + [data_merged(1:6).NR], '-sm', 'LineWidth', 1); % Magenta
% 
% yticks(0:0.02:0.12);
% ylim([0 0.12]);
% 
%     xlabel('cycle');
%     ylabel('$\Delta Q$', 'Interpreter', 'latex');
% 
% h = legend({'Loss by LLI', 'Loss by LAMp', 'Loss by R', 'Loss data (C/10)', 'Loss data (C/3)'}, 'Location', 'northwest');
%     h.ItemTokenSize(1) = 15;
%     h.FontSize = 4;

% data_merged = data_folder.data_merged; 
% save(save_path,'data_merged');
cd(save_path);
filenames = sprintf('new_samples');
% filenames = sprintf('1c1c_35_3sample');
% filenames = sprintf('qc1c_25_1sample');
% filenames = sprintf('qc0.3c_25_1sample');
% filenames = sprintf('1c0.3c_10_1sample');
% filenames = sprintf('2c0.3c_10_1sample');
% figuresettings43a(filenames, 1200);










