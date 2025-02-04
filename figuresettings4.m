function figuresettings4(filename, dpi, width, height)

    alw = 0.5;    
    fsz = 8;   
    lw = 1;

    if nargin < 4
        height = 4; 
    end

    if nargin < 3
        width = 8; 
    end

    if nargin < 2
        dpi = 1200; 
    end

    if nargin < 1
        filename = ['unnamed_', datestr(datetime, 'yyyymmdd_HHMMSS')];
    end
  
    set(0, 'DefaultLineLineWidth', 1);
    set(gcf, 'Units', 'centimeters');
    fig = gcf;
    fig.Position = [0, 0, width, height];

    subplot(1, 2, 1);
    set(gca, 'FontSize', fsz, 'LineWidth', alw, 'FontName', 'Times New Roman','LineWidth', lw);
    ax1 = gca;
    tight1 = ax1.TightInset;
    leftMargin1 = tight1(1);
    bottomMargin1 = tight1(2);
    rightMargin1 = tight1(3);
    topMargin1 = tight1(4);
    ax1.Position = [leftMargin1, bottomMargin1, ...
                    0.5 - leftMargin1 - rightMargin1 / 2, ...
                    1 - topMargin1 - bottomMargin1];


    subplot(1, 2, 2);
    set(gca, 'FontSize', fsz, 'LineWidth', alw, 'FontName', 'Times New Roman','LineWidth', lw);
    ax2 = gca;
    tight2 = ax2.TightInset;
    leftMargin2 = tight2(1);
    bottomMargin2 = tight2(2);
    rightMargin2 = tight2(3);
    topMargin2 = tight2(4);
    ax2.Position = [0.51+leftMargin2, bottomMargin2, ... 
                    0.5 - leftMargin2 - rightMargin2 / 2, ...
                    1 - topMargin2 - bottomMargin2];

    set(gcf, 'InvertHardcopy', 'on');
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [width, height]);
    set(gcf, 'PaperPosition', [0, 0, width, height]);

    savefig([filename, '.fig']);

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
