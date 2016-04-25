function app = profiler(hObject,eventdata,app)

if strcmp(eventdata,'init') % initialize tool
    fprintf('Profiler init...\n');

    fdicon = imread('profiler_icon.png','png');

    app.gui.TB(end+1) = uipushtool('Parent',app.gui.hTB,...
        'Cdata',fdicon,...
        'TooltipString','Profiler',...
        'Separator','on',...
        'ClickedCallback',{@profiler,app});

    app.profiler_config(1).file_name = app.profiler_config(1).dem_path;
    % app.profiler_config(1).file_name = pwd;
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

    ui_arrays(1).number_of_items = numel(ui_arrays(1).text_label);

    % Position indices:
    ui_arrays(1).text_input = [4 5 6 7 8 12 13];
    ui_arrays(1).check_box = [9 10 11];

    % Default values:
    ui_arrays(1).default_values = {'10', '10', '0.5', '12.0', '250', '0', '0', '0', '0.45', '30'};

    for i = 1:ui_arrays(1).number_of_items
      uicontrol('Parent', d, 'Style', 'text', 'Position', [left_x_pos1 (bottom_y_pos1 + ((i + 3) * label_height)) label_width label_height],...
        'HorizontalAlignment', 'right', 'String', ui_arrays(1).text_label{i});
    end

    % All user input elements:
    % TODO: Fix tab order sequence, fix index of data values

    for i = ui_arrays(1).text_input
      ui_data(i).control = uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (i * label_height)) text_input_width text_input_height],...
        'HorizontalAlignment', 'left', 'String', ui_arrays(1).default_values{i - 3});
    end

    for i = ui_arrays(1).check_box
      ui_data(i).control = uicontrol('Parent', d, 'Style', 'checkbox', 'Position', [left_x_pos2 (bottom_y_pos2 + (i * label_height)) text_input_width text_input_height]);
    end

    uicontrol('Parent', d, 'Position', [((dialog_width - label_width) / 2) (bottom_y_pos1 + (2 * label_height)) label_width label_height], 'String', 'Load parameters',...
      'Callback', {@load_parameters, ui_data, ui_arrays, app});

    uicontrol('Parent', d, 'Position', [((dialog_width - label_width) / 2) (bottom_y_pos1 + label_height) label_width label_height], 'String', 'Save parameters',...
      'Callback', {@save_parameters, ui_data, ui_arrays, app});

    uicontrol('Parent', d, 'Position', [((dialog_width - label_width) / 2) bottom_y_pos1 label_width label_height], 'String', 'Run profiler',...
      'Callback', {@run_profiler, ui_data, ui_arrays, app});


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

function has_error = check_parameters(ui_data, ui_arrays)
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

  last_item = ui_arrays(1).number_of_items + 3;

  app.profiler_config(1).run_parameter(1) = ui_data(last_item).value;
  app.profiler_config(1).run_parameter(2) = ui_data(last_item - 1).value;
  app.profiler_config(1).run_parameter(3) = ui_data(last_item - 2).value;
  app.profiler_config(1).run_parameter(4) = ui_data(last_item - 3).value;
  app.profiler_config(1).run_parameter(5) = ui_data(last_item - 4).value;
  app.profiler_config(1).run_parameter(6) = ui_data(last_item - 5).value;
  app.profiler_config(1).run_parameter(7) = ui_data(last_item - 6).value;
  app.profiler_config(1).run_parameter(8) = ui_data(last_item - 7).value;
  app.profiler_config(1).run_parameter(9) = ui_data(last_item - 8).value;
  app.profiler_config(1).run_parameter(10) = ui_data(last_item - 9).value);
end

function save_parameters(hObject, callbackdata, ui_data, ui_arrays, app)
  fprintf('Save profiler parameters...\n');

  % Check user input and mark error
  has_error = check_parameters(ui_data, ui_arrays);
  if has_error
    return;
  end

  for i = ui_arrays(1).check_box
    ui_data(i).value = ui_data(i).control.Value;
  end

  for i = 1:ui_arrays(1).number_of_items
    fprintf('%s: %f\n', ui_arrays(1).text_label{i}, ui_data(i + 3).value);
  end

  [filename, pathname, filterIndex] = uiputfile('*', 'Select parameter file', app.profiler_config(1).file_name);
  if isequal(filename, 0)
    fprintf('User selected cancel\n');
  else
    new_config_file = fullfile(pathname, filename);
    fprintf('User selected: %s\n', new_config_file);

    [fileID, error_msg] = fopen(new_config_file, 'w');
    if fileID < 0
      fprintf('Could not open selected file "%s"\nThere was an error: %s\n', new_config_file, error_msg);
      errordlg('Error wile opening file', 'IO error');
    else
      last_item = ui_arrays(1).number_of_items + 3;
      % fprintf(fileID, '%f %f', ui_data(last_item).value, ui_data(last_item - 1).value);
      v1 = app.profiler_config(1).run_parameter(1);
      v2 = app.profiler_config(1).run_parameter(2);
      v3 = app.profiler_config(1).run_parameter(3);
      v4 = app.profiler_config(1).run_parameter(4);
      v5 = app.profiler_config(1).run_parameter(5);
      v6 = app.profiler_config(1).run_parameter(6);
      v7 = app.profiler_config(1).run_parameter(7);
      v8 = app.profiler_config(1).run_parameter(8);
      v9 = app.profiler_config(1).run_parameter(9);
      v10 = app.profiler_config(1).run_parameter(10);
      fprintf(fileID, '%f %f %f %f %f %f %f %f %f %f\n', v1, v2, v3, v4, v5, v6, v7, v8, v9, v10);
      fclose(fileID);
      app.profiler_config(1).file_name = new_config_file;
    end
  end
end

function load_parameters(hObject, callbackdata, ui_data, ui_arrays, app)
  fprintf('Load profiler parameters...\n');

  [filename, pathname] = uigetfile('*', 'Select parameter file', app.profiler_config(1).file_name);
  if isequal(filename, 0)
    fprintf('User selected cancel\n');
  else
    new_config_file = fullfile(pathname, filename);
    fprintf('User selected: %s\n', new_config_file);

    [fileID, error_msg] = fopen(new_config_file, 'r');
    if fileID < 0
      fprintf('Could not open selected file "%s"\nThere was an error: %s\n', new_config_file, error_msg);
      errordlg('Error wile opening file', 'IO error');
    else
      content = textscan(fileID, '%f %f %f %f %f %f %f %f %f %f');
      fclose(fileID);
      % disp(content)

      has_error = false;

      for i = 1:ui_arrays(1).number_of_items
        if isnan(content{i})
          fprintf('item %d of file %s is invalid!\n', i, new_config_file);
          has_error = true;
        else
          if strcmp(ui_data(i + 3).control.Style, 'edit')
            ui_data(i + 3).control.String = num2str(content{ui_arrays(1).number_of_items - i + 1});
          else
            if content{ui_arrays(1).number_of_items - i + 1} ~= 0.0
              ui_data(i + 3).control.Value = 1;
            else
              ui_data(i + 3).control.Value = 0;
            end
          end
        end
      end

      if ~has_error
        app.profiler_config(1).file_name = new_config_file;
      end

    end
  end
end

function run_profiler(hObject, callbackdata, ui_data, ui_arrays, app)
  fprintf('Run profiler...\n');

  % Check user input and mark error
  has_error = check_parameters(ui_data, ui_arrays);
  if has_error
    return;
  end

  d = ui_data(1).control;

  if ishandle(d)
    delete(d);
  end

  profile51(app);

end
