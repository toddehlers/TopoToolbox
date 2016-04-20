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

    ui_data(1).dialog = d;

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

    ui_data(1).cell_size = uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (11 * label_height)) text_input_width text_input_height],...
      'HorizontalAlignment', 'left', 'String', '28');

    ui_data(1).theta_ref = uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (10 * label_height)) text_input_width text_input_height],...
      'HorizontalAlignment', 'left', 'String', '0.45');

    ui_data(1).remove_spikes = uicontrol('Parent', d, 'Style', 'checkbox', 'Position', [left_x_pos2 (bottom_y_pos2 + (9 * label_height)) text_input_width text_input_height]);

    ui_data(1).step_remover = uicontrol('Parent', d, 'Style', 'checkbox', 'Position', [left_x_pos2 (bottom_y_pos2 + (8 * label_height)) text_input_width text_input_height]);

    ui_data(1).smooth_profile = uicontrol('Parent', d, 'Style', 'checkbox', 'Position', [left_x_pos2 (bottom_y_pos2 + (7 * label_height)) text_input_width text_input_height]);

    ui_data(1).smoothing_window = uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (6 * label_height)) text_input_width text_input_height],...
      'HorizontalAlignment', 'left', 'String', '250');

    ui_data(1).contour_sampling = uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (5 * label_height)) text_input_width text_input_height],...
      'HorizontalAlignment', 'left', 'String', '12.0');

    ui_data(1).auto_ksn = uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (4 * label_height)) text_input_width text_input_height],...
      'HorizontalAlignment', 'left', 'String', '0.5');

    ui_data(1).search_distance = uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (3 * label_height)) text_input_width text_input_height],...
      'HorizontalAlignment', 'left', 'String', '10');

    ui_data(1).minimum_acc = uicontrol('Parent', d, 'Style', 'edit', 'Position', [left_x_pos2 (bottom_y_pos2 + (2 * label_height)) text_input_width text_input_height],...
      'HorizontalAlignment', 'left', 'String', '10');


    uicontrol('Parent', d, 'Position', [((dialog_width - label_width) / 2) bottom_y_pos1 label_width label_height], 'String', 'Save parameters',...
      'Callback', {@save_parameters, ui_data});


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

function save_parameters(hObject, callbackdata, user_data)
  fprintf('Save profiler parameters...\n');

  % Check user input and mark error
  has_error = false;

  cell_size = str2double(user_data(1).cell_size.String);
  if isnan(cell_size)
    user_data(1).cell_size.BackgroundColor = 'r';
    has_error = true;
  else
    user_data(1).cell_size.BackgroundColor = 'w';
  end

  theta_ref = str2double(user_data(1).theta_ref.String);
  if isnan(theta_ref)
    user_data(1).theta_ref.BackgroundColor = 'r';
    has_error = true;
  else
    user_data(1).theta_ref.BackgroundColor = 'w';
  end

  smoothing_window = str2double(user_data(1).smoothing_window.String);
  if isnan(smoothing_window)
    user_data(1).smoothing_window.BackgroundColor = 'r';
    has_error = true;
  else
    user_data(1).smoothing_window.BackgroundColor = 'w';
  end

  contour_sampling = str2double(user_data(1).contour_sampling.String);
  if isnan(contour_sampling)
    user_data(1).contour_sampling.BackgroundColor = 'r';
    has_error = true;
  else
    user_data(1).contour_sampling.BackgroundColor = 'w';
  end

  auto_ksn = str2double(user_data(1).auto_ksn.String);
  if isnan(auto_ksn)
    user_data(1).auto_ksn.BackgroundColor = 'r';
    has_error = true;
  else
    user_data(1).auto_ksn.BackgroundColor = 'w';
  end

  search_distance = str2double(user_data(1).search_distance.String);
  if isnan(search_distance)
    user_data(1).search_distance.BackgroundColor = 'r';
    has_error = true;
  else
    user_data(1).search_distance.BackgroundColor = 'w';
  end

  minimum_acc = str2double(user_data(1).minimum_acc.String);
  if isnan(minimum_acc)
    user_data(1).minimum_acc.BackgroundColor = 'r';
    has_error = true;
  else
    user_data(1).minimum_acc.BackgroundColor = 'w';
  end


  if has_error
    fprintf('An error has occured! Please fix all the red input values\n');
    return;
  end

  fprintf('cell_size: %f\n', cell_size);
  fprintf('theta_ref: %f\n', theta_ref);
  fprintf('smoothing_window: %f\n', smoothing_window);
  fprintf('contour_sampling: %f\n', contour_sampling);
  fprintf('auto_ksn: %f\n', auto_ksn);
  fprintf('search_distance: %f\n', search_distance);
  fprintf('minimum_acc: %f\n', minimum_acc);

  fprintf('remove_spikes: %f\n', user_data(1).remove_spikes.Value);
  fprintf('step_remover: %f\n', user_data(1).step_remover.Value);
  fprintf('smooth_profile: %f\n', user_data(1).smooth_profile.Value);

end
