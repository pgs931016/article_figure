% BSL OCV Code
clc; clear; close all;

%% Interface

% data_merged folder
addpath = 'C:\Users\GSPARK\Desktop\Hcode';
data_folder = 'G:\공유 드라이브\BSL-Data\Processed_data\Hyundai_dataset\현대차파우치셀 (rOCV,Crate)\1C1C';
cd(data_folder);
[save_folder,save_name] = fileparts(data_folder); 


% cathode, fullcell, or anode
id_cfa =2; % 1 for cathode, 2 for fullcell, 3 for anode, 0 for automatic (not yet implemented)

% OCV steps
    % chg/dis sub notation : with respect to the full cell operation
step_ocv_chg = 1;
step_ocv_dis = 1;

% parameters
y1 = 0.215685; % cathode stoic at soc = 100%. reference : AVL NMC811
x_golden = 0.5;



%% Engine
slash = filesep;
files = dir([data_folder slash 'NE_data_ocv.mat']);

for i = 1:length(files)
    fullpath_now = [data_folder slash files(i).name]; % path for i-th file in the folder
    load(fullpath_now);

    % for j = 1:length(data_merged)
    % calculate capabilities
    %     if length(data_merged(j).t) > 1
    %         data_merged(j).Q = abs(trapz(data_merged(j).t,data_merged(j).I))/3600; %[Ah]
    %         data_merged(j).cumQ = abs(cumtrapz(data_merged(j).t,data_merged(j).I))/3600; %[Ah]
    %     end
    % end

    data_merged(step_ocv_chg).soc = data_merged(step_ocv_chg).cumQ/data_merged(step_ocv_chg).Q;
    data_merged(step_ocv_dis).soc = 1-data_merged(step_ocv_dis).cumQ/data_merged(step_ocv_dis).Q;

    % stoichiometry for cathode and anode (not for fullcell)
    if id_cfa == 1 % cathode
        data_merged(step_ocv_chg).stoic = 1-(1-y1)*data_merged(step_ocv_chg).soc;
        data_merged(step_ocv_dis).stoic = 1-(1-y1)*data_merged(step_ocv_dis).soc;
    elseif id_cfa == 3 % anode
        data_merged(step_ocv_chg).stoic = data_merged(step_ocv_chg).soc;
        data_merged(step_ocv_dis).stoic = data_merged(step_ocv_dis).soc;
    elseif id_cfa == 2 % full cell
        % stoic is not defined for full cell.
    end


    % make an overall OCV struct
    if id_cfa == 1 || id_cfa == 3 % cathode or anode halfcell
        x_chg = data_merged(step_ocv_chg).stoic;  
        y_chg = data_merged(step_ocv_chg).V;
        z_chg = data_merged(step_ocv_chg).cumQ;
        x_dis = data_merged(step_ocv_dis).stoic;
        y_dis = data_merged(step_ocv_dis).V;
        z_dis = data_merged(step_ocv_dis).cumQ;
    elseif id_cfa == 2 % fullcell
        x_chg = data_merged(step_ocv_chg).soc;
        y_chg = data_merged(step_ocv_chg).V;
        z_chg = data_merged(step_ocv_chg).cumQ;
        x_dis = data_merged(step_ocv_dis).soc;
        y_dis = data_merged(step_ocv_dis).V;
        z_dis = data_merged(step_ocv_dis).cumQ;

    end

    OCV_all(i).OCVchg = [1-x_chg y_chg z_chg];
    OCV_all(i).OCVdis = [1-x_dis y_dis z_dis];

    OCV_all(i).Qchg = data_merged(step_ocv_chg).Q;
    OCV_all(i).Qdis = data_merged(step_ocv_dis).Q;


    % golden criteria
    OCV_all(i).y_golden = (interp1(x_chg,y_chg,0.5)+ interp1(x_dis,y_dis,0.5))/2; 
    

    % plot
    color_mat=lines(4);
    % if i == 1
    % figure(1)
    % end
    % hold on; box on;

    plot(1-x_chg,y_chg,'-',"Color",'[0.027, 0.451, 0.761]')
    % plot(x_dis,y_dis,'-','Color',color_mat(2,:),'LineWidth', 2)
