function [x, t, t_unit] = importSignal(this, start_end, st_unit, filepath, filename, options)
    % MULTISCALEELECTROPHYSIOLOGYFILE_3P0.IMPORTMEF Import MEF 3.0 channel into MATLAB
    %
    % Syntax:
    %   [x, t, t_unit] = importSignal(this)
    %   [x, t, t_unit] = importSignal(__, start_end)
    %   [x, t, t_unit] = importSignal(__, start_end, st_unit)
    %   [x, t, t_unit] = importSignal(__, start_end, st_unit, filepath)
    %   [x, t, t_unit] = importSignal(__, start_end, st_unit, filepath, filename)
    %   [x, t, t_unit] = importSignal(__, 'Level1Password', level_1_pw)
    %   [x, t, t_unit] = importSignal(__, 'Level2Password', level_2_pw)
    %   [x, t, t_unit] = importSignal(__, 'AccessLevel', access_level)
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
    %   t               - [num array] sample indices of the signal in the file
    %   t_unit          - [num array] timestamps in st_unit
    %
    % Note:
    %   Import data from one channel of MEF 3.0 file into MatLab.
    %
    % See also .

    % Copyright 2020-2025 Richard J. Cui. Created: Wed 02/05/2020 10:24:56.722 PM
    % $Revision: 0.4 $  $Date: Thu 09/11/2025 10:30:39.673 AM $
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
        st_unit (1, 1) string {mustBeMember(st_unit, {'index', 'uutc', 'second', 'minute', 'hour', 'day'})} = 'index' % unit of start_end
        filepath (1, :) char = '' % directory of the session
        filename (1, :) char = '' % filename of the channel
        options.Level1Password (1, :) char = '' % password of level 1
        options.Level2Password (1, :) char = '' % password of level 2
        options.AccessLevel (1, 1) double = NaN % data decode level to be used
    end % optional

    l1_pw = options.Level1Password;
    l2_pw = options.Level2Password;
    al = options.AccessLevel;

    % ======================================================================
    % main
    % ======================================================================
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
            se_yn = true(1, 2);
            se_uutc = this.SampleIndex2Time(se_index, 'uutc');
        otherwise
            [se_index, se_yn, se_uutc] = this.SampleTime2Index(start_end, st_unit);
    end % switch

    if isempty(start_end) == true
        [start_ind, start_yn, start_uutc] = this.SampleTime2Index(this.Channel.earliest_start_time);
        [end_ind, end_yn, end_uutc] = this.SampleTime2Index(this.Channel.latest_end_time);
        se_index = [start_ind, end_ind];
        se_yn = [start_yn, end_yn];
        se_uutc = [start_uutc, end_uutc];
    end % if

    % check
    if se_index(1) < 1
        se_index(1) = 1;
        warning('MultiscaleElectrophysiologyFile_3p0:ImportSignal:discardSample', ...
        'Reqested data samples before the recording are discarded')
        se_yn(1) = true;
        se_uutc(1) = this.Continuity.SampleTimeStart(1);
    end % if

    if se_index(2) > this.Channel.metadata.section_2.number_of_samples
        se_index(2) = this.Channel.metadata.section_2.number_of_samples;
        warning('MultiscaleElectrophysiologyFile_3p0:ImportSignal:discardSample', ...
        'Reqested data samples after the recording are discarded')
        se_yn(2) = true;
        se_uutc(2) = this.Continuity.SampleTimeEnd(end);
    end % if

    % find the indices corresponding to physically collected data
    se_index = adjust_se_index(this, se_index, se_yn, se_uutc);

    % verbose
    % -------
    num_samples = diff(start_end) + 1;

    if num_samples > 2 ^ 20
        verbo = true;
    else
        verbo = false;
    end % if

    % load the data
    % -------------
    if verbo
        [~, thisChannel] = fileparts(wholename);
        fprintf(['-->Loading ' thisChannel ' ...'])
        clear thisChannel
    end % if

    x = this.read_mef_ts_data_3p0(wholename, pw, 'samples', se_index(1), se_index(2));
    x = double(x(:)).'; % change to row vector

    % * TODO: add nan for missing data
    if nargout > 1
        t = se_index(1):se_index(2);
    end % if

    if nargout > 2
        t_unit_abs = this.SampleIndex2Time(t, st_unit);
        t_unit = this.abs2relativeTimePoint(t_unit_abs, st_unit);
    end % if

    if verbo, fprintf('Done!\n'), end % if

end

% ==========================================================================
% subroutines
% ==========================================================================
function se_out = adjust_se_index(this, se_in, se_yn, se_uutc)
    % adjust start and end index to physically collected data

    arguments
        this (1, 1) MultiscaleElectrophysiologyFile_3p0
        se_in(1, 2) double {mustStartLessThanOrEqualEnd} % [start, end] index of the signal to be extracted
        se_yn (1, 2) logical % whether the start and end index are adjusted
        se_uutc (1, 2) double % [start, end] time in uUTC
    end % arguments

    % get sample start and end indexes
    % --------------------------------
    cont = this.Continuity;

    if se_yn(1) == false
        % adjust the start index to the start of the previous block
        fprintf('Warning: the start time %d in uUTC is not available\n', se_uutc(1))
        blk_index = find(cont.SampleTimeStart <= se_uutc(1), 1, 'last');

        if isempty(blk_index)
            blk_index = 1;
        end % if

        se_in(1) = cont.SampleIndexStart(blk_index);

    end % if

    if se_yn(2) == false
        % adjust the end index to the end of the next block
        fprintf('Warning: the end time %d in uUTC is not available\n', se_uutc(2))
        blk_index = find(cont.SampleTimeEnd >= se_uutc(2), 1, 'first');

        if isempty(blk_index)
            blk_index = height(cont);
        end % if

        se_in(2) = cont.SampleIndexEnd(blk_index);

    end % if

    se_out = se_in;

end % function

function mustStartLessThanOrEqualEnd(x)

    if x(1) > x(2)
        error('The first element must be less than or equal to the second element.');
    end

end

% [EOF]
