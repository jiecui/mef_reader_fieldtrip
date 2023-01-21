function view_MED(varargin)

    %   view_MED([session], [password])
    
    %   Copyright Dark Horse Neuro, 2021

    % ------------ Defaults ---------------

    DEFAULT_PASSWORD = 'L2_password';  % example_data password == 'L1_password' or 'L2_password'
    DEFAULT_DATA_DIRECTORY = pwd;
    DEFAULT_WINDOW_USECS = 1e7;  % 10 seconds

    % ---------- Clean mex slate ----------

    evalin('base', 'clear load_session matrix_MED_exec read_MED_exec add_customer create_license send_authentication_code')

    % ------------ GUI layout -------------

    OS = computer;
    DIR_DELIM = '/';
    switch OS
        case 'MACI64'       % MacOS
            SYS_FONT_SIZE = 10;
        case 'GLNXA64'      % Linux
            SYS_FONT_SIZE = 7;
        case 'PCWIN64'      % Windows
            SYS_FONT_SIZE = 8;
            DIR_DELIM = '\';
        otherwise           % Unknown OS
            SYS_FONT_SIZE = 9;
    end

    [READ_MED_PATH, ~, ~] = fileparts(which('read_MED'));
    RESOURCES = [READ_MED_PATH DIR_DELIM 'Resources'];
    if (isempty(which('read_MED_exec')))
        addpath(RESOURCES, READ_MED_PATH, '-begin');
        savepath;
        msg = ['Added ', RESOURCES, ' to your search path.' newline];
        beep
        fprintf(2, '%s', msg);  % 2 == stderr, so prints in red in command window
    end

    FORWARD = 1;
    BACKWARD = 2;
    LIGHT_GRAY = [0.9 0.9 0.9];
    DARK_GRAY = [0.45 0.45 0.45];
    VERY_DARK_GRAY = [0.25 0.25 0.25];
    DARK_GREEN = [0.0 0.45 0.0];

    panel_color = get(0,'DefaultUicontrolBackgroundColor');
    pix_per_cm = get(groot, 'ScreenPixelsPerInch') / 2.54;
    points_per_cm = 28.3465;
    points_per_pix = points_per_cm / pix_per_cm;
    label_font_size = SYS_FONT_SIZE;

    logo = imread([RESOURCES DIR_DELIM 'Dark Horse Neuro Logo.png']);
    [neh_signal, neh_sf] = audioread([RESOURCES DIR_DELIM 'neh.wav']);
    neh_signal = neh_signal / 4;
    scale = 1;
    uV_per_cm = 1;
    screen_size = get(groot, 'ScreenSize');
    screen_x_pix = screen_size(3);
    screen_y_pix = screen_size(4);
    sess_map_ax_height = 11;
    sess_map_ax_width = 0;
    data_ax_width = 0;
    data_ax_height = 0;
    data_ax_left = 0;
    data_ax_right = 0;
    data_ax_bot = 0;
    data_ax_top = 0;
    export_num = 0;
    discont_num = 0;
    ax_mouse_down = false;

    % Figure
    fig = figure('Units', 'pixels', ...
        'Position',[100 50 (screen_x_pix - 200) (screen_y_pix - 150)], ...
        'HandleVisibility', 'callback', ...
        'IntegerHandle', 'off', ... 
        'Renderer', 'painters', ...
        'Toolbar', 'none', ...
        'MenuBar', 'none', ...
        'NumberTitle', 'off', ...
        'Visible', 'off', ...
        'Interruptible', 'on', ...
        'BusyAction', 'cancel',  ...
        'KeyPressFcn', @key_press_callback, ...
        'KeyReleaseFcn', @key_release_callback, ...
        'CloseRequestFcn', @figure_close_callback, ...
        'ResizeFcn', @resize, ...
        'WindowButtonDownFcn', @ax_mouse_down_callback, ...
        'WindowButtonUpFcn', @ax_mouse_up_callback);

    % Data Axes
    data_ax = axes('Parent', fig, ...
        'Units', 'pixels', ...
        'TickDir', 'out', ...
        'TickLength',[.005, 0], ...
        'Box', 'off', ...
        'XTick', [], ...
        'YTick', [], ...
        'XLimMode', 'manual', ...
        'YLimMode', 'manual', ...
        'YDir', 'reverse');
    colors = get(data_ax, 'ColorOrder');
    n_colors = size(colors, 1);
    mono_color = colors(1, :);
    
    % Axis Time Strings
    time_str_ax = axes('Parent', fig, ...
        'Units', 'pixels', ...
        'XTick', [], ...
        'YTick', [], ...
        'Visible', 'off', ...
        'XLimMode', 'manual', ...
        'YLimMode', 'manual', ...
        'ButtonDownFcn', @sess_map_callback);

    axis_start_time_string = text(time_str_ax, ...
        'Units', 'pixels', ...
        'String', '', ...
        'FontSize', SYS_FONT_SIZE, ...
        'FontAngle', 'italic', ...
        'HorizontalAlignment', 'left', ...
        'ButtonDownFcn', @axis_time_callback);

    axis_end_time_string = text(time_str_ax, ...
        'Units', 'pixels', ...
        'String', '', ...
        'FontSize', SYS_FONT_SIZE, ...
        'FontAngle', 'italic', ...
        'HorizontalAlignment', 'right', ...
        'ButtonDownFcn', @axis_time_callback);

    % Label Axes
    label_ax = axes('Parent', fig, ...
        'Units', 'pixels', ...
        'Color', panel_color, ...
        'XTick', [], ...
        'YTick', [], ...
        'Visible', 'off', ...
        'XLimMode', 'manual', ...
        'YLimMode', 'manual');
    
    % Session Map Axes    
    sess_map_ax = axes('Parent', fig, ...
        'Units', 'pixels', ...
        'TickLength',[0 0], ...
        'XTick', [], ...
        'YTick', [], ...
        'Box', 'on', ...
        'Color', 'white', ...
        'XLimMode', 'manual', ...
        'YLimMode', 'manual', ...
        'ButtonDownFcn', @sess_map_callback);
        
    % Logo Axes    
    logo_ax = axes('Parent', fig, ...
        'Units', 'pixels', ...
        'XLim', [1, 190], ...
        'XLim', [1, 72], ...
        'Color', panel_color, ...
        'XTick', [], ...
        'YTick', [], ...
        'visible', 'off', ...
        'XLimMode', 'manual', ...
        'YLimMode', 'manual'); 

    % Page Movement Buttons
    forward_button = uicontrol(fig, ...
        'Style', 'pushbutton', ...
        'Units', 'pixels', ...
        'String', '=>', ...
        'FontSize', SYS_FONT_SIZE + 4, ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'ButtonDownFcn', @page_movement_callback, ...
        'KeyPressFcn', @key_press_callback, ...
        'KeyReleaseFcn', @key_release_callback, ...
        'Callback', @page_movement_callback);

    back_button = uicontrol(fig, ...
        'Style', 'pushbutton', ...
        'Units', 'pixels', ...
        'String', '<=', ...
        'FontSize', SYS_FONT_SIZE + 4, ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'ButtonDownFcn', @page_movement_callback, ...
        'KeyPressFcn', @key_press_callback, ...
        'KeyReleaseFcn', @key_release_callback, ...
        'Callback', @page_movement_callback);

    % Antialias Button
    antialias_button = uicontrol(fig, ...
        'Style', 'pushbutton', ...
        'Units', 'pixels', ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'String', 'Antialiasing is On', ...
        'FontSize', SYS_FONT_SIZE, ...
        'Callback', @antialias_callback);
    
    % Autoscale Button
    autoscale_button = uicontrol(fig, ...
        'Style', 'pushbutton', ...
        'Units', 'pixels', ...
        'String', 'Autoscaling is On', ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'FontSize', SYS_FONT_SIZE, ...
        'Callback', @autoscale_callback);

    % Multicolor Button
    multicolor_button = uicontrol(fig, ...
        'Style', 'pushbutton', ...
        'Units', 'pixels', ...
        'String', 'In Multicolor Mode', ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'FontSize', SYS_FONT_SIZE, ...
        'Callback', @multicolor_callback);

    % Export Data button
    export_button = uicontrol(fig, ...
        'Style', 'pushbutton', ...
        'Units', 'pixels', ...
        'String', 'Export to Workspace', ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'FontSize', SYS_FONT_SIZE, ...
        'Callback', @export_callback);

    % Baseline Correction Button
    baseline_correct_button = uicontrol(fig, ...
        'Style', 'pushbutton', ...
        'Units', 'pixels', ...
        'String', 'Baseline Correction is On', ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'FontSize', SYS_FONT_SIZE, ...
        'Callback', @baseline_callback);

    % Gain Textbox & Label
    gain_textbox_label = uicontrol(fig, ...
        'Style', 'text', ...
        'Units', 'pixels', ...
        'String', '�V/cm:', ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'FontSize', SYS_FONT_SIZE, ...
        'HorizontalAlignment', 'right');
    
    gain_textbox = uicontrol(fig, ...
        'Style', 'edit', ...
        'Units', 'pixels', ...
        'String', '', ...
        'BackgroundColor', 'white', ...
        'FontSize', SYS_FONT_SIZE, ...
        'HorizontalAlignment', 'left', ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'KeyPressFcn', @key_press_callback, ...
        'Callback', @gain_callback);

    % Timebase Textbox & Label
    timebase_textbox_label = uicontrol(fig, ...
        'Style', 'text', ...
        'Units', 'pixels', ...
        'String', 's/page:', ...
        'FontSize', SYS_FONT_SIZE, ...
        'HorizontalAlignment', 'right');
    
    timebase_textbox = uicontrol(fig, ...
        'Style', 'edit', ...
        'Units', 'pixels', ...
        'String', '', ...
        'BackgroundColor', 'white', ...
        'FontSize', SYS_FONT_SIZE, ...
        'HorizontalAlignment', 'left', ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'KeyPressFcn', @key_press_callback, ...
        'Callback', @timebase_callback);

    % Current Time Textbox & Label
    current_time_textbox_label = uicontrol(fig, ...
        'Style', 'text', ...
        'Units', 'pixels', ...
        'String', 'page (s):', ...
        'FontSize', SYS_FONT_SIZE, ...
        'HorizontalAlignment', 'right');
    
    current_time_textbox = uicontrol(fig, ...
        'Style', 'edit', ...
        'Units', 'pixels', ...
        'String', '', ...
        'BackgroundColor', 'white', ...
        'FontSize', SYS_FONT_SIZE, ...
        'HorizontalAlignment', 'left', ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'KeyPressFcn', @key_press_callback, ...
        'Callback', @current_time_callback);

    % Amplitude Direction Button
    amplitude_direction_button = uicontrol(fig, ...
        'Style', 'pushbutton', ...
        'Units', 'pixels', ...
        'String', 'Negative is Up', ...
        'FontSize', SYS_FONT_SIZE, ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'Callback', @amplitude_direction_callback);
    
    % View Selected Button
    view_selected_button = uicontrol(fig, ...
        'Style', 'pushbutton', ...
        'Units', 'pixels', ...
        'String', 'View Selected', ...
        'FontSize', SYS_FONT_SIZE, ...
        'Enable', 'off', ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'Callback', @view_selected_callback);

    % Remove Selected Button
    remove_selected_button = uicontrol(fig, ...
        'Style', 'pushbutton', ...
        'Units', 'pixels', ...
        'String', 'Remove Selected', ...
        'FontSize', SYS_FONT_SIZE, ...
        'Enable', 'off', ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'Callback', @view_selected_callback);

    % Add Channels Button
    add_channels_button = uicontrol(fig, ...
        'Style', 'pushbutton', ...
        'Units', 'pixels', ...
        'String', 'Add Channels', ...
        'FontSize', SYS_FONT_SIZE, ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'Callback', @add_channels_callback);

    % Deselect All Button
    deselect_all_button = uicontrol(fig, ...
        'Style', 'pushbutton', ...
        'Units', 'pixels', ...
        'String', 'Deselect All', ...
        'FontSize', SYS_FONT_SIZE, ...
        'Visible', 'off', ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'Callback', @deselect_all_callback);

    % Records Checkbox
    records_checkbox = uicontrol(fig, ...
        'Style', 'checkbox', ...
        'String', 'Records', ...
        'Value', 0, ...
        'BackgroundColor', panel_color, ...
        'FontSize', SYS_FONT_SIZE, ...
        'FontName', 'FixedWidth', ...
        'HorizontalAlignment', 'left', ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'Callback', @records_callback);

    % Trace Ranges Checkbox
    ranges_checkbox = uicontrol(fig, ...
        'Style', 'checkbox', ...
        'String', 'Trace Ranges', ...
        'Value', 0, ...
        'BackgroundColor', panel_color, ...
        'FontSize', SYS_FONT_SIZE, ...
        'FontName', 'FixedWidth', ...
        'HorizontalAlignment', 'left', ...
        'Interruptible', 'off', ...
        'BusyAction', 'cancel', ...
        'Callback', @trace_ranges_callback);


    % ----------- Startup ----------------
    
    wind_usecs = DEFAULT_WINDOW_USECS;
    x_ax_inds = [];
    x_tick_inds = [];
    full_page_width = [];
    plot_handles = [];
    logo_handle = [];
    sess = [];
    password = DEFAULT_PASSWORD;
    chan_paths = {};
    chan_labels = {};
    label_ax_width = 0;
    raw_page = [];
    movement_direction = FORWARD;
    antialiased_channels = 0;
    raw_page = [];
    range_patches = [];
    discont_lines = [];
    record_lines = [];
    sess_map_records_lines = [];
    currently_plotting = false;
        
    % Parse inputs
    if (nargin >= 1)
        sess = varargin{1};
        if (nargin == 2)
            password = varargin{2};
        end
    end
    
    if (isempty(sess))
        filters = {'medd', 'ticd'};
        stop_filters = {'ticd'};
        [chan_list, sess_dir] = directory_chooser(filters, DEFAULT_DATA_DIRECTORY, stop_filters);
        if (isempty(chan_list))
            errordlg('No MED files selected', 'View MED');
            return;
        end
        n_chans = numel(chan_list);
        if (n_chans == 1)
            [~, ~, ext] = fileparts(chan_list(1));
            if (strcmp(ext, '.medd') == true)
                sess_dir = [sess_dir DIR_DELIM char(chan_list(1))];
                dir_list = dir([sess_dir DIR_DELIM '*.ticd']);
                if (isempty(dir_list))
                    errordlg('No MED files selected session', 'View MED');
                    return;
                end
                n_chans = numel(dir_list);
                chan_list = cell(n_chans, 1);
                for ii = 1:n_chans
                    [~, name, ~] = fileparts(dir_list(ii).name);
                    chan_list(ii) = cellstr([name '.ticd']);
                end
                clear dir_list;
            end
        end
        chan_paths = cell(n_chans, 1);
        for ii = 1:n_chans
            chan_paths{ii} = [sess_dir DIR_DELIM chan_list{ii}];
        end
        page_start = 0;
        page_end = -DEFAULT_WINDOW_USECS;  % set limits to default page width
    else  % get channels & page limits from passed session
        n_chans = numel(sess.channels);
        chan_paths = cell(n_chans, 1);
        chan_list = cell(n_chans, 1);
        for ii = 1:n_chans
            chan_paths{ii} = sess.channels(ii).metadata.path;
            chan_list{ii} = sess.channels(ii).metadata.channel_name;
        end
        page_start = sess.metadata.start_time;
        page_end = sess.metadata.end_time;
        wind_usecs = (page_end - page_start) + 1;
        clear sess;
    end

    % Set up wait pointer timer
    WAIT_POINTER_DELAY = 0.667;  % seconds
    OS_RECOVERY_DELAY_PROPORTION = 0.05;  % pause for this proportion of read time after read to allow OS to clean up
    MIN_OS_RECOVERY_DELAY = 0.01;
    OS_recovery_secs = MIN_OS_RECOVERY_DELAY;
    new_page_secs = 0;
    new_page_timer = [];
    potentially_increased_plot_time = false;

    set(fig, 'Pointer', 'watch');
    reset_pointer = true;
    drawnow;
    
    % load session
    [sess, sess_record_times, tmp_disconts] = load_session(chan_paths, password);
    pause(OS_recovery_secs);
    clear load_session;
    if (isempty(sess))
        errordlg('read_MED() error', 'View MED');
        return;
    end

    % get channels & page limits from loaded session (order and limits can differ from request)
    n_chans = numel(sess.channels);
    chan_paths = cell(n_chans, 1);
    chan_list = cell(n_chans, 1);
    for ii = 1:n_chans
        chan_paths{ii} = sess.channels(ii).metadata.path;
        chan_list{ii} = sess.channels(ii).metadata.channel_name;
    end
    page_start = sess.metadata.start_time;
    page_end = (page_start + wind_usecs) - 1;

    sess_dir = sess.metadata.path;
    recording_time_offset = sess.metadata.recording_time_offset;
    sess_start = sess.metadata.session_start_time;
    sess_end = sess.metadata.session_end_time;
    sess_duration = double(sess_end - sess_start);
    curr_usec = double(page_start - sess_start);
    set(current_time_textbox, 'String', num2str(double(curr_usec) / 1e6, '%0.6f'));
    set(timebase_textbox, 'String', num2str(wind_usecs / 1e6, '%0.6f'));
    set(fig, 'Name', ['View MED: ' sess.metadata.session_name]);
    clear sess;
    
    NEGATIVE_UP = 1;  % data y axis is inverted
    NEGATIVE_DOWN = -1;
    amplitude_direction = NEGATIVE_UP;
    baseline_correct_flag = true;
    multicolor_flag = true;
    antialias_flag = true;
    autoscale_flag = true;
    ranges_flag = false;
    records_flag = false;
    calendar_time_flag = true;
    uUTC_flag = false;
    oUTC_flag = false;
    screen_sf = [];
    shift_pressed = false;
  
    n_discontigua = numel(tmp_disconts);
    if (n_discontigua)
        discontigua = cell(n_discontigua, 1);
        for ii = 1:n_discontigua
            discontigua{ii}.start_time = double(tmp_disconts(ii).start_time);
            discontigua{ii}.end_time = double(tmp_disconts(ii).end_time);
            discontigua{ii}.start_prop = double(tmp_disconts(ii).start_proportion);
            discontigua{ii}.end_prop = double(tmp_disconts(ii).end_proportion);
            % Z coordinate 1's hold patch in "front"
            discontigua{ii}.patch = patch(sess_map_ax, ...
                [1, 1, 1, 1], [0, sess_map_ax_height, sess_map_ax_height, 0], [1, 1, 1, 1], ...
                DARK_GRAY, 'EdgeColor', 'none', 'ButtonDownFcn', @sess_map_callback);
        end
    end
    clear tmp_disconts;

    % Z coordinate 0's hold patch in "back" (behind contigua patches)
    curr_page_patch = patch(sess_map_ax, ...
        [1, 1, 1, 1], [0, sess_map_ax_height, sess_map_ax_height, 0], [0, 0, 0, 0], ...
        'red', 'EdgeColor', 'none', ...
        'ButtonDownFcn', @sess_map_callback);

    % Make channel labels
    selected_labels = [];
    create_labels();
   
    % Draw window
    currently_resizing = false;
    set(fig, 'Visible', 'on');  % calls resize()
    uicontrol(forward_button);


    % ------------ Support Functions ---------------

    function plot_page(get_new_data)

        if (currently_plotting == true)
            set(fig, 'Pointer', 'watch'); 
            reset_pointer = true;
            return;
        end
        currently_plotting = true;

        % start new page timer
        new_page_timer = tic;
        if (new_page_secs > WAIT_POINTER_DELAY || potentially_increased_plot_time == true)
            potentially_increased_plot_time = false;
            set(fig, 'Pointer', 'watch'); 
            drawnow;
            reset_pointer = true;
        end

        % raw_page, mins, maxs have decimation, detrending, & filtering (no offsetting, scaling, or inversion)
        if (get_new_data == true)

            % get new data
            set_page_limits();
            screen_sf = (full_page_width * double(1e6)) / double(wind_usecs);
            page_load_timer = tic;
            raw_page = matrix_MED_exec(chan_paths, page_start, page_end, full_page_width, password, antialias_flag, baseline_correct_flag, ranges_flag);
            page_load_secs = toc(page_load_timer);
            OS_recovery_secs = OS_RECOVERY_DELAY_PROPORTION * page_load_secs;
            if (OS_recovery_secs < MIN_OS_RECOVERY_DELAY)
                OS_recovery_secs = MIN_OS_RECOVERY_DELAY;
            end
            pause(OS_recovery_secs);
            clear matrix_MED_exec;

            if (isempty(raw_page))
                errordlg('Error reading data', 'View MED');
                return;
            end

            % get returned page times (may differ from requested)
            page_start = raw_page.start_time;
            page_end = raw_page.end_time;

            % set time strings
            curr_usec = double(page_start - sess_start);
            set(current_time_textbox, 'String', num2str(double(curr_usec) / 1e6, '%0.6f'));
            if calendar_time_flag == true
                set(axis_start_time_string, 'String', raw_page.start_time_string);
                set(axis_end_time_string, 'String', raw_page.end_time_string);
            elseif uUTC_flag == true
                set(axis_start_time_string, 'String', ['start �UTC: ' num2str(page_start + recording_time_offset)]);
                set(axis_end_time_string, 'String', ['end �UTC: ' num2str(page_end + recording_time_offset)]);
            elseif oUTC_flag == true
                set(axis_start_time_string, 'String', ['start oUTC: ' num2str(page_start)]);
                set(axis_end_time_string, 'String', ['end oUTC: ' num2str(page_end)]);
            end
            
            % see if any channels were antialiased
            antialiased_channels = false;
            if (antialias_flag == true)
                for i = 1:n_chans
                    sf = raw_page.sampling_frequencies(i);
                    if (screen_sf < sf)
                        antialiased_channels = true;
                        break;
                    end
                end
            end
            if (antialiased_channels == true)
                    set(antialias_button, 'String', ['Antialiasing at ' num2str(screen_sf / 4, '%0.0f') ' Hz']);
            else
                    set(antialias_button, 'String', 'Antialiasing is Off');            
            end

        end  % end get_new_data
  
        % page, mins, maxs have scaling, inversion, & offsetting (use copy)
        page = raw_page.samples;
        if (ranges_flag == true)
            mins = raw_page.minima;
            maxs = raw_page.maxima;
        end       

        % subtract trace means to keep highly offset traces on screen
        if (baseline_correct_flag == false)
            for i = 1:n_chans
                tr_mn = mean(page(:, i));
                page(:, i) = page(:, i) - tr_mn;
                if (ranges_flag == true)
                    mins(:, i) = mins(:, i) - tr_mn;
                    maxs(:, i) = maxs(:, i) - tr_mn;
                end
            end
        end

        % scale (+/- invert)
        pix_per_trace = data_ax_height / (n_chans + 1);
        if (autoscale_flag == true)
             % Matlab quantile() requires Statistics and Machine Learning Toolbox
            if (ranges_flag == false)
                q = local_quantile(page, [0.01, 0.99]);
            else
                q(1) = local_quantile(mins, 0.01);
                q(2) = local_quantile(maxs, 0.99);
            end
            magnitude = q(2) - q(1);
            if (magnitude < 1)
                magnitude = 1;
            end
            scale = (pix_per_trace / magnitude);
        else
            scale = abs(scale);
        end   
        uV_per_cm = pix_per_cm / scale;
        set(gain_textbox, 'String', num2str(uV_per_cm, '%0.0f'));
        scale = scale * amplitude_direction;
        page = page * scale;
        if (ranges_flag == true)
            mins = mins * scale;
            maxs = maxs * scale;
        end

        % offset traces (in plot window)
        pix_per_trace = (data_ax_height - 4) / n_chans;
        offset = (pix_per_trace / 2) + 2;
        for i = 1:n_chans
            r_offset = round(offset);
            page(:, i) = page(:, i) + r_offset;
            if (ranges_flag == true)
                mins(:, i) = mins(:, i) + r_offset;
                maxs(:, i) = maxs(:, i) + r_offset;
            end
            offset = offset + pix_per_trace;
        end

        % plot
        if (isempty(plot_handles))
            cla(data_ax);
            offset = (pix_per_trace / 2) + 2;
            y_tick_inds = zeros(n_chans, 1);
            for i = 1:n_chans
                y_tick_inds(i) = round(offset);
                offset = offset + pix_per_trace;
            end
            hold(data_ax, 'on');
            set(data_ax, 'Xlim', [1, data_ax_width], 'Ylim', [1, data_ax_height], 'XTickLabels', [], 'YTickLabels', [], 'XTick', x_tick_inds, 'YTick', y_tick_inds);
            if (multicolor_flag == true)
                plot_handles = plot(data_ax, x_ax_inds, page);
            else
                plot_handles = plot(data_ax, x_ax_inds, page, 'Color', mono_color);
            end
            line(data_ax, [1, data_ax_width, data_ax_width, 1, 1], [1, 1, data_ax_height, data_ax_height, 1], 'Color', 'k');
            hold(data_ax, 'off');
        else
            for i = 1:n_chans
                set(plot_handles(i), 'YData', page(:, i));
            end
        end
        
        % clear old trace range patches
        if (~isempty(range_patches))
            for i = 1:numel(range_patches)
                delete(range_patches{i});
            end
            range_patches = [];
        end

        % draw trace range patches
        if (ranges_flag == true)
            range_patches = cell(n_chans, 1);
            for i = 1:n_chans
                    patch_x = [(x_ax_inds(1):x_ax_inds(end))' ; (x_ax_inds(end):-1:x_ax_inds(1))'];
                    patch_y = [mins(:, i) ; flipud(maxs(:, i))];
                    patch_z = ones((2 * full_page_width), 1) * -1;
                    range_patches{i} = patch(data_ax, patch_x, patch_y, patch_z, LIGHT_GRAY, 'EdgeColor', 'none');
            end
        end

        % clear old discontinuity lines
        if (~isempty(discont_lines))
            for i = 1:numel(discont_lines)
                delete(discont_lines{i}.line);
                delete(discont_lines{i}.zag);
            end
            discont_lines = [];
        end

        % draw discontinuity lines
        n_contigua = numel(raw_page.contigua);
        if (n_contigua > 1)
            discont_lines = cell(n_contigua - 1, 1);
            for i = 2:n_contigua
                sess_map_x = double(raw_page.contigua(i).start_index) + (x_ax_inds(1) - 1);
                discont_lines{i - 1}.line = line(data_ax, [sess_map_x, sess_map_x], [20 data_ax_height], 'color', VERY_DARK_GRAY, 'LineWidth', 2, 'LineStyle', '--');
                patch_x = [-1, 11, 2, 7, -3, 2, -6, -1] + sess_map_x;
                patch_y = [1, 1, 5, 10, 15, 10, 5, 1];
                discont_lines{i - 1}.zag = patch(data_ax, patch_x, patch_y, VERY_DARK_GRAY, 'EdgeColor', 'none', 'ButtonDownFcn', @discont_line_callback);
            end
        end

        % clear old record lines
        if (~isempty(record_lines))
            for i = 1:numel(record_lines)
                delete(record_lines{i}.line);
                delete(record_lines{i}.flag);
            end
            record_lines = [];
        end

        % draw record lines
        if (records_flag == true)
            record_lines = cell(numel(raw_page.records), 1);
            for i = 1:numel(record_lines)
                sess_map_x = double(raw_page.records{i}.start_index) + (x_ax_inds(1) - 1);
                record_lines{i}.line = line(data_ax, [sess_map_x, sess_map_x], [20 data_ax_height], 'color', DARK_GREEN, 'LineWidth', 2, 'LineStyle', '--');
                patch_x = [-1, 19, 14, 19, -1, -1] + sess_map_x;
                patch_y = [1, 1, 7, 14, 14, 1];
                record_lines{i}.flag = patch(data_ax, patch_x, patch_y, DARK_GREEN, 'EdgeColor', 'none', 'ButtonDownFcn', @rec_line_callback);
            end
        end

        % update current page patch on session map
        window_offset = double(page_start - sess_start);
        sess_map_start_x = round(data_ax_width * (window_offset / sess_duration));
        window_offset = double(page_end - sess_start);
        sess_map_end_x = round(data_ax_width * (window_offset / sess_duration));
        if (sess_map_end_x == sess_map_start_x)
            sess_map_end_x = sess_map_start_x + 1;
        end   
        set(curr_page_patch, 'XData', [sess_map_start_x, sess_map_start_x, sess_map_end_x, sess_map_end_x]);

        % stop new page timer
        if (reset_pointer == true)
            set(fig, 'Pointer', 'arrow');
            drawnow;
            reset_pointer = false;
        end
        new_page_secs = toc(new_page_timer);
        currently_plotting = false;

    end  % end plot_page()

    function set_page_limits()
        if ((page_start + wind_usecs) >= sess_end)
            page_start = sess_end - wind_usecs;
            movement_direction = BACKWARD;
        elseif (page_start < sess_start)
            page_start = sess_start;
            movement_direction = FORWARD;
        end

        if (n_discontigua == 0)
            page_end = page_start + wind_usecs;
            return;
        end

        % is page_start in a discontiguous region?
        discont_num = 0;
        for i = 1:n_discontigua
            if (page_start >= discontigua{i}.start_time)
                if (page_start <= discontigua{i}.end_time)      
                    discont_num = i;
                    break;
                end
            else
                break;          
            end
        end

        % page_start is in a discontiguous region
        if (discont_num)
            if (movement_direction == FORWARD)
                page_start = discontigua{discont_num}.end_time + 1;
            else  % movement_direction == BACKWARD
                discont_usecs = discontigua{discont_num}.end_time - page_start;
                if (discont_usecs > wind_usecs)
                    discont_usecs = wind_usecs;
                end
                page_start = discontigua{discont_num}.start_time - discont_usecs;                
            end
            if ((page_start + wind_usecs) >= sess_end)
                page_start = sess_end - wind_usecs;
                movement_direction = BACKWARD;
                set_page_limits();  % recursion
            elseif (page_start < sess_start)
                page_start = sess_start;
                movement_direction = FORWARD;
                set_page_limits();  % recursion
            end
        end

        page_end = page_start + wind_usecs;
    end

    function create_labels()
        cla(label_ax);
        chan_labels = cell(n_chans, 1);
        for i = 1:n_chans   
            chan_labels{i} = text(label_ax, ...
            'Units', 'pixels', ...
            'String', chan_list{i}, ...
            'FontSize', SYS_FONT_SIZE, ...
            'Color', colors((mod((i - 1), n_colors) + 1), :), ...
            'HorizontalAlignment', 'right', ...
            'Interpreter', 'none', ...
            'ButtonDownFcn', @label_select_callback);
        end
        selected_labels = zeros(n_chans, 1);
    end

    function draw_labels()
        chan_dy = (data_ax_height - 4) / n_chans;
        chan_y = data_ax_height - (chan_dy / 2);        
        label_font_size = points_per_pix * chan_dy;
        if (label_font_size > SYS_FONT_SIZE)
            label_font_size = SYS_FONT_SIZE;
        end
        for i = 1:n_chans
            set(chan_labels{i}, 'Position', [label_ax_width, round(chan_y)], 'FontSize', label_font_size);
            chan_y = chan_y - chan_dy;
            c = colors((mod((i - 1), n_colors) + 1), :);
            if (selected_labels(i) == 1)
                set(chan_labels{i}, 'BackgroundColor', panel_color * 0.95);
                if (multicolor_flag == true)
                    set(chan_labels{i}, 'Color', c);
                else
                    set(chan_labels{i}, 'Color', 'red');
                end
            else
                if (multicolor_flag == true)
                    set(chan_labels{i}, 'Color', c);
                else
                    set(chan_labels{i}, 'Color', 'black');
                end                
            end
        end
    end

    function set_movement_focus()
        ax_mouse_down = false;
        if (movement_direction == FORWARD)
            uicontrol(forward_button);
        else  % movement_direction == BACKWARD
            uicontrol(back_button);
        end       
    end

    function plot_sess_record_times()

        ax_locs = round(sess_record_times * sess_map_ax_width);
        ax_locs = unique(ax_locs);  % potentially a lot of overlap
        n_lines = numel(ax_locs);
        delete(sess_map_records_lines);
        sess_map_records_lines = gobjects(n_lines, 1);
        for i = 1:n_lines
            x = ax_locs(i);
            sess_map_records_lines(i) = line(sess_map_ax, [x x], [0 sess_map_ax_height], [-1 -1], 'Color', DARK_GREEN, 'ButtonDownFcn', @sess_map_callback);  % Z coords put display below page patch
        end
        clear ax_locs;
    end

    function q = local_quantile(page, q_points)
        tot_samps = numel(page);
        sorted_page = sort(reshape(page, [tot_samps, 1]));
        q = zeros(size(q_points));
        for i = 1:numel(q_points)
            float_idx = q_points(i) * tot_samps;
            floor_idx = floor(float_idx);
            ceil_idx = floor_idx + 1;
            val = (ceil_idx - float_idx) * sorted_page(floor_idx);
            q(i) = val + ((float_idx - floor_idx) * sorted_page(ceil_idx));
        end
        clear sorted_page;
    end

