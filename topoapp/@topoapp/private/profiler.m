function app = profiler(hObject,eventdata,app)

if strcmp(eventdata,'init') % initialize tool
    fprintf('Profiler init...\n');

    fdicon = imread('profiler_icon.png','png');

    app.gui.TB(end+1) = uipushtool('Parent',app.gui.hTB,...
        'Cdata',fdicon,...
        'TooltipString','Profiler',...
        'Separator','on',...
        'ClickedCallback',{@profiler,app});
else
    fprintf('Profiler is running...\n');

    % Design Matlab UI:
    % http://de.mathworks.com/help/matlab/ref/dialog.html
    % http://de.mathworks.com/help/matlab/ref/uicontrol.html
    % http://de.mathworks.com/help/matlab/ref/uicontrol-properties.html
    % http://de.mathworks.com/help/matlab/creating_guis/write-callbacks-using-the-programmatic-workflow.html#f16-1001315
    

    d = dialog('Position', [0 0 800 600], 'Name', 'Set Profiler properties');

    txt = uicontrol('Parent', d, 'Style', 'text', 'Position', [10 500 200 30],...
      'String', 'Click the close button when you''re done.');

    btn = uicontrol('Parent', d, 'Position', [10 10 100 30], 'String', 'Close',...
      'Callback', 'delete(gcf)');
end
end %
