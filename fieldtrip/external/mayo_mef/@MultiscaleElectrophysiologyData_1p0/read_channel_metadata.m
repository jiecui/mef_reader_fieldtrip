function chan_meta = read_channel_metadata(this, wholename, password)
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
    % $Revision: 0.2 $  $Date: Thu 04/13/2023 12:11:12.194 AM $
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

    % ======================================================================
    % main
    % ======================================================================
    % get seesion and channel names
    % -----------------------------
    [session_name, channel_name] = fileparts(wholename);

    % get channel metadata
    % --------------------
    % get session metadata
    s = read_MED(session_name, [], [], [], [], password, channel_name, false);

    % get channel metadata
    chan_meta = struct();
    chan_meta.records = s.records;

    n_chan = length(s.channels);

    for k = 1:n_chan
        chan_k = s.channels(k);
        chan_name_k = chan_k.metadata.channel_name;

        if strcmpi(chan_name_k, channel_name)
            chan_meta.metadata = chan_k.metadata;
            chan_meta.contigua = chan_k.contigua;
            break
        end % if

    end % for

    this.ChannelMetadata = chan_meta;

end % function read_channel_metadata

% [EOF]