end

   xticks(0:0.2:1);  
   xlim([0 1]);  
   yticks(2.8:0.2:4.4);
   ylim([2.8 4.4]);
   % yticks([0 0.2 1.6]);
   % ylim([0 1.6]);

   ax = gca;
   ax.FontWeight = 'bold';

   xlabel('SOC');
   ylabel('FC/OCV [V]');
   %xlabel('x in Li_{x}C_{6}', 'FontSize', 12, 'FontWeight', 'bold');%anode
   %xlabel('y in Li_{y}MO_{2}', 'FontSize', 12, 'FontWeight','bold');%cathode
   %ylabel('NE/OCP [V]', 'FontSize', 12, 'FontWeight', 'bold');
   %title('Full-Cell', 'FontSize', 12, 'FontWeight', 'bold'); 
   figuresettings8(files(i).name(1:end-4), 1200);

%    save_fullpath = [save_folder filesep save_name '.mat'];
%    OCV_golden = OCV_all;
% save(save_fullpath,'OCV_golden')
% 
% %    ax = gca;  % 현재 축을 가져오기
% % 
% % ax.YLim(1) = floor(ax.YLim(1) / 0.5) * 0.5;  % 0.5 간격으로 내림
% % ax.YLim(2) = floor(ax.YLim(2) / 0.5) * 0.5;  % 0.5 간격으로 내림
% 
%    figuresettings(files(i).name(1:end-4), 1200);
%     %savefig(fig1)
%     % print(fig1,'-dtiff','-r1200');
% 
% end
% 
% % select an golden OCV
% [~,i_golden] = min(abs([OCV_all.y_golden]-median([OCV_all.y_golden])));
% OCV_golden.i_golden = i_golden;
% 
% % save OCV struct
% OCV_golden.OCVchg = OCV_all(1,i_golden).OCVchg;
% OCV_golden.OCVdis = OCV_all(1,i_golden).OCVdis;
% 
% 
% % plot
% 
%    plot(OCV_golden.OCVchg(:,1),OCV_golden.OCVchg(:,2),'-','Color','k','LineWidth', 2)
%    %xlabel('x in Li_{x}C_{6}', 'FontSize', 12, 'FontWeight', 'bold');
%    %xlabel('y in Li_{y}MO_{2}', 'FontSize', 12, 'FontWeight', 'bold');
%    xlabel('SOC', 'FontSize', 12, 'FontWeight', 'bold');
%    %ylabel('NE/OCP [V]', 'FontSize', 12, 'FontWeight', 'bold');
%    ylabel('OCV [V]', 'FontSize', 12, 'FontWeight', 'bold');

% title_str = strjoin(strsplit(save_name,'_'),' ');
% title(title_str)

% plot(OCV_golden.OCVdis(:,1),OCV_golden.OCVdis(:,2),'-','Color',color_mat(4,:),'LineWidth', 2)

   % xticks(0:0.2:1);  
   % xlim([0 1]);  
   % % yticks(2.8:0.2:4.4);
   % % ylim([2.8 4.4]);
   % yticks(0:0.2:1.6);
   % ylim([0 1.6]);       
   % ax = gca;
   % ax.FontWeight = 'bold';
   %  save_path = fullfile(data_merged_folder,save_name);
   
%    ax = gca;  % 현재 축을 가져오기

% ax.YLim(1) = floor(ax.YLim(1) / 0.5) * 0.5;  % 0.5 간격으로 내림
% ax.YLim(2) = floor(ax.YLim(2) / 0.5) * 0.5;  % 0.5 간격으로 내림
   % figuresettings(save_name, 1200);

    % savefig(fig2)
    % print(fig2,'-dpdf','-r1200');

% save
% save_fullpath = [save_folder filesep save_name '.mat'];
% save(save_fullpath,'OCV_all')
