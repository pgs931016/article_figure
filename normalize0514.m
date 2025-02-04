clc;clear;close all


%% Variable name change 

%data_folder = "G:\공유 드라이브\BSL-Data\Processed_data\Hyundai_dataset\현대차파우치셀 (rOCV,Crate)\QC1C\QC1C사이클(C10)\NE_data_ocv.mat"; 
data_folder = "G:\공유 드라이브\BSL-Data\Processed_data\Hyundai_dataset\현대차파우치셀 (rOCV,Crate)\QC1C\QC1C셀들(C20)\NE_data_ocv.mat"; 

save_path = 'G:\공유 드라이브\BSL-Data\Processed_data\Hyundai_dataset\현대차파우치셀 (rOCV,Crate)\QC1C\QC1C셀들(C20)';

load(data_folder);

%% Normalization


% for j = 1:length(data_merged) % sample 01 normalization
%     data_merged(j).NLAMp = data_merged(j).LAMp/data_merged(1).Q;
%     data_merged(j).NLAMn = data_merged(j).LAMn/data_merged(1).Q;
%     data_merged(j).NLLI = data_merged(j).LLI/data_merged(1).Q;
%     data_merged(j).NdQ_LLI = data_merged(j).dQ_LLI/data_merged(1).Q;
%     data_merged(j).NdQ_LAMp = data_merged(j).dQ_LAMp/data_merged(1).Q;
%     data_merged(j).NdQ_data = data_merged(j).dQ_data/data_merged(1).Q;
%     data_merged(j).NR = data_merged(j).R/data_merged(1).Q;
% end


% Plot the stacked bar
figure();
bar([data_merged.cycle], [data_merged.NdQ_LLI; data_merged.NdQ_LAMp;data_merged.NR]', 'stacked');
hold on;
plot([data_merged.cycle], [data_merged.NdQ_data] , '-sc', 'LineWidth', 2); % Cyan
plot([data_merged.cycle], [data_merged.NdQ_data] + [data_merged.NR], '-sm', 'LineWidth', 2); % Magenta





% Legend and title
legend({'Loss by LLI', 'Loss by LAMp', 'Loss by R', 'Loss data (C/10)', 'Loss data (C/3)'}, 'Location', 'northwest');
title('고속층전(QC1C) 열화인자 분석');


%fig1 = sprintf('G:\\공유 드라이브\\BSL-Data\\Processed_data\\Hyundai_dataset\\현대차파우치셀 (rOCV,Crate)\\1C1C\\Nbar_plot.jpg');
fig1 = sprintf('G:\\공유 드라이브\\BSL-Data\Processed_data\\Hyundai_dataset\\현대차파우치셀 (rOCV,Crate)\\QC1C\\QC1C셀들(C20)\\Nbar_plot');
saveas(gcf, fig1);

%data_merged = data_folder.data_merged; 
save(save_path,'data_merged');

