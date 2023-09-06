function [sess_info, unit] = get_info_data(this)
    % MEDSESSION_1P0.GET_INFO_DATA get session info from data
    %
    % Syntax:
    %   [sessionifo, unit] = get_info_data(this)
    %
    % Input(s):
    %   sess_info       - [table] N x 16 tabel: 'ChannelName', 'SamplingFreq',
    %                     'Begin', 'Stop', 'Samples' 'IndexEntry',
    %                     'DiscountinuityEntry', 'SubjectEncryption',
    %                     'SessionEncryption', 'DataEncryption', 'Version',
    %                     'Institution', 'SubjectID', 'AcquistitionSystem',
    %                     'CompressionAlgorithm', 'Continuity', where N is the
    %                     number of channels.
    %   unit            - [str] unit of begin_stop: 'Index' (default), 'uUTC',
    %                     'Second', 'Minute', 'Hour', and 'Day'
    %
    % Output(s):
    %
    % Example:
    %
    % Note:
    %
    % References:
    %
    % See also .

    % Copyright 2023 Richard J. Cui. Created: Tue 02/21/2023 11:27:28.805 PM
    % $Revision: 0.1 $  $Date: Wed 09/06/2023 12:02:05.569 AM $
    %
    % Rocky Creek Dr. NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % ======================================================================
    % parse inputs
    % ======================================================================
    arguments
        this (1, 1) MEDSession_1p0
    end % positional

    % =========================================================================
    % main
    % =========================================================================
    var_names = {'ChannelName', 'SamplingFreq', 'Begin', 'Stop', 'Samples', ...
                     'IndexEntry', 'DiscountinuityEntry', 'SubjectEncryption', ...
                     'SessionEncryption', 'DataEncryption', 'Version', 'Institution', ...
                     'SubjectID', 'AcquisitionSystem', 'CompressionAlgorithm', 'Continuity'};
    var_types = {'string', 'double', 'double', 'double', 'double', 'double', ...
                     'double', 'logical', 'logical', 'logical', 'string', 'string', 'string', ...
                     'string', 'string', 'cell'};

    % get the meta data
    % -----------------
    metadata = this.MetaData;

    if isempty(metadata) == true % no metadata
        metadata = this.read_med_session_metadata_1p0();
        this.MetaData = metadata;
    end % if

    % get session info
    % ----------------
    chan_names = metadata.channel_name;
    num_chan = length(chan_names);

    if num_chan < 1 % no time series channel
        sess_info = table;
        unit = '';
    else % if
        unit = 'uUTC';
        sz = [num_chan, numel(var_names)]; % size of the table of session info
        fp = this.SessionPath; % session path of channels
        pw = this.processPassword(this.Password); % password
        sess_info = table('size', sz, 'VariableTypes', var_types, ...
            'VariableNames', var_names);

        for k = 1:num_chan
            chan_name_k = chan_names(k);
            fn_k = chan_name_k + ".ticd";
            info_k = MED_session_stats(fullfile(fp, fn_k), true, true, true, pw); % get info of channel 

            % assign values
            sess_info.ChannelName(k) = chan_name_k;
        end % for

        % TODO
    end % if

end % function get_info_data

% [EOF]
