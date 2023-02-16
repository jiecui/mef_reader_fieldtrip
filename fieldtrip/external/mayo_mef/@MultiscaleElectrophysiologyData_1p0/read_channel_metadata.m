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
    % $Revision: 0.1 $  $Date: Wed 02/15/2023 10:19:06.947 PM $
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
    s = read_MED(session_name, [], [], 1, 1, password, channel_name, false);
    chan_meta = s.channels.metadata;
    this.ChannelMetadata = chan_meta;

end % function read_channel_metadata

% [EOF]
