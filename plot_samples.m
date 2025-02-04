clc;clear;close all

data_folder1 = "G:\공유 드라이브\GSP_Data\1C1C.mat"; 
data_folder2 = "G:\공유 드라이브\GSP_Data\QC1C cycles.mat";
data_folder3 = "G:\공유 드라이브\GSP_Data\new_samples.mat";
save_path = "G:\공유 드라이브\GSP_Data";

load(data_folder1);
data_merged1 = data_merged;
load(data_folder2);
data_merged2 = data_merged;
load(data_folder3);
data_merged3 = data_merged;

figure(1)
for i = 1:length(data_merged3.data(1).SOH(:,1))
plot(data_merged3.data(1).cycles, data_merged3.data(1).SOH(i,:)); hold on;
end

for i = 1:length(data_merged3.data(2).SOH(:,1))
plot(data_merged3.data(2).cycles, data_merged3.data(2).SOH(i,:)); 
end

plot(data_merged3.data(3).cycles, data_merged3.data(3).SOH); 

plot(data_merged3.data(4).cycles, data_merged3.data(4).SOH); 

plot(data_merged3.data(5).cycles, data_merged3.data(5).SOH); 

plot(data_merged3.data(6).cycles, data_merged3.data(6).SOH); 

h = legend({...
    ['SOH 1C/1C 25', char(176), 'C (1)'], ...
    ['SOH 1C/1C 25', char(176), 'C (2)'], ...
    ['SOH 1C/1C 25', char(176), 'C (3)'], ...
    ['SOH 1C/1C 35', char(176), 'C (1)'], ...
    ['SOH 1C/1C 35', char(176), 'C (2)'], ...
    ['SOH 1C/1C 35', char(176), 'C (3)'], ...
    ['SOH QC/1C 25', char(176), 'C'], ...
    ['SOH QC/0.3C 25', char(176), 'C'], ...
    ['SOH 1C/0.3C 10', char(176), 'C'], ...
    ['SOH 2C/0.3C 10', char(176), 'C']}, ...
    'Location', 'best');

h.ItemTokenSize(1) = 30;
h.FontSize = 5;

grid on;
set(gca, 'YDir', 'reverse');

cd('C:\Users\GSPARK\Documents\GitHub\article_figure');
filenames = sprintf('cap_retention_fig3b');
figuresettings_3a(filenames, 1200);
