classdef MultiscaleElectrophysiologyData < handle
    % Class MULTISCALEELECTROPHYSIOLOGYDATA process MED channel data

    % Copyright 2023 Richard J. Cui. Created: Mon 01/30/2023 10:01:06.104 PM
    % $Revision: 0.2 $  $Date: Thu 04/13/2023  1:00:43.288 AM $
    %
    % Rocky Creek Dr. NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % =====================================================================
    % properties
    % =====================================================================
    % MED information
    % ---------------
    properties (SetAccess = protected)
        MEDVersion (1, 1) double = NaN % MED version
        MPS = 1e6 % microseconds per seconds
        FilePath % [str] filepath of MED channel file
        FileName % [str] filename of MED channel file including ext
        ChanSamplingFreq % sampling frequency of channel (Hz)
        SampleTimeInterval % sample time interval = [lower, upper] (uUTC),
        % indicating the lower and upper bound of the time interval between
        % two successive samples
    end % properties

    % MED channel information
    % -----------------------
    properties (SetAccess = protected, Hidden = true)
    end % properties

    methods

        function this = MultiscaleElectrophysiologyData()

        end

    end % methods

    % other methods
    % -------------
    methods
        sti = getSampleTimeInterval(this, varargin) % bound of sampling interval
    end % methods

end % classdef

% [EOF]
