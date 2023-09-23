classdef MEDFieldTrip_1p0 < MEDSession_1p0 & MEDFieldTrip
    % Class MEDFIELDTRIP_1P0 processes MED 1.0 data using FieldTrip
    %
    % Syntax:
    %   this = MEDFieldTrip_1p0
    %   this = MEDFieldTrip_1p0(filename)
    %   this = MEDFieldTrip_1p0(__, password)
    %   this = MEDFieldTrip_1p0(__, 'SortChannel', sortchannel)
    %
    % Input(s):
    %   filename    - [char] (opt) session path or channel path or dataset name
    %   password    - [char] (opt) password (default: L2_password)
    %   sortchannel - [char] (para) sort channel according to either 'alphabet' of
    %                 the channel names or 'number' of the acquisiton
    %                 channel number (default = 'alphabet')

    % Copyright 2023 Richard J. Cui. Created: Sat 02/11/2023 10:24:32.031 PM
    % $Revision: 0.1 $  $Date: Sat 02/11/2023 10:24:32.043 PM $
    %
    % Rocky Creek Dr. NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % =====================================================================
    % properties
    % =====================================================================
    properties

    end % properties

    % =====================================================================
    % constructor
    % =====================================================================
    methods

        function this = MEDFieldTrip_1p0(varargin)

            % class constructor
            % =================
            % parse inputs
            % ------------

            % operations during construction
            % ------------------------------
            % call super class
            this@MEDFieldTrip; 
            this@MEDSession_1p0(varargin{:}); % TODO: this is not working yet

            % set class properties
            this.FileType = 'dhn_med10';
        end % constructor

    end % methods

    % =====================================================================
    % methods
    % =====================================================================
    methods (Static = true)

    end %

    % other methods
    % -------------
    methods
        hdr = getHeader(this, channames) % TODO: get header information of MED 1.0 session
        evt = getEvent(this, channames) % TODO: get MED 1.0 events for FieldTrip
        dat = getData(this, varargin) % TODO: read data from MED 1.0 dataset for FieldTrip
    end % methods

end % classdef

% [EOF]
