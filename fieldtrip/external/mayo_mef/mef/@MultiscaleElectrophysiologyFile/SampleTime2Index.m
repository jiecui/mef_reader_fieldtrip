function [sample_index, sample_yn, sample_time] = SampleTime2Index(this, sample_time, st_unit)
    % MULTISCALEELECTROPHYSIOLOGYFILE.SAMPLETIME2INDEX Convert sample time to sample index
    %
    % Syntax:
    %   [sample_index, sample_yn] = SampleTime2Index(this, sample_time)
    %   [sample_index, sample_yn] = SampleTime2Index(__, st_unit)
    %
    % Input(s):
    %   this            - [obj] MultiscaleElectrophysiologyFile object
    %   sample_time     - [num array] array of sample time (default unit uUTC)
    %   st_unit         - [str] (optional) sample time unit: 'uUTC' (default)
    %                     or 'u', 'mSec', 'Second' or 's', 'Minute' or 'm', 'Hour' or
    %                     'h' and 'Day' or 'd'.
    %
    % Output(s):
    %   sample_index    - [num array] sample indices corresponding to sample
    %                     time
    %   sample_yn       - [logical array] true: this sample index corresponding
    %                     to physically collected data
    %
    % Note:
    %
    % See also SampleIndex2Time.

    % Copyright 2019-2025 Richard J. Cui. Created: Sun 05/05/2019 10:29:21.071 PM
    % $Revision: 0.8 $  $Date: Wed 09/10/2025 14:09:13.683 PM $
    %
    % 1026 Rocky Creek Dr NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % ======================================================================
    % parse inputs
    % ======================================================================
    arguments
        this (1, 1) MultiscaleElectrophysiologyFile
        sample_time (1, :) {mustBeNonempty, mustBeReal, mustBeFinite} % sample time (default unit uUTC)
        st_unit (1, 1) string {mustBeMember(st_unit, ...
                                   {'uutc', 'msec', 'second', 'minute', 'hour', 'day'})} = 'uutc'
    end % positional

    % ======================================================================
    % main
    % ======================================================================
    % convert to uUTC
    % ---------------
    switch lower(st_unit) % convert to uUTC
        case 'msec'
            sample_time = round(sample_time * 1e3);
        case 'second'
            sample_time = round(sample_time * 1e6);
        case 'minute'
            sample_time = round(sample_time * 60 * 1e6);
        case 'hour'
            sample_time = round(sample_time * 60 * 60 * 1e6);
        case 'day'
            sample_time = round(sample_time * 24 * 60 * 60 * 1e6);
    end % switch

    % set paras
    % ----------
    sample_index = zeros(size(sample_time));
    sample_yn = false(size(sample_time));
    [sorted_st, orig_index] = sort(sample_time);

    if isempty(this.Continuity)
        cont = this.analyzeContinuity;
    else
        cont = this.Continuity;
    end % if

    % within continuous segment
    % -------------------------
    time_se = cont{:, {'SampleTimeStart', 'SampleTimeEnd'}};
    sample_se = cont{:, {'SampleIndexStart', 'SampleIndexEnd'}};

    % choose continuity segment that in the range of sample indices
    num_st = numel(sorted_st);
    sel_cont_ind = sorted_st(1) <= time_se(:, 2) ...
        & sorted_st(num_st) >= time_se(:, 1);
    % range of sorted_si
    sel_time_se = time_se(sel_cont_ind, :);
    sel_sample_se = sample_se(sel_cont_ind, :);
    [sorted_sample_index, sorted_sample_yn] = inContLoopCont(sel_time_se, ...
        sel_sample_se, sorted_st);

    % output
    % ------
    sample_index(orig_index) = sorted_sample_index;
    sample_yn(orig_index) = sorted_sample_yn;

end

% ==========================================================================
% subroutines
% ==========================================================================
function [s_index, s_yn] = inContLoopCont(time_se, sample_se, sorted_st)

    arguments
        time_se (:, 2) double % start and end time in uUTC
        sample_se (:, 2) double % start and end sample index
        sorted_st (:, 1) double % sorted sample time in uUTC
    end % positional

    num_st = numel(sorted_st);
    num_blk = size(time_se, 1);
    s_index = nan(1, num_st);
    s_yn = false(1, num_st);

    for j = 1:num_st

        st_j = sorted_st(j);

        for k = 1:num_blk
            time_start_k = time_se(k, 1);
            time_end_k = time_se(k, 2);

            if st_j >= time_start_k && st_j <= time_end_k
                s_jk = interp1(time_se(k, :), sample_se(k, :), st_j, "linear");
                s_jk = round(s_jk);
                s_index(j) = s_jk;
                s_yn(j) = true;
            end % if

        end % for

    end % for

end % function

% [EOF]
