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
    % Design Matlab UI:
    % http://de.mathworks.com/help/matlab/ref/dialog.html
    % http://de.mathworks.com/help/matlab/ref/uicontrol.html
    % http://de.mathworks.com/help/matlab/ref/uicontrol-properties.html
    % http://de.mathworks.com/help/matlab/creating_guis/write-callbacks-using-the-programmatic-workflow.html#f16-1001315

    dialog_width = 260;
    dialog_height = 460;

    label_width = 150;
    label_height = 30;

    left_x_pos1 = 10;
    left_x_pos2 = left_x_pos1 + label_width + 10;

    bottom_y_pos1 = 10;
    bottom_y_pos2 = 22;

    text_input_width = 50;
    text_input_height = 20;

    d = dialog('Position', [0 0 dialog_width dialog_height], 'Name', 'Set Profiler properties');

    ui_data(1).control = d;
    ui_data(1).value = 0;

    % All labels:

    % Texts:
    ui_arrays(1).text_label = {'Minimum Accumulation:', 'Search Distance:', 'Auto k_sn Window (km):', 'Contour Sampling Interval:', 'Smoothing Window:', ...
      'Smooth Profile ?', 'Step Remover ?', 'Remove Spikes ?', 'Theta Ref:', 'Cell size (from DEM):'};

    % Position indices:
    ui_arrays(1).text_input = [4 5 6 7 8 12 13];
    ui_arrays(1).check_box = [9 10 11];

    % Default values:
    ui_arrays(1).default_values = {'10', '10', '0.5', '12.0', '250', '0', '0', '0', '0.45', '30'};

    for i = 1:numel(ui_arrays(1).text_label)
      uicontrol('Parent', d, 'Style', 'text', 'Position', [left_x_pos1 (bottom_y_pos1 + ((i + 3) * label_height)) label_width label_height],...
        'HorizontalAlignment', 'right', 'String', ui_arrays(1).text_label{i});
    end

    % All user input elements:

    for i = ui_arrays(1).text_input
      ui_data(i).control = uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (i * label_height)) text_input_width text_input_height],...
        'HorizontalAlignment', 'left', 'String', ui_arrays(1).default_values{i - 3});
    end

    for i = ui_arrays(1).check_box
      ui_data(i).control = uicontrol('Parent', d, 'Style', 'checkbox', 'Position', [left_x_pos2 (bottom_y_pos2 + (i * label_height)) text_input_width text_input_height]);
    end

    uicontrol('Parent', d, 'Position', [((dialog_width - label_width) / 2) (bottom_y_pos1 + (2 * label_height)) label_width label_height], 'String', 'Load parameters',...
      'Callback', {@load_parameters, ui_data, ui_arrays});

    uicontrol('Parent', d, 'Position', [((dialog_width - label_width) / 2) (bottom_y_pos1 + label_height) label_width label_height], 'String', 'Save parameters',...
      'Callback', {@save_parameters, ui_data, ui_arrays});

    uicontrol('Parent', d, 'Position', [((dialog_width - label_width) / 2) bottom_y_pos1 label_width label_height], 'String', 'Run profiler',...
      'Callback', {@run_profiler, ui_data, ui_arrays});


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

function save_parameters(hObject, callbackdata, ui_data, ui_arrays)
  fprintf('Save profiler parameters...\n');

  % Check user input and mark error
  has_error = false;

  for i = ui_arrays(1).text_input
    ui_data(i).value = str2double(ui_data(i).control.String);
    if isnan(ui_data(i).value)
      ui_data(i).control.BackgroundColor = 'r';
      has_error = true;
    else
      ui_data(i).control.BackgroundColor = 'w';
    end
  end

  if has_error
    fprintf('An error has occured! Please fix all the red input values!\n');
    errordlg('Please fix all the red values!', 'Numeric input error');
    return;
  end

  for i = ui_arrays(1).check_box
    ui_data(i).value = ui_data(i).control.Value;
  end

  for i = 1:numel(ui_arrays(1).text_label)
    fprintf('%s: %f\n', ui_arrays(1).text_label{i}, ui_data(i + 3).value);
  end
end

function load_parameters(hObject, callbackdata, ui_data, ui_arrays)
  fprintf('Load profiler parameters...\n');
end

function run_profiler(hObject, callbackdata, ui_data, ui_arrays)
  fprintf('Run profiler...\n');
end
