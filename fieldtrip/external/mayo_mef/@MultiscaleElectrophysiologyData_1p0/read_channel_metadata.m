function chan_meta = read_channel_metadata(this, wholename, password, options)
    % MULTISCALEELECTROPHYSIOLOGYDATA_1P0.READ_CHANNEL_METADATA get channel metadata
    %
    % Syntax:
    %
    % Input(s):
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

    % Copyright 2023 Richard J. Cui. Created: Wed 02/15/2023 10:19:06.942 PM
    % $Revision: 0.3 $  $Date: Thu 05/04/2023 12:28:55.508 AM $
    %
    % Rocky Creek Dr. NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % ======================================================================
    % parse inputs
    % ======================================================================
    arguments
        this (1, 1) MultiscaleElectrophysiologyData_1p0
        wholename (1, :) char
        password (1, :) char
    end % positional

    arguments
        options.ReturnChannels (1, 1) logical = false
        options.ReturnContigua (1, 1) logical = true
        options.ReturnRecords (1, 1) logical = true
    end % optional

    % ======================================================================
    % main
    % ======================================================================
    % get channel metadata
    % --------------------
    return_channels = options.ReturnChannels;
    return_contigua = options.ReturnContigua;
    return_records = options.ReturnRecords;

    chan_meta = MED_session_stats(wholename, return_channels, ...
        return_contigua, return_records, password);
    chan_meta = rmfield(chan_meta, 'channels');

    this.ChannelMetadata = chan_meta;

end % function read_channel_metadata

% [EOF]
