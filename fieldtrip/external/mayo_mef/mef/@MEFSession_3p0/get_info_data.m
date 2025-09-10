function [sess_info, unit] = get_info_data(this)
    % MEFSESSION_3P0.GET_INFO_DATA get sesion information from data
    %
    % Syntax:
    %   [sessionifo, unit] = get_info_data(this)
    %
    % Input(s):
    %   this            - [obj] MEFSession_3p0 object
    %
    % Output(s):
    %   unit            - [str] unit of begin_stop: 'Index' (default), 'uUTC',
    %                     'Second', 'Minute', 'Hour', and 'Day'
    %   sess_info       - [table] N x 14 tabel: 'ChannelName', 'SamplingFreq',
    %                     'Begin', 'Stop', 'Samples' 'IndexEntry',
    %                     'DiscountinuityEntry', 'SubjectEncryption',
    %                     'SessionEncryption', 'DataEncryption', 'Version',
    %                     'Institution', 'SubjectID', 'AcquistitionSystem',
    %                     'CompressionAlgorithm', 'Continuity', where N is the
    %                     number of channels.
    %
    % Example:
    %
    % Note:
    %   This function obtains information about the session from the data
    %   directly.  Other information, such as session directory and password,
    %   should be provided via MEFSession_3p0 object.
    %
    % References:
    %
    % See also MEFSession_3p0, get_sessinfo.

    % Copyright 2020-2025 Richard J. Cui. Created: Fri 01/03/2020  4:19:10.683 PM
    % $ Revision: 0.5 $  $ Date: Tue 09/09/2025 14:30:50.888 PM $
    %
    % 1026 Rocky Creek Dr NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

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

    % get the metadata
    metadata = this.MetaData;

    if isempty(metadata)
        fprintf('Reading session metadata... ');
        metadata = this.read_mef_session_metadata_3p0(this.SessionPath);
        metadata = get_header_info(this, metadata); % TODO: get header info
        this.MetaData = metadata;
        fprintf('Done.\n');
    end % if

    num_chan = metadata.number_of_time_series_channels; % number of channels

    if num_chan < 1 % no time series channel
        sess_info = table;
        unit = '';
    else % if
        unit = 'uUTC';
        sz = [num_chan, numel(var_names)];
        fp = this.SessionPath; % session path of channels
        ts_channel = metadata.time_series_channels; % structure of time-series channel
        sess_info = table('size', sz, 'VariableTypes', var_types, ...
            'VariableNames', var_names);

        fprintf('Reading information of %d channels... ', num_chan);

        for k = 1:num_chan
            fprintf('%d ', k);
            tsc_k = ts_channel(k); % kth channel of time series
            fn_k = [tsc_k.name, '.', tsc_k.extension]; % channel name
            % header info
            header_k = tsc_k.header;
            mef_ver = sprintf('%d.%d', header_k.mef_version_major, ...
                header_k.mef_version_minor);
            % analysis discountinuity
            ch3_k = MultiscaleElectrophysiologyFile_3p0(fp, fn_k, ...
                'Level1Password', this.Password.Level1Password, ...
                'Level2Password', this.Password.Level2Password, ...
                'AccessLevel', this.Password.AccessLevel);
            seg_cont_k = ch3_k.analyzeContinuity;

            sess_info.ChannelName(k) = tsc_k.name;
            sess_info.SamplingFreq(k) = tsc_k.metadata.section_2.sampling_frequency;
            sess_info.Begin(k) = tsc_k.earliest_start_time;
            sess_info.Stop(k) = tsc_k.latest_end_time;
            sess_info.Samples(k) = tsc_k.metadata.section_2.number_of_samples;
            % number of data blocks in each channel
            sess_info.IndexEntry(k) = tsc_k.metadata.section_2.number_of_blocks;

            sess_info.DiscountinuityEntry(k) = height(seg_cont_k);

            % TODO: NA in MEF 3.0
            sess_info.SubjectEncryption(k) = false;
            sess_info.SessionEncryption(k) = false;
            sess_info.DataEncryption(k) = false;

            sess_info.Version(k) = mef_ver;
            sess_info.Institution(k) = tsc_k.metadata.section_3.recording_location;
            sess_info.SubjectID(k) = tsc_k.metadata.section_3.subject_ID;

            % TODO: NA in MEF 3.0
            sess_info.AcquisitionSystem(k) = 'not available';
            sess_info.CompressionAlgorithm(k) = 'not available';

            % continuity table
            sess_info.Continuity{k} = seg_cont_k;
        end % for

        fprintf('Done.\n');

    end % if

end

% ==========================================================================
% subroutines
% ==========================================================================
function metadata = get_header_info(this, metadata)
    % get header info

    arguments
        this (1, 1) MEFSession_3p0
        metadata (1, 1) struct
    end % arguments

    fp = this.SessionPath; % session path of channels
    pw = this.processPassword(this.Password); % password
    ts_channel = metadata.time_series_channels; % structure of time-series channel
    ch_names = {ts_channel.name}; % channel names

    for k = 1:numel(ch_names)
        fn_k = [ch_names{k}, '.', ts_channel(k).extension]; % channel name
        header_k = this.readHeader(fullfile(fp, fn_k), pw);
        metadata.time_series_channels(k).header = header_k;
    end % for

end % function

% [EOF]
