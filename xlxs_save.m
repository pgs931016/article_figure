clc;clear;close all

data_folder = 'G:\공유 드라이브\GSP_Data\driving_sample';

% Split the path using the directory separator
splitPath = split(data_folder, filesep);

% Find the index of "Data" (to be replaced)
index = find(strcmp('OCV',splitPath), 1);

% Replace the first "Data" with "Processed_Data"
splitPath{index} = 'Processed_Data';

% Create the new save_path
save_path = strjoin(splitPath, filesep);

% Create the directory if it doesn't exist
if ~exist(save_path, 'dir')
   mkdir(save_path)
end