% ------------ Callback Functions ---------------

	% Figure resize function
    function resize(~, ~)
  
        % Reject all concommitant resize calls
        if (currently_resizing == true)
            return;
        end        
        currently_resizing = true;

        % Wait for user to stop resizing
        last_f_pos = get(fig, 'Position');
        while (true)
            pause(0.2);
            f_pos = get(fig, 'Position');
            if (f_pos(3) == last_f_pos(3) && f_pos(4) == last_f_pos(4))
                break;
            end
            last_f_pos = f_pos;
        end

        % Figure dimensions
        fig_left = 1;
        fig_right = round(f_pos(3));
        fig_bot = 1;
        fig_top = round(f_pos(4));

        min_size_flag = false;
        if (fig_right < 950)
            fig_right = 950;
            min_size_flag = true;
        end
        if (fig_top < 650)
            fig_top = 650;
            min_size_flag = true;
        end

        % check that window is entirely on screen
        if ((f_pos(1) + fig_right) > screen_x_pix)
            f_pos(1) = (screen_x_pix - fig_right) - 1;
            min_size_flag = true;
        end
        if ((f_pos(2) + fig_top) > screen_y_pix)   
            if (strcmp(OS, 'PCWIN64'))  % Windows window banner not counted in fig size
                f_pos(2) = (screen_y_pix - fig_top) - 26;
            else
                f_pos(2) = (screen_y_pix - fig_top) - 1;
            end
            min_size_flag = true;
        end
        if (min_size_flag)
            set(fig, 'Position', [f_pos(1), f_pos(2), fig_right, fig_top]);
        end

        % Data axes dimensions
        data_ax_left = fig_left + 160;
        data_ax_right = fig_right - 30;
        data_ax_width = (data_ax_right - data_ax_left) + 1;
        x_ax_inds = (1:data_ax_width)';
        x_tick_inds = linspace(1, data_ax_width, 11);
        full_page_width = data_ax_width;
        data_ax_bot = fig_bot + 165;
        data_ax_top = fig_top - 50;
        data_ax_height = (data_ax_top - data_ax_bot) + 1;

        set(data_ax, 'Position', [data_ax_left, data_ax_bot, data_ax_width, data_ax_height]);
        set(data_ax, 'XLim', [0, data_ax_width - 1], 'YLim', [0, data_ax_height - 1]);
        
        % Label axes dimensions
        label_ax_left = 30;
        label_ax_right = 150;
        label_ax_width = label_ax_right - label_ax_left;
        label_ax_bot = data_ax_bot;

        set(label_ax, 'Position', [label_ax_left, label_ax_bot, label_ax_width, data_ax_height]);
        set(label_ax, 'XLim', [1, label_ax_width], 'YLim', [1, data_ax_height]);
        
        % Session map axes dimensions
        sess_map_ax_left = data_ax_left;
        sess_map_ax_width = data_ax_width;
        sess_map_ax_bot = data_ax_bot - 45;
        % sess_map_ax_top = sess_map_ax_bot + 10;

        set(sess_map_ax, 'Position', [sess_map_ax_left, sess_map_ax_bot, sess_map_ax_width, sess_map_ax_height], ...
            'XLim', [0, sess_map_ax_width + 1], 'YLim', [0, sess_map_ax_height + 1]);

        % Time string axes dimensions
        time_str_ax_left = data_ax_left;
        time_str_ax_width = data_ax_width;
        time_str_ax_bot = data_ax_top + 9;
        time_str_ax_top = time_str_ax_bot + 10;
        time_str_ax_height = (time_str_ax_top - time_str_ax_bot) + 1;

        set(time_str_ax, 'Position', [time_str_ax_left, time_str_ax_bot, time_str_ax_width, time_str_ax_height], ...
            'XLim', [0, time_str_ax_width + 1], 'YLim', [0, time_str_ax_height]);
        set(axis_start_time_string, 'Position', [1, 1]);
        set(axis_end_time_string, 'Position', [time_str_ax_width, 1]);
        
        % Logo axes dimensions
        logo_ax_left = 20;
        logo_ax_right = logo_ax_left + 117;
        logo_ax_width = (logo_ax_right - logo_ax_left) + 1;
        logo_ax_bot = fig_bot + 25;
        logo_ax_top = logo_ax_bot + 44;
        logo_ax_height = (logo_ax_top - logo_ax_bot) + 1;
        set(logo_ax, 'Position', [logo_ax_left, logo_ax_bot, logo_ax_width, logo_ax_height]);
        set(logo_ax, 'XLim', [1, logo_ax_width], 'YLim', [1, logo_ax_height]);
        delete(logo_handle);
        logo_handle = imshow(logo, 'Parent', logo_ax);
        set(logo_handle, 'ButtonDownFcn', @logo_callback);

        button_group_right = data_ax_left + 363;
        label_group_left = data_ax_right - 155;
        mid_center_space = round((button_group_right + label_group_left) / 2);

        % Controls time_str_ax
        set(view_selected_button, 'Position', [data_ax_left - 3, 75, 130, 30]);
        set(remove_selected_button, 'Position', [data_ax_left - 3, 50, 130, 30]);
        set(add_channels_button, 'Position', [data_ax_left - 3, 25, 130, 30]);
        
        set(amplitude_direction_button, 'Position', [(data_ax_left + 125), 75, 130, 30]);
        set(baseline_correct_button, 'Position', [(data_ax_left + 125), 50, 130, 30]);
        set(antialias_button, 'Position', [(data_ax_left + 125), 25, 130, 30]);

        set(autoscale_button, 'Position', [(data_ax_left + 253), 75, 130, 30]);
        set(multicolor_button, 'Position', [(data_ax_left + 253), 50, 130, 30]);
        set(export_button, 'Position', [(data_ax_left + 253), 25, 130, 30]);    

        set(back_button, 'Position', [(mid_center_space - 75), 35, 80, 50]);
        set(forward_button, 'Position', [(mid_center_space + 15), 35, 80, 50]);
        
        set(gain_textbox, 'Position', [(data_ax_right - 100), 25, 100, 20]);
        set(gain_textbox_label, 'Position', [(data_ax_right - 155), 25, 50, 20]);
        set(timebase_textbox, 'Position', [(data_ax_right - 100), 50, 100, 20]);
        set(timebase_textbox_label, 'Position', [(data_ax_right - 155), 50, 50, 20]);
        set(current_time_textbox, 'Position', [(data_ax_right - 100), 75, 100, 20]);
        set(current_time_textbox_label, 'Position', [(data_ax_right - 155), 75, 50, 20]);
        
        set(deselect_all_button, 'Position', [30, (data_ax_bot - 25), 117, 20]);
        set(records_checkbox, 'Position', [30, (data_ax_bot - 50), 117, 20]);
        set(ranges_checkbox, 'Position', [30, (data_ax_bot - 70), 117, 20]);

        % draw discontigua
        if (n_discontigua)
            for i = 1:n_discontigua
                sess_map_start_x = round(data_ax_width * discontigua{i}.start_prop);
                sess_map_end_x = round(data_ax_width * discontigua{i}.end_prop);
                if (sess_map_end_x == sess_map_start_x)
                    sess_map_end_x = sess_map_start_x + 1;
                end
                set(discontigua{i}.patch, 'XData', [sess_map_start_x, sess_map_start_x, sess_map_end_x, sess_map_end_x]);
            end
        end

        % draw session map record lines
        if (records_flag == true)
            plot_sess_record_times();
        end

        % plot
        while (currently_plotting == true)
            pause(0.05);
        end
        draw_labels();
        plot_handles = [];
        potentially_increased_plot_time = true;
        plot_page(true);
        currently_resizing = false;
    end

    % Key Press Callback
    function key_press_callback(src, evt)
        key = lower(char(evt.Key));
        switch key
            case 'rightarrow'
                page_movement_callback(src, evt);
            case 'leftarrow'
                page_movement_callback(src, evt);
            case 'shift'
                shift_pressed = true;
            case {'uparrow', 'downarrow'}
                switch src
                    case {fig, gain_textbox, forward_button, back_button}
                        uicontrol(gain_textbox);
                        gain_callback(gain_textbox, evt);
                    case timebase_textbox
                        uicontrol(timebase_textbox);
                        timebase_callback(timebase_textbox, evt);
                    case current_time_textbox
                        switch key
                            case 'uparrow'
                                page_movement_callback(forward_button, evt);
                            case 'downarrow'
                                page_movement_callback(back_button, evt);
                        end
                end
        end 
    end

    % Key Release Callback
    function key_release_callback(~, evt)
        key = lower(char(evt.Key));
        switch key
            case 'shift'
                    shift_pressed = false;
        end
    end

    % Page Movement Callback
    function page_movement_callback(src, evt)

        left_click = 0;
        right_click = 0;
        modifier = '';
        key = '';
        switch class(evt)
            case 'matlab.ui.eventdata.MouseData'
                right_click = 1;
            case 'matlab.ui.eventdata.ActionData'
                left_click = 1;
            case 'matlab.ui.eventdata.UIClientComponentKeyEvent'
                modifier = lower(char(evt.Modifier));
                key = lower(char(evt.Key));
                switch key
                    case 'uparrow'
                        key = 'rightarrow';
                    case 'downarrow'
                        key = 'leftarrow';
                end
        end
        
        if (right_click || left_click)
            if right_click
                modifier = 'command';
            else
                modifier = 'no modifier';
            end
            switch src
                case forward_button
                    key = 'rightarrow';
                case back_button
                    key = 'leftarrow';
            end
        end
        
        switch modifier
            case 'command'
                page_shift = round(wind_usecs / 3);
            case 'alt'
                page_shift = round(wind_usecs / 10);
            otherwise
                page_shift = wind_usecs;
        end

        switch key
            case 'rightarrow'
                if (page_shift == wind_usecs)
                    page_start = page_end + 1;
                else
                    page_start = page_start + page_shift;
                end
                movement_direction = FORWARD;
            case 'leftarrow'
                page_start = page_start - page_shift;
                movement_direction = BACKWARD;
        end

        plot_page(true);
        set_movement_focus();        
    end

    % Timebase Callback
    function timebase_callback(~, evt)
        
        key = '';
        modifier = '';
        temp_wind_usecs = str2double(get(timebase_textbox, 'String')) * 1e6;
        switch class(evt)
            case 'matlab.ui.eventdata.KeyData'   % unmodified arrow
                key = lower(char(evt.Key));
            case 'matlab.ui.eventdata.UIClientComponentKeyEvent'   % modified arrow
                key = lower(char(evt.Key));
                modifier = lower(char(evt.Modifier));
        end   
        switch modifier
            case 'command'
                multiplier = 2;
            case 'alt'
                multiplier = 1.1;
            otherwise
                multiplier = 1.4142;
        end    
        switch key
            case 'uparrow'
                temp_wind_usecs = temp_wind_usecs * multiplier;
            case 'downarrow'
                temp_wind_usecs = temp_wind_usecs / multiplier;
            otherwise
                key = 'enter';
        end

        if (temp_wind_usecs > 0)
            if (temp_wind_usecs > wind_usecs)
                potentially_increased_plot_time = true;
            end
            wind_usecs = temp_wind_usecs;
        else
            return;
        end
        set(timebase_textbox, 'String', num2str(wind_usecs / 1e6, '%0.6f'));

        page_end = (page_start + wind_usecs) - 1;
                
        plot_page(true);

        % return focus to timebase box if user used up/down arrows
        if (strcmp(key, 'enter') == true)
            set_movement_focus();
        else
            uicontrol(timebase_textbox);
        end
    end

	% Gain Callback
    function gain_callback(~, evt)
        
        key = '';
        modifier = '';
        switch class(evt)
            case 'matlab.ui.eventdata.KeyData'   % unmodified arrow
                key = lower(char(evt.Key));
            case 'matlab.ui.eventdata.UIClientComponentKeyEvent'   % modified arrow
                key = lower(char(evt.Key));
                modifier = lower(char(evt.Modifier));
            case 'matlab.ui.eventdata.ActionData'   % textbox entry
                uV_per_cm = str2double(get(gain_textbox, 'String'));
                scale = pix_per_cm / uV_per_cm;
        end        
        switch modifier
            case 'command'
                multiplier = 2;
            case 'alt'
                multiplier = 1.1;
            otherwise
                multiplier = 1.4142;
        end 
        switch key
            case 'uparrow'
                scale = scale * multiplier;
            case 'downarrow'
                scale = scale / multiplier;
            otherwise
                key = 'enter';
        end
       
        if (autoscale_flag == true)
            set(autoscale_button, 'String', 'Autoscaling is Off');
        end
        autoscale_flag = false;
        plot_page(false);

        % return focus to gain box if user used up/down arrows
        if (strcmp(key, 'enter') == true)
            set_movement_focus();
        else
            uicontrol(gain_textbox);
        end
    end

	% Multicolor Callback
    function multicolor_callback(src, ~)
        if (multicolor_flag == true)
            set(src, 'String', 'In Monochrome Mode');
            multicolor_flag = false;
        else
            set(src, 'String', 'In Multicolor Mode');
            multicolor_flag = true;
        end
        
        for i = 1:n_chans            
            if (multicolor_flag == true)
                c = colors((mod((i - 1), n_colors) + 1), :);
                set(chan_labels{i}, 'Color', c);
                set(plot_handles(i), 'Color', c);
            else
                if (selected_labels(i) == 1)
                    set(chan_labels{i}, 'Color', 'red');
                else
                    set(chan_labels{i}, 'Color', 'black');
                end
                set(plot_handles(i), 'Color', mono_color);
            end
        end

        set_movement_focus();
    end

	% Antialias Callback
    function antialias_callback(~, ~)
        % set button text in plot_page() in case no traces need antialisiang
        if (antialias_flag == true)
            antialias_flag = false;
        else
            antialias_flag = true;
            potentially_increased_plot_time = true;
        end

        plot_page(true);
        set_movement_focus();
    end

	% Baseline Callback
    function baseline_callback(src, ~)
        if (baseline_correct_flag == true)
            set(src, 'String', 'Baseline Correction is Off');
            baseline_correct_flag = false;
        else
            set(src, 'String', 'Baseline Correction is On');
            potentially_increased_plot_time = true;
            baseline_correct_flag = true;
        end

        plot_page(true);
        set_movement_focus();
    end

	% Amplitude Direction Callback
    function amplitude_direction_callback(~, ~)
        if (amplitude_direction == NEGATIVE_DOWN)
            set(amplitude_direction_button, 'String', 'Negative is Up');
            amplitude_direction = NEGATIVE_UP;
        else
            set(amplitude_direction_button, 'String', 'Negative is Down');
            amplitude_direction = NEGATIVE_DOWN;
        end

        plot_page(false);
        set_movement_focus();
    end

	% Autoscale Callback
    function autoscale_callback(~, ~)
        if (autoscale_flag == true)
            set(autoscale_button, 'String', 'Autoscaling is Off');
            autoscale_flag = false;
        else
            set(autoscale_button, 'String', 'Autoscaling is On');
            autoscale_flag = true;
            potentially_increased_plot_time = true;
        end

        plot_page(false);
        set_movement_focus();
    end

	% Current Time Callback
    function current_time_callback(~, ~)      
        curr_usec = round(str2double(get(current_time_textbox, 'String')) * 1e6);
        if curr_usec < 0
            curr_usec = 0;
        end       
        page_start = sess_start + curr_usec;  
        plot_page(true);
        set_movement_focus();
    end

	% Label Select Callback
    function label_select_callback(src, ~)

        for i = 1:n_chans
            if (strcmp(chan_list{i}, src.String) == true)
                break;
            end
        end
        selected = i;

        if (label_font_size < SYS_FONT_SIZE)
            pos = get(chan_labels{selected}, 'Position');
            if (selected_labels(selected))
                set(chan_labels{selected}, 'Position', [label_ax_width, pos(2)], 'HorizontalAlignment', 'right', 'FontSize', label_font_size);
            else
                set(chan_labels{selected}, 'Position', [0, pos(2)], 'HorizontalAlignment', 'left', 'FontSize', SYS_FONT_SIZE);
            end
        end

        prev_selected = selected;        
        if (shift_pressed == true)
            % find next selected higher in list
            for i = (selected - 1):-1:1
                if selected_labels(i)
                    prev_selected = i;
                    break;
                end
            end
            if (prev_selected == selected)
                % find next selected lower in list
                for i = (selected + 1):n_chans
                    if selected_labels(i)
                        prev_selected = selected;
                        selected = i;
                        break;
                    end
                end
            end
            if (prev_selected ~= selected)
                selected_labels(prev_selected:selected) = 1;
            end 
        else
            selected_labels(selected) = ~selected_labels(selected);
        end
        
        for i = prev_selected:selected
            if selected_labels(i)
                set(chan_labels{i}, 'FontAngle', 'italic', 'BackgroundColor', panel_color * 0.925);
                if (multicolor_flag == false)
                    set(chan_labels{i}, 'Color', 'red');
                end
            else
                set(chan_labels{i}, 'FontAngle', 'normal', 'BackgroundColor', panel_color);
                if (multicolor_flag == false)
                    set(chan_labels{i}, 'Color', 'black');
                end
            end
        end
        if (sum(selected_labels))
            set(view_selected_button, 'Enable', 'on');
            set(remove_selected_button, 'Enable', 'on');
            set(deselect_all_button, 'Visible', 'on');
        else
            set(deselect_all_button, 'Visible', 'off');
            set(view_selected_button, 'Enable', 'off');
            set(remove_selected_button, 'Enable', 'off');
            selected_labels = [];
            create_labels();
            draw_labels();
        end

        shift_pressed = false;
        set_movement_focus();
    end

    % View Selected Callback
    function view_selected_callback(src, ~)
        if src == view_selected_button
            val = 1;
        else % src == remove_selected_button
            val = 0;
        end
        

        % Get selected / unselected channels
        j = 0;
        for i = 1:n_chans
            if selected_labels(i) == val
                j = j + 1;
                chan_paths{j} = chan_paths{i};
                chan_list{j} = chan_list{i};
            end
        end
        
        % view all
        if (j == n_chans)
            return;
        % remove all
        elseif (j == 0 && val == 0)
            errordlg('At least one channel must be selected', 'View MED');
            chan_paths = [];
            chan_list = [];
            n_chans = 0;
            add_channels_callback();
            return;
        end

        n_chans = j;
        chan_paths = chan_paths(1:n_chans);
        chan_list = chan_list(1:n_chans);

        plot_handles = [];
        if (autoscale_flag == false)  % rescale plots for new trace set
            set(autoscale_button, 'String', 'Autoscaling is On');
            autoscale_flag = true;
        end
        plot_page(true);

        % Make channel labels
        set(deselect_all_button, 'Visible', 'off');
        selected_labels = [];
        create_labels();
        draw_labels();

        set_movement_focus();
    end

    % Add Channels Callback
    function add_channels_callback(~, ~)
        filters = {'ticd'};
        stop_filters = {'ticd'};
        [new_chan_list, new_sess_dir] = directory_chooser(filters, sess_dir, stop_filters);
        if (isempty(new_chan_list))
            if (n_chans == 0)
                errordlg('No channels selected for display. Exiting.', 'View MED');
                figure_close_callback();
                return;
            else
                errordlg('No MED files selected', 'View MED');
                return;
            end
        end
        if (strcmp(sess_dir, new_sess_dir) == false)
        	errordlg('Channels must be from the same MED session', 'View MED');
            return;
        end

        n_new_chans = numel(new_chan_list);
        for i = 1:n_new_chans
            n_chans = n_chans + 1;
            chan_paths{n_chans} = [sess_dir DIR_DELIM new_chan_list{i}];
        end
        chan_paths = unique(chan_paths);

        % put new channel set in acquisition channel order with read_MED (not efficient, but probably not frequent)
        sess = read_MED_exec(chan_paths, page_start, page_start + 1e6, [], [], password);
        pause(OS_recovery_secs);
        clear read_MED_exec;
        if (isempty(sess))
            errordlg('read_MED() error', 'View MED');
            return;
        end
        n_chans = numel(sess.channels);
        chan_paths = cell(n_chans, 1);
        chan_list = cell(n_chans, 1);
        for i = 1:n_chans
            chan_paths{i} = sess.channels(i).metadata.path;
            chan_list{i} = sess.channels(i).metadata.channel_name;
        end
        page_start = sess.metadata.start_time;
        page_end = (page_start + wind_usecs) - 1;
        clear sess;
    
        % plot
        plot_handles = [];
        if (autoscale_flag == false)  % rescale plots for new trace set
            set(autoscale_button, 'String', 'Autoscaling is On');
            autoscale_flag = true;
        end
        potentially_increased_plot_time = true;
        plot_page(true);
                
        % Make channel labels
        set(deselect_all_button, 'Visible', 'off');
        selected_labels = [];
        create_labels();
        draw_labels();
        
        set_movement_focus();
    end

    % Session Map Callback
    function sess_map_callback(~, evt)
        x = evt.IntersectionPoint(1, 1);
    
        page_start = sess_start + round(sess_duration * (x / data_ax_width));

        plot_page(true);
        set_movement_focus();
    end

    % Export Callback
    function export_callback(~, ~)
        export_num = export_num + 1;
        d = dialog('Position', [400 400 250 150], ...
            'Name', 'Export to Workspace');
        d_txtbx_label = uicontrol('Parent', d, ...
            'Style', 'text', ...
            'Position', [10 102 70 30], ...
            'HorizontalAlignment', 'right', ...
            'String','Workspace Name:');
        d_txtbx = uicontrol('Parent', d, ...
            'Style','edit', ...
            'Position', [88 100 132 30], ...
            'HorizontalAlignment', 'left', ...
            'String', ['page_' num2str(export_num)]);
        d_raw_radbtn = uicontrol('Parent', d, ...
            'Style', 'radiobutton', ...
            'String', 'Raw Data', ...
            'Value', 1, ...
            'Position', [35 50 210 40], ...
            'BackgroundColor', panel_color, ...
            'FontSize', SYS_FONT_SIZE, ...
            'Callback', @d_radbtnsCallback);
        d_dsp_radbtn = uicontrol('Parent', d, ...
            'Style', 'radiobutton', ...
            'String', 'As Displayed', ...
            'Value', 0, ...
            'Position', [135 50 210 40], ...
            'BackgroundColor', panel_color, ...
            'FontSize', SYS_FONT_SIZE, ...
            'Callback', @d_radbtnsCallback);
        d_expt_btn = uicontrol('Parent', d, ...
            'Style', 'pushbutton', ...
            'Position', [95 20 70 25], ...
            'String', 'Export', ...
            'Callback', @d_expt_btnCallback);

        uiwait(d);
        if (isvalid(d))  % user hit close button
            close(d);
        end

        set_movement_focus();

        % Dialog export Button (nested)
        function d_expt_btnCallback(~, ~)
            if (new_page_secs > WAIT_POINTER_DELAY)
                set(d, 'Pointer', 'watch'); 
                drawnow;
            end
            expt_sess = read_MED_exec(chan_paths, page_start, page_end, [], [], password);
            pause(OS_recovery_secs);
            clear read_MED_exec;
            if (isempty(expt_sess))
                close(d);
                errordlg('read_MED() error', 'View MED');
                return;
            end
            if (d_dsp_radbtn.Value == true)  % assign raw page data to session structure    
                if (antialias_flag == true && expt_sess.metadata.sampling_frequency > screen_sf)
                        expt_sess.metadata.high_frequency_filter_setting = screen_sf / 4;
                end
                expt_sess.metadata.sampling_frequency = screen_sf;
                for i = 1:n_chans
                    expt_sess.channels(i).data = raw_page.samples(:, i);
                    if (antialias_flag == true && expt_sess.channels(i).metadata.sampling_frequency > screen_sf)
                        expt_sess.channels(i).metadata.high_frequency_filter_setting = screen_sf / 4;
                    end
                    expt_sess.channels(i).metadata.sampling_frequency = screen_sf;
                end
            end
            
            var_name = d_txtbx.String;
            assignin('base', var_name, expt_sess);
            clear expt_sess;

           % change dialog box
            delete(d_txtbx);
            delete(d_raw_radbtn);
            delete(d_dsp_radbtn);
            set(d_txtbx_label, ...
                'Position', [10 80 230 30], ...
                'FontSize', SYS_FONT_SIZE + 4, ...
                'HorizontalAlignment', 'center', ...
                'String', ['"' var_name '" exported']);
            set(d_expt_btn, 'String', 'OK', 'Callback', @d_ok_btnCallback);
            function d_ok_btnCallback(~, ~)
                close(d)
            end

            if (new_page_secs > WAIT_POINTER_DELAY)
                set(d, 'Pointer', 'arrow'); 
                drawnow;
            end
            uiwait(d, 5);

            return;
        end

        % Dialog Radio Buttons (nested)
        function d_radbtnsCallback(src, ~)
            if (src == d_raw_radbtn)
                if (d_raw_radbtn.Value == false)
                    d_dsp_radbtn.Value = true;
                else
                    d_dsp_radbtn.Value = false;
                end
            else
                if (d_dsp_radbtn.Value == false)
                    d_raw_radbtn.Value = true;
                else
                    d_raw_radbtn.Value = false;
                end
            end
        end

    end  % end Export Callback

    % Axis Time Callback
    function axis_time_callback(src, ~)
        if calendar_time_flag == true   % calendar time => �UTC time
            if recording_time_offset ~= 0
                calendar_time_flag = false; oUTC_flag = false;
                uUTC_flag = true;
                set(axis_start_time_string, 'String', ['start �UTC: ' num2str(page_start + recording_time_offset)]);
                set(axis_end_time_string, 'String', ['end �UTC: ' num2str(page_end + recording_time_offset)]);
            else
                calendar_time_flag = false; 
                oUTC_flag = true;
                set(axis_start_time_string, 'String', ['start oUTC: ' num2str(page_start)]);
                set(axis_end_time_string, 'String', ['end oUTC: ' num2str(page_end)]);   
            end
        elseif uUTC_flag == true   % �UTC time => oUTC time
            uUTC_flag = false; calendar_time_flag = false;
            oUTC_flag = true;
            set(axis_start_time_string, 'String', ['start oUTC: ' num2str(page_start)]);
            set(axis_end_time_string, 'String', ['end oUTC: ' num2str(page_end)]);   
        elseif oUTC_flag == true   % oUTC time => calendar time
            uUTC_flag = false; oUTC_flag = false;
            calendar_time_flag = true;
            set(axis_start_time_string, 'String', raw_page.start_time_string);
            set(axis_end_time_string, 'String', raw_page.end_time_string);
        end
        
        % copy data to clipboard
        if (src == axis_start_time_string)  % copy start times
            page_start_str = num2str(curr_usec / 1e6,  '%0.6f');
            if recording_time_offset ~= 0  % include �UTC
                clipboard('copy', ['Page Start Time:' newline raw_page.start_time_string newline '�UTC: ' num2str(page_start + recording_time_offset) newline 'oUTC: ' num2str(page_start) newline 'Relative (s): ' page_start_str newline]);
            else  % don't include �UTC
                clipboard('copy', ['Page Start Time:' newline raw_page.start_time_string newline 'oUTC: ' num2str(page_start) newline 'Relative (s): ' page_start_str newline]);
            end        
        else    % copy end times
            page_end_str = num2str((curr_usec + wind_usecs) / 1e6,  '%0.6f');
            if recording_time_offset ~= 0  % include �UTC
                clipboard('copy', ['Page End Time:' newline raw_page.end_time_string newline '�UTC: ' num2str(page_end + recording_time_offset) newline 'oUTC: ' num2str(page_end) newline 'Relative (s): ' page_end_str newline]);
            else  % don't include �UTC
                clipboard('copy', ['Page End Time:' newline raw_page.end_time_string newline 'oUTC: ' num2str(page_end) newline 'Relative (s): ' page_end_str newline]);
            end
        end

        set_movement_focus();
    end

    % Deselect All Callback
    function deselect_all_callback(~, ~)
        for i = 1:n_chans
            if selected_labels(i)
                selected_labels(i) = 0;
                set(chan_labels{i}, 'FontAngle', 'normal', 'BackgroundColor', panel_color);
                if (multicolor_flag == false)
                    set(chan_labels{i}, 'Color', 'black');
                end
            end
        end
        set(deselect_all_button, 'Visible', 'off');
        selected_labels = [];
        create_labels();
        draw_labels();
        set_movement_focus();
    end

    % Trace Ranges Callback
    function trace_ranges_callback(~, ~)
        if (ranges_checkbox.Value == true)
            ranges_flag = true;
            potentially_increased_plot_time = true;
            plot_page(true);  % need raw data to generate trace ranges
        else
            ranges_flag = false;
            % clear old trace range patches (don't need to plot)
            if (~isempty(range_patches))
                for i = 1:numel(range_patches)
                    delete(range_patches{i});
                end
                range_patches = [];
            end
        end
        set_movement_focus();
    end

    % Records Callback
    function records_callback(~, ~)
        if (records_checkbox.Value == true)
            records_flag = true;
            plot_sess_record_times();
            plot_page(false);
        else
            records_flag = false;
            % clear old record lines (don't need to plot)
            if (~isempty(record_lines))
                for i = 1:numel(record_lines)
                    delete(record_lines{i}.line);
                    delete(record_lines{i}.flag);
                end
                record_lines = [];
            end
            delete(sess_map_records_lines);
        end
        set_movement_focus();
    end

    % Record Line Callback
    function rec_line_callback(src, ~)

        for i = 1:numel(record_lines)
            if (src == record_lines{i}.flag)
                rec_idx = i;
                break;
            end
        end 

        coords = get(fig, 'Position');    % screen coordinates
        flag_screen_left = coords(1);
        flag_screen_top = coords(2);
        
        coords = get(data_ax, 'Position');    % figure coordinates
        flag_screen_left = flag_screen_left + coords(1);
        flag_screen_top = flag_screen_top + coords(2);

        coords = get(record_lines{i}.flag, 'XData');  % x axis coordinates
        flag_screen_left = flag_screen_left + coords(1);
        flag_screen_top = flag_screen_top + data_ax_height;

        rec_type = raw_page.records{rec_idx}.type_string;
        blurb = [ 'Type: ' rec_type ' v' raw_page.records{rec_idx}.version_string newline ...
            'Encryption: ' raw_page.records{rec_idx}.encryption_string newline ...
            'Start Time: ' raw_page.records{rec_idx}.start_time_string newline];

        switch rec_type
            case 'NlxP'
                title = 'Neuralynx Port Record';
                blurb = [blurb 'Subport: ' num2str(raw_page.records{rec_idx}.subport) newline 'Value: ' num2str(raw_page.records{rec_idx}.value)];
            case 'Note'
                title = 'Annotation Record';
                blurb = [blurb 'Text: ' raw_page.records{rec_idx}.text];
            case 'Sgmt'
                title = 'Segment Record';
                if raw_page.records{rec_idx}.encryption <= 0
                    if ischar(raw_page.records{rec_idx}.start_sample_number)
                        blurb = [blurb 'End Time: ' raw_page.records{rec_idx}.end_time_string newline ...
                            'Start Sample Number: ' raw_page.records{rec_idx}.start_sample_number newline ...
                            'End Sample Number: ' raw_page.records{rec_idx}.end_sample_number newline ...
                            'Segment Number: ' num2str(raw_page.records{rec_idx}.segment_number) newline ...
                            'Segment UID: ' num2str(raw_page.records{rec_idx}.segment_UID) newline ...
                            'Description: ' raw_page.records{rec_idx}.description];
                    else
                        blurb = [blurb 'End Time: ' raw_page.records{rec_idx}.end_time_string newline ...
                            'Start Sample Number: ' num2str(raw_page.records{rec_idx}.start_sample_number) newline ...
                            'End Sample Number: ' num2str(raw_page.records{rec_idx}.end_sample_number) newline ...
                            'Segment Number: ' num2str(raw_page.records{rec_idx}.segment_number) newline ...
                            'Segment UID: ' num2str(raw_page.records{rec_idx}.segment_UID) newline ...
                            'Description: ' raw_page.records{rec_idx}.description];
                    end
                else
                    blurb = [blurb 'End Time: ' raw_page.records{rec_idx}.end_time_string newline ...
                        'Start Sample Number: ' raw_page.records{rec_idx}.start_sample_number newline ...
                        'End Sample Number: ' raw_page.records{rec_idx}.end_sample_number newline ...
                        'Segment Number: ' raw_page.records{rec_idx}.segment_number newline ...
                        'Segment UID: ' raw_page.records{rec_idx}.segment_UID newline ...
                        'Description: ' raw_page.records{rec_idx}.description];
               end
            otherwise  % unknown record type
                title = 'Unknown Record';
                blurb = [blurb 'Comment: ' raw_page.records{rec_idx}.comment];
        end

        clipboard('copy', blurb);
        blurb = [blurb newline newline '(copied to clipboard)'];

        d_left = flag_screen_left - 170;
        d_bot = flag_screen_top - 260;
        d = dialog('Position', [d_left d_bot 340 180], 'Name', title, 'Color', 'white');
        uicontrol('Parent', d, ...
           'Style', 'text', ...
           'FontSize', SYS_FONT_SIZE, ...
           'BackgroundColor', 'white', ...
           'HorizontalAlignment', 'left', ...
           'Position', [10 10 320 160], ...
           'String', blurb);
        
        uiwait(d, 15);
        if (isvalid(d))
            close(d);
        end

        set_movement_focus();
    end

    % Discontinuity Line Callback
    function discont_line_callback(src, ~)
       for i = 1:numel(discont_lines)
            if (src == discont_lines{i}.zag)
                discont_idx = i;
                break;
            end
        end

        coords = get(fig, 'Position');    % screen coordinates
        zag_screen_left = coords(1);
        zag_screen_top = coords(2);
        
        coords = get(data_ax, 'Position');    % figure coordinates
        zag_screen_left = zag_screen_left + coords(1);
        zag_screen_top = zag_screen_top + coords(2);

        coords = get(discont_lines{i}.zag, 'XData');  % x axis coordinates
        zag_screen_left = zag_screen_left + coords(1);
        zag_screen_top = zag_screen_top + data_ax_height;

        discont_start_time = raw_page.contigua(discont_idx).end_time + 1;
        discont_start_string = ['Start Time: ' raw_page.contigua(discont_idx).end_time_string];
        discont_end_time = raw_page.contigua(discont_idx + 1).start_time - 1;
        discont_end_string = ['End Time: ' raw_page.contigua(discont_idx + 1).start_time_string];
        discont_dur = double((discont_end_time - discont_start_time) + 1) / double(1e6);
        duration_string = ['Duration: ' num2str(discont_dur) ' (sec)'];

        blurb = [discont_start_string newline discont_end_string newline duration_string];
        clipboard('copy', blurb);
        blurb = [blurb newline newline '(copied to clipboard)'];

        d_left = zag_screen_left - 170;
        d_bot = zag_screen_top - 180;
        d = dialog('Position', [d_left d_bot 340 100], 'Name', 'Discontinuity', 'Color', 'white');

        uicontrol('Parent', d, ...
           'Style', 'text', ...
           'FontSize', SYS_FONT_SIZE, ...
           'BackgroundColor', 'white', ...
           'HorizontalAlignment', 'left', ...
           'Position', [10 10 320 80], ...
           'String', blurb);
        
        uiwait(d, 15);
        if (isvalid(d))
            close(d);
        end

        set_movement_focus();
    end

    % Logo Callback
    function logo_callback(~, ~)
        d = dialog('Position', [400 400 220 140], 'Name', 'About View_MED...', 'Color', 'white');
        
        blurb = ['A Matlab viewer for MED format files' newline newline ...
            'by Matt Stead' newline newline ...
            'Copyright Dark Horse Neuro, 2021' newline ...
            'Bozeman, Montana, USA' newline newline ...
            'w.a.t.i.w.'];
        
        uicontrol('Parent', d, ...
           'Style', 'text', ...
           'FontSize', SYS_FONT_SIZE, ...
           'BackgroundColor', 'white', ...
           'HorizontalAlignment', 'left', ...
           'Position', [10 10 200 120], ...
           'String', blurb);
        
        sound(neh_signal, neh_sf);

        uiwait(d, 15);
        if (isvalid(d))
            close(d);
        end

        set_movement_focus();
    end

    % Axis Drag Functions
    function ax_mouse_down_callback(~, ~)
        ax_mouse_down = true;  % reset by ax_mouse_up()

        curr_p = get(fig, 'CurrentPoint');
        x = curr_p(1);
        if (x <= data_ax_left || x >= data_ax_right)
            ax_mouse_down = false;
            return;
        end
        y = curr_p(2);
        if (y <= data_ax_bot || y >= (data_ax_top - 20))  % leave room for clicking on flags & discontinuities)
            ax_mouse_down = false;
            return;
        end

        % abort: user clicked & let go
        pause(0.3);
        if (ax_mouse_down == false)
            return;
        end

        % plot big page
        page_start = page_start - wind_usecs;
        wind_usecs = wind_usecs * 3;
        x_ax_inds = ((1 - data_ax_width):(2 * data_ax_width))';
        x_tick_inds = linspace(x_ax_inds(1), x_ax_inds(end), 31);
        full_page_width = data_ax_width * 3; 
        potentially_increased_plot_time = true;
        plot_handles = [];
        plot_page(true);

        % drag
        set(fig, 'Pointer', 'hand'); 
        drawnow;
        cum_dx = 0;
        curr_p = get(0, 'PointerLocation');
        last_x = round(curr_p(1));
        new_lims = [1 data_ax_width];
        while (ax_mouse_down == true)
            curr_p = get(0, 'PointerLocation');
            curr_x = round(curr_p(1));
            dx = last_x - curr_x;
            if (dx)
                new_lims = new_lims + dx;
                cum_dx = cum_dx + dx;
                last_x = curr_x;
                set(data_ax, 'XLim', new_lims);
            end
            pause(0.05);  % give ax_mouse_up_callback a chance to run
        end

        % get new page with dragged limits
        wind_usecs = round(wind_usecs / 3);
        new_page_secs = new_page_secs / 3;
        page_start = page_start + wind_usecs + round(wind_usecs * (cum_dx / data_ax_width));
        x_ax_inds = (1:data_ax_width)';
        x_tick_inds = linspace(1, data_ax_width, 11);
        full_page_width = data_ax_width;
        reset_pointer = true;
        plot_handles = [];        
        plot_page(true);
        set_movement_focus();
    end

    function ax_mouse_up_callback(~, ~)
        ax_mouse_down = false;
    end

	% Figure Close Callback
    function figure_close_callback(~, ~)
        delete(fig);
    end

    % comment out to allow control to return to command window after loading 
    % uiwait(fig);  % wait for fig to be deleted

end % view_MED

