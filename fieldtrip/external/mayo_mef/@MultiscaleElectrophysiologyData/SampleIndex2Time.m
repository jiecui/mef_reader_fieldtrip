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
    sample_time = zeros(size(sample_index));
    sample_yn = false(size(sample_index));
    [sorted_si, orig_idx] = sort(sample_index); % sort sample index

    if isempty(this.ContinuityCorrected)
        cont = this.analyzeContinuity;
    else
        cont = this.ContinuityCorrected;
    end % if

    fs = this.ChanSamplingFreq;

    [sorted_st, sorted_st_yn] = findSampleTime(fs, cont, fs, sorted_si); % TODO

    % convert to desired unit
    % -----------------------
    switch st_unit
        case 'uutc'
            sorted_sample_time = sorted_st;
        case 'msec'
            sorted_sample_time = sorted_st / 1e3;
        case 'second'
            sorted_sample_time = sorted_st / 1e6;
        case 'minute'
            sorted_sample_time = sorted_st / 1e6/60;
        case 'hour'
            sorted_sample_time = sorted_st / 1e6/3600;
        case 'day'
            sorted_sample_time = sorted_st / 1e6/3600/24;
    end % switch-case

    % output
    % ------
    sample_time(orig_idx) = sorted_sample_time;
    sample_yn(orig_idx) = sorted_st_yn;

end % function SampleIndex2Time

% ==========================================================================
% subroutines
% ==========================================================================


% [EOF]
