function session = read_MED(file_list, varargin)

    %
    %   read_MED() requires 1 to 8 inputs
    %
    %   Prototype:
    %   session = read_MED(file_list, [start_time], [end_time], [start_index], [end_index], [password], [indices_reference_channel], [samples_as_singles]);
    %
    %   read_MED() returns a single Matlab session structure
    %
    %   Arguments in square brackets are optional => '[]' will substitute default values
    %
    %   Input Arguments:
    %   file_list:  string array, strings can contain regexp
    %   start_time:  if empty/absent, defaults to session/channel start (unless indices are specified)
    %   end_time:  if empty/absent, defaults to session/channel end (unless indices are specified)
    %   start_index:  if empty/absent, defaults to session/channel start (unless times are specified)
    %   end_index:  if empty/absent, defaults to session/channel end (unless times are specified)
    %   password:  if empty/absent, proceeds as if unencrypted (but, may error out)
    %   indices_reference_channel:  if empty/absent, and necessary, defaults to first channel in set
    %   samples_as_singles:  if empty/absent, defaults to 'false' (options: 'true', 'false')
    %
    %   If samples_as_singles is set to 'true', sample values are returned as singles (32-bit floating 
    %   point numbers), rather than doubles (64-bit floating point numbers, the Matlab default type).
    %   Singles have adequate precision to exactly represent integers up to 24-bits.
    %   Exercising this option doubles the amount of data that can be stored in memory by Matlab.
    %
    %   In MED, times are preferable to indices as they are independent of sampling frequencies
    %       a) times are natively in offset µUTC (oUTC), but unoffset times may be used
    %       b) negatives times are considered to be relative to the session start
    %       c) if indices are used, index numbering begins at 1, per Matlab convention
    %
    %   In sessions with varying sampling frequencies, the indices reference channel is used to
    %   determine the import extents on all channels when delimited by index values
    %
    %   e.g. to get samples 1001:2000 from 'channel_1', and all the corresponding samples, in time, 
    %   from the other channels, regardless of their sampling frequencies: specify 1001 as the start 
    %   index, 2000 as the end index, and 'channel_1' as the indices_reference_channel
         
    %   Copyright Dark Horse Neuro, 2021


    if nargin == 0 || nargin > 8 || nargout ~=  1
        help read_MED;
        return;
    end
    
    if nargin > 1
        start_time = varargin{1};
    else
        start_time = [];
    end
  
    if nargin > 2
        end_time = varargin{2};
    else
        end_time = [];
    end

    if nargin > 3
        start_index = varargin{3};
    else
        start_index = [];
    end
  
    if nargin > 4
        end_index = varargin{4};
    else
        end_index = [];
    end

    %   Enter DEFAULT_PASSWORD here for convenience, if doing does not violate your privacy requirements
    DEFAULT_PASSWORD = [];
    if nargin > 5
        password = varargin{5};
    else
        password = DEFAULT_PASSWORD;
    end

    if nargin > 6
        reference_channel = varargin{6};
    else
        reference_channel = [];
    end

    if nargin > 7
        samples_as_singles = varargin{7};
    else
        samples_as_singles = [];
    end

    clear read_MED_exec;  % This is critical, and the entire reason for this wrapper function.
                          %
                          % Shared libraries from previous calls must be unloaded, or the 
                          % function will crash on repeated calls.
                          %
                          % If you don't want use this wrapper, just call read_MED_exec() exactly 
                          % as you call read_MED(), but call 'clear read_MED_exec' first.
                          % You will also need to add the 'Resources' folder to your path as below.
    
    try
        session = read_MED_exec(file_list, start_time, end_time, start_index, end_index, password, reference_channel, samples_as_singles);
        clear read_MED_exec;
        if (isempty(session))
            errordlg('read_MED() error', 'Read MED');
            return;
        end
    catch ME
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
                msg = [Added ', RESOURCES, ' to your search path.' newline];
                beep
                fprintf(2, '%s', msg);  % 2 == stderr, so red in command window
                session = read_MED_exec(file_list, start_time, end_time, start_index, end_index, password, reference_channel, samples_as_singles);
            otherwise
                session = [];
                rethrow(ME);
        end
    end
    
end

