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
    % $Revision: 0.3 $  $Date: Mon 09/11/2023 10:30:51.387 PM $
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
        ChannelName % channel names
        SamplingFrequency % in Hz
        Samples % number of samples
        DataBlocks % number of data blocks
        TimeGaps % number of discountinuity time gaps
        BeginStop % Begin and stop indexes of entire signal
        Unit % unit of BeginStop
        Institution % name of the institute
        SubjectID % identification of the subject
        AcquisitionSystem % name of the system to record the session
        CompressionAlgorithm % name of compression algorithm
        SessionInformation % table of session information (see get_sessinfo.m)
        SessionContinuity % [table] data segments of conituous sampling (see
        % analyzeContinuity.m for the detail)
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
