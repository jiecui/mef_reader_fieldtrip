classdef MultiscaleElectrophysiologyData < handle
    % Class MULTISCALEELECTROPHYSIOLOGYDATA process MED channel data

    % Copyright 2023 Richard J. Cui. Created: Mon 01/30/2023 10:01:06.104 PM
    % $Revision: 0.1 $  $Date: Mon 01/30/2023 10:01:06.111 PM $
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
        MEDVersion (1, 1) double {mustBeNonnegative, mustBeFinite} = 0.0 % MED version
    end % properties

    % MED channel information
    % -----------------------
    properties

    end % properties

    methods

        function this = MultiscaleElectrophysiologyData()

        end

    end % methods

end % classdef

% [EOF]
