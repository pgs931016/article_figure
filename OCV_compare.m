clc;clear;close all

data_folder1 = "G:\공유 드라이브\GSP_Data\NE_characterization\dataNE.mat"; 
data_folder2 = "G:\공유 드라이브\GSP_Data\driving_sample\NE_MCT25oC_HPPC25oC_OCV_KENTECH.mat";

save_path = "G:\공유 드라이브\GSP_Data";

load(data_folder1);
data1 = dataNE;
load(data_folder2);
data2 = NE_OCV;

figure(1)
plot(data1.SOC1, data1.V1); hold on;
plot(data1.SOC1, data1.V2);
plot(data1.SOC1, data1.V3);

plot(data2.SOC, data2.V,':');

h = legend({...
    ['C/10 Chg   25', char(176), 'C (1)'], ...
    ['C/10 Dchg 25', char(176), 'C (2)'], ...
    ['C/10 Avg   25', char(176), 'C (3)'], ...
    ['OCV Sample 25', char(176), 'C']}, ...
    'Location', 'best');

h.ItemTokenSize(1) = 30;
h.FontSize = 8;

xlabel('SOC');  
ylabel('OCV [V]'); 

grid on;

cd('C:\Users\GSPARK\Documents\GitHub\article_figure');
filenames = sprintf('ocv_compare1');
figuresettings12(filenames, 1200);

figure(2)
plot(data1.SOC2, data1.V4); hold on;
plot(data1.SOC2, data1.V5);
plot(data1.SOC2, data1.V6);

plot(data2.SOC, data2.V, ':');

h = legend({...
    ['C/20 Chg   25', char(176), 'C (1)'], ...
    ['C/20 Dchg 25', char(176), 'C (2)'], ...
    ['C/20 Avg   25', char(176), 'C (3)'], ...
    ['OCV Sample 25', char(176), 'C']}, ...
    'Location', 'best');

h.ItemTokenSize(1) = 30;
h.FontSize = 8;
xlabel('SOC');  
ylabel('OCV [V]'); 

grid on;
% set(gca, 'YDir', 'reverse');

cd('C:\Users\GSPARK\Documents\GitHub\article_figure');
filenames = sprintf('ocv_compare2');
figuresettings12(filenames, 1200);

% cd('C:\Users\GSPARK\Documents\GitHub\article_figure');
% filenames = sprintf('cap_retention_fig3b');
% figuresettings_3a(filenames, 1200);