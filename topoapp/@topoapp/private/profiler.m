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

    dialog_width = 260;
    dialog_height = 400;

    label_width = 150;
    label_height = 30;

    left_x_pos1 = 10;
    left_x_pos2 = left_x_pos1 + label_width + 10;

    bottom_y_pos1 = 10;
    bottom_y_pos2 = 22;

    text_input_width = 50;
    text_input_height = 20;

    d = dialog('Position', [0 0 dialog_width dialog_height], 'Name', 'Set Profiler properties');

    % All labels:

    uicontrol('Parent', d, 'Style', 'text', 'Position', [left_x_pos1 (bottom_y_pos1 + (11 * label_height)) label_width label_height],...
      'HorizontalAlignment', 'right', 'String', 'Cell size (from DEM):');

    uicontrol('Parent', d, 'Style', 'text', 'Position', [left_x_pos1 (bottom_y_pos1 + (10 * label_height)) label_width label_height],...
        'HorizontalAlignment', 'right', 'String', 'Theta Ref:');

    uicontrol('Parent', d, 'Style', 'text', 'Position', [left_x_pos1 (bottom_y_pos1 + (9 * label_height)) label_width label_height],...
        'HorizontalAlignment', 'right', 'String', 'Remove Spikes ?');

    uicontrol('Parent', d, 'Style', 'text', 'Position', [left_x_pos1 (bottom_y_pos1 + (8 * label_height)) label_width label_height],...
        'HorizontalAlignment', 'right', 'String', 'Step Remover ?');

    uicontrol('Parent', d, 'Style', 'text', 'Position', [left_x_pos1 (bottom_y_pos1 + (7 * label_height)) label_width label_height],...
        'HorizontalAlignment', 'right', 'String', 'Smooth Profile ?');

    uicontrol('Parent', d, 'Style', 'text', 'Position', [left_x_pos1 (bottom_y_pos1 + (6 * label_height)) label_width label_height],...
        'HorizontalAlignment', 'right', 'String', 'Smoothing Window:');

    uicontrol('Parent', d, 'Style', 'text', 'Position', [left_x_pos1 (bottom_y_pos1 + (5 * label_height)) label_width label_height],...
        'HorizontalAlignment', 'right', 'String', 'Contour Sampling Interval:');

    uicontrol('Parent', d, 'Style', 'text', 'Position', [left_x_pos1 (bottom_y_pos1 + (4 * label_height)) label_width label_height],...
        'HorizontalAlignment', 'right', 'String', 'Auto k_sn Window (km):');

    uicontrol('Parent', d, 'Style', 'text', 'Position', [left_x_pos1 (bottom_y_pos1 + (3 * label_height)) label_width label_height],...
        'HorizontalAlignment', 'right', 'String', 'Search Distance:');

    uicontrol('Parent', d, 'Style', 'text', 'Position', [left_x_pos1 (bottom_y_pos1 + (2 * label_height)) label_width label_height],...
        'HorizontalAlignment', 'right', 'String', 'Minimum Accumulation:');


    % All user input elements:

    uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (11 * label_height)) text_input_width text_input_height],...
      'HorizontalAlignment', 'left', 'String', '28');

    uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (10 * label_height)) text_input_width text_input_height],...
      'HorizontalAlignment', 'left', 'String', '0.45');

    uicontrol('Parent', d, 'Style', 'checkbox', 'Position', [left_x_pos2 (bottom_y_pos2 + (9 * label_height)) text_input_width text_input_height]);

    uicontrol('Parent', d, 'Style', 'checkbox', 'Position', [left_x_pos2 (bottom_y_pos2 + (8 * label_height)) text_input_width text_input_height]);

    uicontrol('Parent', d, 'Style', 'checkbox', 'Position', [left_x_pos2 (bottom_y_pos2 + (7 * label_height)) text_input_width text_input_height]);

    uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (6 * label_height)) text_input_width text_input_height],...
      'HorizontalAlignment', 'left', 'String', '250');

    uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (5 * label_height)) text_input_width text_input_height],...
      'HorizontalAlignment', 'left', 'String', '12.0');

    uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (4 * label_height)) text_input_width text_input_height],...
      'HorizontalAlignment', 'left', 'String', '0.5');

    uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (3 * label_height)) text_input_width text_input_height],...
      'HorizontalAlignment', 'left', 'String', '10');

    uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (2 * label_height)) text_input_width text_input_height],...
      'HorizontalAlignment', 'left', 'String', '10');


    uicontrol('Parent', d, 'Position', [((dialog_width - label_width) / 2) bottom_y_pos1 label_width label_height], 'String', 'Save parameters',...
      'Callback', @save_parameters);


    % Cell size (from DEM)
    % Theta ref
    % Remove Spikes ?
    % Step Remover ?
    % Smooth Profile ?
    % Smothing Window
    % Contour Sampling Interval
    % Auto k_sn Window (km)
    % Search Distance
    % Minimum Accumulation

end
end

function save_parameters(hObject,callbackdata)
  fprintf('Save profiler parameters...\n');
end
