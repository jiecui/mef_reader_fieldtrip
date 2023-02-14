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
    %   password    - [char] (opt) password structure of MED 1.0 data (see
    %                 MEDSession_1p0)
    %   sortchannel - [char] (para) sort channel according to either 'alphabet' of
    %                 the channel names or 'number' of the acquisiton
    %                 channel number (default = 'alphabet')
    %
    % Output(s):
    %   this        - [obj] MEFDession_1p0 object
    %
    % See also get_sessinfo.

    % Copyright 2023 Richard J. Cui. Created: Sun 02/12/2023  9:10:13.351 PM
    % $Revision: 0.1 $  $Date: Sun 02/12/2023  9:10:13.352 PM $
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
                password (1, :) char = 'L2_password' % example_data password =='L1_password' or 'L2_password'
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

        end

    end % methods

    % static methods
    % -------------
    methods (Static)

    end % methods

    % other methods
    % -------------
    methods
    end % methods

end % classdef

% [EOF]
