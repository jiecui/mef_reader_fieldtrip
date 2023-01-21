function matrix = matrix_MED(chan_list, start_time, end_time, n_out_samps, varargin)

    %
    %   matrix_MED() requires Four to 8 inputs: 
    %   1)  chan_list
    %   2)  start_time
    %   3)  end_time
    %   4)  n_out_samps
    %   5)  [password]
    %   6)  [antialias ([true] / false)]
    %   7)  [detrend (true / [false])]
    %   8)  [trace_ranges (true / [false])] 
    %
    %   Prototype:
    %   matrix_struct = matrix_MED(chan_list, start_time, end_time, n_out_samps, [password], [antialias], [detrend], [trace_ranges]);
    %
    %   matrix_MED() returns a single Matlab matrix structure
    %
    %   Arguments in square brackets are optional => '[]' will substitute default values
    %
    %   Input Arguments:
    %   chan_list:  cell array of strings (strings can contain regexp)
    %   start_time:  if empty/absent, defaults to session/channel start (unless indices are specified)
    %   end_time:  if empty/absent, defaults to session/channel end (unless indices are specified)
    %   n_out_samps: the output matrix sample dimension
    %   password:  if empty/absent, proceeds as if unencrypted (but, may error out)
    %   antialias:  if empty/absent, defaults to 'true' (options: 'true', 'false')
    %   detrend:  if empty/absent, defaults to 'false' (options: 'true', 'false')
    %   trace_ranges:  if empty/absent, defaults to 'false' (options: 'true', 'false')
    %
    %   In MED, times are preferable to indices as they are independent of sampling frequencies
    %       a) times are natively in offset µUTC (oUTC), but unoffset times may be used
    %       b) negatives times are considered to be relative to the session start
    %
    %   Copyright Dark Horse Neuro, 2021


    if nargin < 4 || nargin > 8 || nargout ~=  1
        help matrix_MED;
        return;
    end
   
    %   Enter DEFAULT_PASSWORD here for convenience, if doing does not violate your privacy requirements
    DEFAULT_PASSWORD = [];
    if nargin >= 5
        password = varargin{1};
    else
        password = DEFAULT_PASSWORD;
    end

    if nargin >= 6
        antialias = varargin{2};
    else
        antialias = [];
    end

    if nargin >= 7
        detrend = varargin{3};
    else
        detrend = [];
    end

    if nargin >= 8
        trace_ranges = varargin{4};
    else
        trace_ranges = [];
    end

    clear matrix_MED_exec;  % This is critical, and the entire reason for this wrapper function.
                          %
                          % Shared libraries from previous calls must be unloaded, or the 
                          % function will crash on repeated calls.
                          %
                          % If you don't want use this wrapper, just call read_MED_exec() exactly 
                          % as you call read_MED(), but call 'clear read_MED_exec' first.
                          % You will also need to add the 'Resources' folder to your path as below.
    
    try
        matrix = matrix_MED_exec(chan_list, start_time, end_time, n_out_samps, password, antialias, detrend, trace_ranges);
        if (isempty(matrix))
            errordlg('matrix_MED() error', 'Read MED');
            return;
        end
    catch ME
        clear matrix_MED_exec;
        OS = computer;
        if (strcmp(OS, 'PCWIN64') == 1)
            DIR_DELIM = '\';
        else
            DIR_DELIM = '/';
        end
        switch ME.identifier
            case 'MATLAB:UndefinedFunction'
                [READ_MED_PATH, ~, ~] = fileparts(which('read_MED'));
                RESOURCES = [READ_MED_PATH DIR_DELIM 'Resources'];
                addpath(RESOURCES, READ_MED_PATH, '-begin');
                savepath;
                msg = ['Added ', RESOURCES, ' to your search path.' newline];
                beep
                fprintf(2, '%s', msg);  % 2 == stderr, so red in command window
                matrix = matrix_MED_exec(chan_list, start_time, end_time, n_out_samps, password, antialias, detrend, trace_ranges);
            otherwise
                matrix = [];
                rethrow(ME);
        end
    end
    
end

