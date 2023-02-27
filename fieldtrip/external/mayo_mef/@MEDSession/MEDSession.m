classdef MEDSession < handle
    % Class MEDSESSION processes MED session data.
    %
    % Syntax:
    %   this = MEDSession();
    %
    % Input(s):
    %
    % Output(s):
    %
    % See also .

    % Copyright 2023 Richard J. Cui. Created: Tue 02/21/2023 12:21:48.365 AM
    % $Revision: 0.2 $  $Date: Sun 02/26/2023 11:18:14.135 PM $
    %
    % Rocky Creek Dr. NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % =====================================================================
    % properties
    % =====================================================================
    % properties of importing session
    % -------------------------------
    properties
        SelectedChannel % channels selected
        StartEnd % start and end points to import the session
        SEUnit % unit of StartEnd
    end % properties

    % properties of session information
    % ---------------------------------
    properties
        SessionPath % session directory
        Password % password structure of the session
    end % properties

    % =====================================================================
    % methods
    % =====================================================================
    % the constructor
    methods

        function this = MEDSession()

        end

    end % methods

    % other methods
    % -------------
    methods
        varargout = get_sessinfo(this) % get sess info from data
        [path_to_sess, sess_name, sess_ext] = get_sess_parts(this, varargin) % get the parts of session path
    end % methods

end % classdef

% [EOF]
