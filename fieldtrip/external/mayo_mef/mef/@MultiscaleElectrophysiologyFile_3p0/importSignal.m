function [x, t] = importSignal(this, start_end, st_unit, filepath, filename, options)
    % MULTISCALEELECTROPHYSIOLOGYFILE_3P0.IMPORTMEF Import MEF 3.0 channel into MATLAB
    %
    % Syntax:
    %   [x, t] = importSignal(this)
    %   [x, t] = importSignal(__, start_end)
    %   [x, t] = importSignal(__, start_end, st_unit)
    %   [x, t] = importSignal(__, start_end, st_unit, filepath)
    %   [x, t] = importSignal(__, start_end, st_unit, filepath, filename)
    %   [x, t] = importSignal(__, 'Level1Password', level_1_pw)
    %   [x, t] = importSignal(__, 'Level2Password', level_2_pw)
    %   [x, t] = importSignal(__, 'AccessLevel', access_level)
    %
    % Imput(s):
    %   this            - [obj] MultiscaleElectrophysiologyFile object
    %   start_end       - [1 x 2 array] (opt) [start time/index, end time/index] of
    %                     the signal to be extracted fromt the file (default:
    %                     the entire signal)
    %   st_unit         - [str] (opt) unit of start_end: 'Index' (default), 'uUTC',
    %                     'Second', 'Minute', 'Hour', and 'Day'
    %   filepath        - [str] (opt) directory of the session
    %   filename        = [str] (opt) filename of the channel
    %   level_1_pw      - [str] (para) password of level 1 (default = this.Level1Password)
    %   level_2_pw      - [str] (para) password of level 2 (default = this.Level2Password)
    %   access_level    - [str] (para) data decode level to be used
    %                     (default = this.AccessLevel)
    %
    % Output(s):
    %   x               - [num array] extracted signal
    %   t               - [num array] time indices of the signal in the file
    %
    % Note:
    %   Import data from one channel of MEF 3.0 file into MatLab.
    %
    % See also .

    % Copyright 2020 Richard J. Cui. Created: Wed 02/05/2020 10:24:56.722 PM
    % $Revision: 0.3 $  $Date: Fri 04/03/2020  5:11:57.375 PM $
    %
    % Multimodel Neuroimaging Lab (Dr. Dora Hermes)
    % Mayo Clinic St. Mary Campus
    % Rochester, MN 55905, USA
    %
    % Email: richard.cui@utoronto.ca

    % ======================================================================
    % parse inputs
    % ======================================================================
    % parse inputs now
    % ----------------
    arguments
        this (1, 1) MultiscaleElectrophysiologyFile_3p0
    end % positional

    arguments
        start_end (1, 2) double {mustStartLessThanOrEqualEnd} = [] % [start, end] time/index of the signal to be extracted
        st_unit (1, 1) string {mustBeMember(st_unit, {'Index', 'uUTC', 'Second', 'Minute', 'Hour', 'Day'})} = 'Index' % unit of start_end
        filepath (1, :) char = '' % directory of the session
        filename (1, :) char = '' % filename of the channel
        options.Level1Password (1, :) char = '' % password of level 1
        options.Level2Password (1, :) char = '' % password of level 2
        options.AccessLevel (1, 1) double = NaN % data decode level to be used
    end % optional

    l1_pw = options.Level1Password;
    l2_pw = options.Level2Password;
    al = options.AccessLevel;

    % password
    % --------
    if isempty(l1_pw)
        l1_pw = this.Level1Password;
    else
        this.Level1Password = l1_pw;
    end % if

    if isempty(l2_pw)
        l2_pw = this.Level2Password;
    else
        this.Level2Password = l2_pw;
    end % if

    if isnan(al)
        al = this.AccessLevel;
    else
        this.AccessLevel = al;
    end % if

    pw = this.processPassword('Level1Password', l1_pw, ...
        'Level2Password', l2_pw, ...
        'AccessLevel', al);

    % get the channel metadata if both filepath and filename are provided
    % -------------------------------------------------------------------
    if isfield(this, 'PathToSession')
        path_to_sess = this.PathToSession;
    else
        path_to_sess = pwd;
    end % if

    if isempty(filepath)
        filepath = this.FilePath;
    else
        this.FilePath = filepath;
    end % if

    if isempty(filename)
        filename = this.FileName;
    else
        this.FileName = filename;
    end % if

    wholename = fullfile(path_to_sess, filepath, filename);

    % * find the channel number
    st_chan = this.MetaData.time_series_channels;
    ch_names = string({st_chan.name});
    [~, ch_current] = fileparts(filename);
    ch_number = find(ch_names == ch_current, 1);

    % * update header and channel info
    channel = st_chan(ch_number);
    this.Header = channel.header;
    this.Channel = channel;

    % start and end time points
    % -------------------------
    switch lower(st_unit)
        case 'index'
            se_index = start_end;
        otherwise
            se_index = this.SampleTime2Index(start_end, st_unit);
    end % switch

    if isempty(start_end) == true
        start_ind = this.SampleTime2Index(this.Channel.earliest_start_time);
        end_ind = this.SampleTime2Index(this.Channel.latest_end_time);
        se_index = [start_ind, end_ind];
    end % if

    % check
    if se_index(1) < 1
        se_index(1) = 1;
        warning('MultiscaleElectrophysiologyFile_3p0:ImportSignal:discardSample', ...
        'Reqested data samples before the recording are discarded')
    end % if

    if se_index(2) > this.Channel.metadata.section_2.number_of_samples
        se_index(2) = this.Channel.metadata.section_2.number_of_samples;
        warning('MultiscaleElectrophysiologyFile_3p0:ImportSignal:discardSample', ...
        'Reqested data samples after the recording are discarded')
    end % if

    % verbose
    % -------
    num_samples = diff(start_end) + 1;

    if num_samples > 2 ^ 20
        verbo = true;
    else
        verbo = false;
    end % if

    % ======================================================================
    % load the data
    % ======================================================================
    if verbo
        [~, thisChannel] = fileparts(wholename);
        fprintf(['-->Loading ' thisChannel ' ...'])
        clear thisChannel
    end % if

    x = this.read_mef_ts_data_3p0(wholename, pw, 'samples', se_index(1), se_index(2));
    x = double(x(:)).'; % change to row vector
    % find the indices corresponding to physically collected data
    if nargout == 2
        t = se_index(1):se_index(2);
    end % if

    if verbo, fprintf('Done!\n'), end % if

end

% ==========================================================================
% subroutines
% ==========================================================================
function mustStartLessThanOrEqualEnd(x)

    if x(1) > x(2)
        error('The first element must be less than or equal to the second element.');
    end

end

% [EOF]
