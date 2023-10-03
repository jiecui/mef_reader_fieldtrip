function hdr = getHeader(this, channames)
    % MEDFIELDTRIP_1P0.GETHEADER get header information of MED 1.0 session for fieldtrip
    %
    % Syntax:
    %   hdr = getHeader(this)
    %   hdr = getHeader(this, channames)
    %
    % Input(s):
    %   this            - [obj] MEDFieldTrip_1p0 object
    %   channames       - [string] channel names
    %
    % Output(s):
    %   hdr             - [struct] structure of header information (from
    %                     session metadata information)
    %
    % Example:
    %
    % Note:
    %
    % References:
    %
    % See also .

    % Copyright 2023 Richard J. Cui. Created: Mon 10/02/2023 12:43:05.396 AM
    % $Revision: 0.1 $  $Date: Mon 10/02/2023 12:43:05.469 AM $
    %
    % Rocky Creek Dr. NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % ======================================================================
    % parse inputs
    % ======================================================================
    arguments
        this (1, 1) MEDFieldTrip_1p0
        channames (1, :) string = []
    end % positional

    % ======================================================================
    % main
    % ======================================================================
    % check channel names if provided
    % -------------------------------
    if ~isempty(channames)
        sess_chan = this.ChannelName; % all channels in the session

        if all(ismember(channames, sess_chan)) == false
            error('MEFFieldTrip_3p0:getHeader:invalidChannel', ...
            'invalid channel names')
        end % if

    end % if

    % construct header structure
    % --------------------------
end % function getHeader

% [EOF]
