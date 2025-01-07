function figuresettings14(filename, dpi, width, height)

    % 기본 설정
    alw = 0.5;    
    fsz = 6;      

    % 입력 매개변수 기본값 처리
    if nargin < 4, height = 4; end
    if nargin < 3, width = 17; end
    if nargin < 2, dpi = 1200; end
    if nargin < 1, filename = ['unnamed_', datestr(datetime, 'yyyymmdd_HHMMSS')]; end

    % Figure 크기 및 스타일 설정
    fig = gcf; % 현재 활성화된 figure 가져오기
    fig.Units = 'centimeters';
    fig.Position = [0, 0, width, height];

    % 기존 subplot 핸들 가져오기
    axHandles = findall(fig, 'Type', 'axes'); % 모든 axes 핸들 찾기
    nSubplots = numel(axHandles); % subplot 개수 확인

    % subplot 레이아웃 계산 (1행 4열 기준)
    totalCols = 4; % 열의 개수
    subplotWidth = 1 / totalCols * 0.69; % subplot 너비 (Figure 너비의 90% 활용)
    subplotHeight = 0.84; % subplot 높이 (Figure 높이의 85%)
    subplotSpacing = 0.1; % subplot 간 간격
    

    % subplot 각각에 대해 설정
    for i = 1:nSubplots
        ax = axHandles(nSubplots - i + 1); % subplot 핸들 (역순)
        set(ax, 'FontSize', fsz, 'LineWidth', alw, 'FontName', 'Times New Roman');


        % subplot의 x, y 위치 계산
        colIndex = mod(i - 1, totalCols); % 열 인덱스 (0부터 시작)
        xPos = max(colIndex * (subplotWidth + subplotSpacing), 0.04); % x 위치
        yPos = (1 - subplotHeight) / 2 + 0.06; % y 위치 (중앙 배치)

        if i == 2
            xPos = xPos + 0.03; % 두 번째 subplot 추가 이동
        end
           if i == 3
            xPos = xPos + 0.01; % 두 번째 subplot 추가 이동
        end


        % Position 설정
        ax.Position = [xPos, yPos, subplotWidth, subplotHeight];
    end

    % Figure 저장을 위한 설정
    set(gcf, 'InvertHardcopy', 'on');
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [width, height]);
    set(gcf, 'PaperPosition', [0, 0, width, height]);

    % 파일 저장
    savefig(gcf,[filename, '.fig']);
    print(gcf, [filename, '.tiff'], '-dtiff', ['-r', num2str(dpi)]);
end









% print('figure','-dpdf','-r2400');  
% 
% date = datetime('now','Format','yyyy-mm-dd');


 % idx = 1;
 %    while true
 %        filename = sprintf('%s_%s_%d', customname, date, idx);
 %        if ~isfile([filename '.pdf']) 
 %            break;
 %        end
 %        idx = idx + 1; 
 %    end
 % 
 %    % Save the figure as a PDF
 %    print(filename, '-dpdf', '-r2400');  


% if ispc % Use Windows ghostscript call
%   system('gswin64c -o -q -sDEVICE=png256 -dEPSCrop -r2400 -oimprovedExample_eps.png improvedExample.eps');
% else % Use Unix/OSX ghostscript call
%   system('gs -o -q -sDEVICE=png256 -dEPSCrop -r2400 -oimprovedExample_eps.png improvedExample.eps');
% end
% end
