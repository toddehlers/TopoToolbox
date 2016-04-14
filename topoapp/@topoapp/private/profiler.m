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
end
end %
