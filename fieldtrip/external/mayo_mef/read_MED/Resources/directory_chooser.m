

function [directories, parent_directory] = directory_chooser(varargin)

    %   [directories, parent_directory] = directory_chooser([filters], [start_directory], [stop_filters], [parent_directory])
    %
    %   e.g. 
    %	filters = {'medd', 'ticd'};
    %   start_dir = '/Volumes/my_disk/my_data';
    %   stop_filters = {'ticd'};  %% nothing below these directory types => a double click on these == select, not open
    %	[files/directories, parent_directory] = directory_chooser(filters, start_dir, stop_filters);
       
    %   Copyright Dark Horse Neuro, 2020

    if (nargin > 3)
        help directory_chooser;
        return;
    end
    
    filters = [];
    startDirectory = [];
    stop_filters = [];
    if (nargin >= 1)
        filters = varargin{1};
    end
    if (nargin >= 2)
        startDirectory = varargin{2};
    end
    if (nargin == 3)
        stop_filters = varargin{3};
    end
    
    OS = computer;
    WINDOWS = false;
    DIR_DELIM = '/';
    switch OS
        case 'MACI64'       % MacOS
            SYS_FONT_SIZE = 13;
        case 'GLNXA64'      % Linux
            SYS_FONT_SIZE = 9;
        case 'PCWIN64'      % Windows
            SYS_FONT_SIZE = 10;
            WINDOWS = true;
            DIR_DELIM = '\';
        otherwise           % Unknown OS
            SYS_FONT_SIZE = 9;
    end

    directories = {};
    parent_directory = '';

    % Globals
    parentDirectoryString = '';
    parentDirectoryList = {};
    parentDirectoryLevels = 0;
    directoryList = {};


    % ------------ GUI Layout ---------------

    % Figure
    fig = figure('Units','pixels', ...
        'Position',[200 175 298 695], ...
        'HandleVisibility','on', ...
        'IntegerHandle','off', ...
        'Renderer','painters', ...
        'Toolbar','none', ...
        'Menubar','none', ...
        'NumberTitle','off', ...
        'Name','Directory Chooser', ...
        'Resize', 'off', ...
        'CloseRequestFcn', @figureCloseCallback);
    
    panelColor = get(fig, 'Color');

    % Axes
    ax = axes('parent', fig, ...
        'Units', 'pixels', ...
        'Position', [1 1 298 695], ...
        'Xlim', [1 700], 'Ylim', [1 700], ...
        'Visible', 'off');
    
    % Parent Directory Label
    text('Position', [57 677], ...
        'String', 'Parent Directory:', ...
        'Color', 'k', ...
        'FontSize', SYS_FONT_SIZE, ...
        'HorizontalAlignment', 'left', ...
        'FontWeight', 'bold', ...
        'FontName', 'FixedWidth');

    % Parent Directory Popup
    parentDirectoryPopup = uicontrol(fig,...
        'Style', 'popupmenu', ...
        'String', {}, ...
        'Position', [20 635 262 25], ...
        'FontSize', SYS_FONT_SIZE, ...
        'FontName', 'FixedWidth', ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left', ...
        'Callback', @parentDirectoryPopupCallback);
 
    % Parent Directory Contents Label
    text('Position', [57 602], ...
        'String', 'Contents:', ...
        'Color', 'k', ...
        'FontSize', SYS_FONT_SIZE, ...
        'HorizontalAlignment', 'left', ...
        'FontWeight', 'bold', ...
        'FontName', 'FixedWidth');

    % Directory Listbox
    directoryListbox = uicontrol(fig, ...
        'Style', 'listbox', ...
        'String', {}, ...
        'Position', [25 75 250 510], ...
        'FontSize', SYS_FONT_SIZE,...
        'FontName', 'FixedWidth', ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'Min', 1, ...
        'Max', 65536, ...
        'Callback', @directoryListboxCallback);
    
    % Plot Pushbutton
    selectPushbutton = uicontrol(fig, ...
        'Style', 'pushbutton', ...
        'String', 'Select', ...
        'Position', [60 25 180 30], ...
        'BackgroundColor', panelColor, ...
        'FontSize', SYS_FONT_SIZE, ...
        'FontName', 'FixedWidth', ...
        'HorizontalAlignment', 'left', ...
        'Callback', @selectPushbuttonCallback);
    
    
    % ------------- Callbacks ---------------
    
    % Figure Close
    function figureCloseCallback(~, ~)
        delete(fig);
    end

    % Parent Directory Popup
    function parentDirectoryPopupCallback(~, ~)
        parentDirectoryLevels = parentDirectoryPopup.Value;
        parentDirectoryList = parentDirectoryList(1:parentDirectoryLevels);
        parentDirectoryPopup.String = parentDirectoryList;
        updateParentDirectoryString();
        updateParentDirectoryList();
        updateDirectoryList();
    end

    function directoryListboxCallback(~, ~)
        selected = directoryListbox.String(directoryListbox.Value);
        n_selected = length(selected);

        % double click (no double click on multiple selection for now)
        if (n_selected == 1)
            if (strcmp(get(gcf, 'selectiontype'), 'open') == true)
                % up one level
                if (strcmp(selected, '..') == true)
                    parentDirectoryLevels = parentDirectoryLevels - 1;
                    parentDirectoryList = parentDirectoryList(1:parentDirectoryLevels);
                    parentDirectoryPopup.String = parentDirectoryList;
                    parentDirectoryPopup.Value = parentDirectoryLevels;
                    updateParentDirectoryString();
                    updateDirectoryList();
                % down one level
                else
                    passed_stop_filters = checkStopFilters();
                    if (passed_stop_filters == true)
                        if (parentDirectoryLevels == 1)
                            parentDirectoryString = '';
                        end
                        parentDirectoryString = [parentDirectoryString DIR_DELIM char(selected)];
                        updateParentDirectoryList();
                        updateDirectoryList();
                    else  % treat double click as selection
                        selectPushbuttonCallback();
                    end
                end
            end
        else  % multiple selection
            checkSelected();
        end
    end

    function selectPushbuttonCallback(~, ~)
        % check if selected is '..'
        if (directoryListbox.Value(1) == 1)
            selected = directoryListbox.String(directoryListbox.Value);
            if (strcmp(selected, '..') == 1)
                parentDirectoryLevels = parentDirectoryLevels - 1;
                parentDirectoryList = parentDirectoryList(1:parentDirectoryLevels);
                parentDirectoryPopup.String = parentDirectoryList;
                parentDirectoryPopup.Value = parentDirectoryLevels;
                updateParentDirectoryString();
                updateDirectoryList();
                return;
            end
        end
        % check that selection passes filters
        checkSelected();
        if (directoryListbox.Value(1) ~= 1)
            directories = directoryListbox.String(directoryListbox.Value);
            if (WINDOWS == true)
                parent_directory = parentDirectoryString(2:end);
            else
                parent_directory = parentDirectoryString;
            end
            figureCloseCallback();
        end
    end

    % ----------- Initializations -----------
    
    % Parent Directory String
    if (isempty(startDirectory)) 
        parentDirectoryString = DEFAULT_PARENT_DIRECTORY;
    else
        if (WINDOWS == true)
            if (startDirectory(1) == DIR_DELIM)
                parentDirectoryString = [DIR_DELIM 'C:' startDirectory];
            elseif (startDirectory(1) >= 'A' && startDirectory(1) <= 'Z')
                parentDirectoryString = [DIR_DELIM startDirectory];
            else
                parentDirectoryString = [DIR_DELIM pwd DIR_DELIM startDirectory];
            end
        else  % MacOS or Linux
            if (startDirectory(1) == DIR_DELIM)  
                parentDirectoryString = startDirectory;
            else
                parentDirectoryString = [pwd DIR_DELIM startDirectory];
            end
        end
    end
    
    % Parent Directory Popup
    updateParentDirectoryList();
    
    % Directory Contents Listbox
    updateDirectoryList();
    
    % User starting point
    uicontrol(parentDirectoryPopup); 


    % ---------- Support Functions ----------
    
    function updateParentDirectoryString()
        if (parentDirectoryLevels == 1)
                parentDirectoryString = DIR_DELIM;
        else
            parentDirectoryString = '';
            for i = 2:parentDirectoryLevels
                parentDirectoryString = [parentDirectoryString DIR_DELIM char(parentDirectoryList(i))];
            end
        end
    end

    function updateParentDirectoryList()
        parentDirectoryLevels = 0;
        d_list = {};
        d_name = parentDirectoryString;
        len = length(d_name);
        
        while (len > 1)
            i = len;
            while (d_name(i) ~= DIR_DELIM)
                i = i - 1;
            end
            if (i ~= len)
                name = d_name((i + 1):length(d_name));
                parentDirectoryLevels = parentDirectoryLevels + 1;
                d_list{parentDirectoryLevels} = name;
            end
            len = i - 1;
            d_name = d_name(1:len);
        end
        parentDirectoryLevels = parentDirectoryLevels + 1;
        d_list{parentDirectoryLevels} = DIR_DELIM;
        parentDirectoryList = flip(d_list);
        
        parentDirectoryPopup.String = parentDirectoryList;
        parentDirectoryPopup.Value = parentDirectoryLevels;
    end

    function updateDirectoryList()
        directoryList = {};
        if (parentDirectoryLevels > 1)
            directoryList{1} = '..';
            i = 1;
        else
            i = 0;
        end
        if (WINDOWS == true)
            if (parentDirectoryLevels == 1)
                d = winGetDriveList();
            elseif (parentDirectoryLevels == 2)
                d = dir([parentDirectoryString(2:end) DIR_DELIM]);
            else
                d = dir(parentDirectoryString(2:end));
            end
        else
            d = dir(parentDirectoryString);
        end
        len = length(d);
        for j = 1:len
            if (d(j).isdir == 1)
                if (d(j).name(1) ~= '.' && d(j).name(1) ~= '$')
                    i = i + 1;
                    directoryList{i} = d(j).name;
                end
            end
        end
        
        case_insens_sort = sortrows([directoryList' upper(directoryList')], 2);
        directoryList = case_insens_sort(:, 1);
        directoryListbox.String = directoryList;
        directoryListbox.Value = 1;
    end

    function n_selected = checkSelected()        
        n_filters = numel(filters);
        values = directoryListbox.Value;
        n_selected = length(values);
        if (isempty(filters))
            return;
        end
 
        for i = 1:n_selected
            selected_str = char(directoryListbox.String(values(i)));
            passed_filter = 0;
            for j = 1:n_filters
                filter = char(filters(j));
                filt_len = length(filter) - 1;
                if (length(selected_str) > filt_len)
                    if (strcmp(selected_str((end - filt_len):end), filter) == 1)
                        passed_filter = 1;
                        break;
                    end
                end
            end
            if (passed_filter == 0)
                values(i) = 0;
            end
        end
        values = values(values ~= 0);
        if isempty(values)
            values = 1;
        end
        directoryListbox.Value = values;
        n_selected = length(values);
    end

    function passed_filters = checkStopFilters()
      passed_filters = true;
      if (isempty(stop_filters))
            return;
        end
        
        n_filters = numel(stop_filters);
        values = directoryListbox.Value;
        n_selected = length(values);
        if (n_selected ~= 1)
            return;
        end
        
        selected_str = char(directoryListbox.String(values(1)));
        for i = 1:n_filters
            filter = char(stop_filters(i));
            filt_len = length(filter) - 1;
            if (length(selected_str) > filt_len)
                if (strcmp(selected_str((end - filt_len):end), filter) == 1)
                    passed_filters = false;
                    break;
                end
            end
        end
    end

    function d = winGetDriveList()
        d = [];
        [r, t] = system('wmic logicaldisk get name');
        if (r ~= 0)
            return;
        end
        % output format:
        % 'Name<spc><spc>\r\n' (characters 1-8)
        % '<drive_letter>:<spc><spc><spc><spc>\r\n' (characters 9-16)
        % ...
        % \r\n
        offset = 9;
        n_drives = 0;
        while (t(offset) >= 'A' && t(offset) <= 'Z')
            n_drives = n_drives + 1;
            d(n_drives).isdir = 1;
            d(n_drives).name = [t(offset) ':'];
            offset = offset + 8;
        end
    end

    % wait for figure close
    uiwait(fig);
    delete(fig);

end  % End Directory Chooser
