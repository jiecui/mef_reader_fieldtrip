classdef MEDSession_1p0 < MEDSession & MultiscaleElectrophysiologyData_1p0
    % Class MEDSESSION_1P0 processes MED 1.0 data.
    %
    % Syntax:
    %   this = MEFSession_3p0
    %   this = __(filename)
    %   this = __(filename, password)
    %   this = __(__, 'SortChannel', sortchannel)
    %
    % Input(s):
    %   filename    - [char] (opt) MED 1.0 session path, channel or data file
    %                 (default = '')
    %   password    - [struct] (opt) structure of MED 1.0 passowrd (default
    %                 = struct('Level1Password', '', 'Level2Password', '',...
    %                 'AccessLevel', 1);)
    %                 .Level1Password (default = '')
    %                 .Level2Password (default = '')
    %                 .AccessLevel (default = 1)
    %   sortchannel - [char] (para) sort channel according to either 'alphabet' of
    %                 the channel names or 'number' of the acquisiton
    %                 channel number (default = 'alphabet')
    %
    % Output(s):
    %   this        - [obj] MEFDession_1p0 object
    %
    % See also get_sessinfo.

    % Copyright 2023 Richard J. Cui. Created: Sun 02/12/2023  9:10:13.351 PM
    % $Revision: 0.2 $  $Date: Sun 02/26/2023 11:18:14.135 PM $
    %
    % Rocky Creek Dr. NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % =====================================================================
    % properties
    % =====================================================================
    properties
        MetaData % metadata structure of the session
        PathToSession % not include session name and extension
        SessionName % not include extension
        SessionExt % session extension (includes the '.')
    end % properties

    % =====================================================================
    % methods
    % =====================================================================
    % the constructor
    % ----------------
    methods

        function this = MEDSession_1p0(filename, password, sortchannel)
            % MEFSession_3p0 Construct an instance of this class
            % ==================================================
            % parse inputs
            % -------------
            arguments
                filename (1, :) char
                password (1, 1) struct = struct('Level1Password', '', 'Level2Password', '', ...
                    'AccessLevel', 1) % example_data password =='L1_password' or 'L2_password'
                sortchannel (1, 1) string = "alphabet"
            end % positional

            % operations during construction
            % ------------------------------
            this@MEDSession();
            this@MultiscaleElectrophysiologyData_1p0();

            % * set MEF version to serve
            if isnan(this.MEDVersion) == true
                this.MEDVersion = 1.0;
            elseif this.MEDVersion ~= 1.0
                error('MEDSession_3p0:invalidMEDVer', ...
                'invalid MED version; this function can serve only MED 1.0')
            end % if

            % * set session information
            [sesspath, channames] = this.findSessPath(filename);

            if ~isempty(sesspath)
                this.setSessionInfo(sesspath, password, sortchannel);
            end % if

            if ~isempty(channames) && numel(channames) == 1
                this.SelectedChannel = channames;
            else
                this.SelectedChannel = this.ChannelName;
            end % if

        end

    end % methods

    % static methods
    % -------------
    methods (Static)

    end % methods

    % other methods
    % -------------
    methods
        [sesspath, channames] = findSessPath(this, filename) % find session path and channel name
        metadata = setSessionInfo(this, varargin) % set session information
        metadata = read_med_session_metadata_1p0(this, varargin) % get session metadata of MED 1.0
    end % methods

end % classdef

% [EOF]
