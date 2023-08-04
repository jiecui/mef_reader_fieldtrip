function [sample_time, sample_yn] = SampleIndex2Time(this, sample_index, options)
    % MULTISCALEELECTROPHYSILOGYDATA.SAMPLEINDEX2TIME convert sample index to sample time
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

    % Copyright 2023 Richard J. Cui. Created: Tue 08/01/2023 11:35:13.940 PM
    % $Revision: 0.1 $  $Date: Tue 08/01/2023 11:35:13.946 PM $
    %
    % Rocky Creek Dr. NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % ======================================================================
    % parse inputs
    % ======================================================================
    arguments
        this (1, 1) MultiScaleElectrophysiologyData
        sample_index (:, 1) double
    end % positional

    arguments
        options.st_unit (1, :) char ...
            {mustBeMember(options.st_unit, {'uutc', 'msec', 'second', 'minute', 'hour', 'day'})} = 'uutc'
    end % name-value

    st_unit = options.st_unit;

    % ======================================================================
    % main
    % ======================================================================
    % set parameters
    % --------------
    sample_time=zeros(size(sample_index));
    sample_yn = false(size(sample_index));


end % function SampleIndex2Time

% [EOF]
