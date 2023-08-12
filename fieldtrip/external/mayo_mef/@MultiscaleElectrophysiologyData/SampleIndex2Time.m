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
    % $Revision: 0.2 $  $Date: Sat 08/12/2023 12:08:22.300 AM $
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

    [sorted_st, sorted_st_yn] = findSampleTime(fs, cont, sorted_si); % TODO

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
function [sample_time, sample_yn] = findSampleTime(fs, cont, sample_index)
    % FINDSAMPLETIME find sample time from sample index

    arguments
        fs (1, 1) double % sampling frequency
        cont (:, :) table % continuity table
        sample_index (:, 1) double
    end % positional

    % set parameters
    % --------------
    num_si = numel(sample_index);
    sample_time = zeros(size(sample_index));
    sample_yn = false(size(sample_index));

    % find sample time
    % ----------------
    % find sample time for each sample index
    for k = 1:num_si
        % find the continuity table row that contains the sample index
        idx_k = cont.start_index <= sample_index(k) & cont.end_index >= sample_index(k);
        cont_row = cont(idx_k, :);

        if isempty(cont_row)
            sample_time(k) = NaN;
            sample_yn(k) = false;
            continue
        end % if

        % find the sample index in the continuity table
        delta_microsec = (sample_index(k) - cont_row.start_index) * 1e6 / fs;
        sample_time(k) = cont_row.start_time + delta_microsec;
        sample_yn(k) = true;
    end % for

end % function findSampleTime

% [EOF]
