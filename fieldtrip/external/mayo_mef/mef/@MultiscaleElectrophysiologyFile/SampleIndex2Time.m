function [sample_time, sample_yn] = SampleIndex2Time(this, sample_index, st_unit)
    % MULTISCALEELECTROPHYSIOLOGYFILE.SAMPLEINDEX2TIME Convert sample index to sample time
    %
    % Syntax
    %   [sample_time, sample_yn] = SampleIndex2Time(this, sample_index)
    %   [sample_time, sample_yn] = SampleIndex2Time(__, st_unit)
    %
    % Input(s):
    %   this            - [obj] MultiscaleElectrophysiologyFile object
    %   sample_index    - [num array] array of sample index (must be integers)
    %   st_unit         - [str] (optional) sample time unit: 'uUTC' (default)
    %                     or 'u', 'mSec', 'Second' or 's', 'Minute' or 'm', 'Hour' or
    %                     'h' and 'Day' or 'd'.
    %
    % Output(s):
    %   sample_time     - [num array] sample time corresponding to sample
    %                     indices (default unit: uUTC)
    %   sample_yn       - [logical array] true: this sample time corresponding
    %                     to physically collected data
    %
    % Note:
    %   An error less than one sample time may occure.
    %
    % See also SampleTime2Index.

    % Copyright 2019-2025 Richard J. Cui. Created: Mon 05/06/2019  9:29:08.940 PM
    % $Revision: 1.2 $  $Date: Thu 09/11/2025 09:23:05.190 AM $
    %
    % Rocky Creek Dr NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.jie.cui@gmail.com

    % ======================================================================
    % parse inputs
    % ======================================================================
    arguments
        this (1, 1) MultiscaleElectrophysiologyFile
        sample_index (1, :) {mustBeInteger, mustBeNonempty} % sample index (must be integers)
        st_unit (1, 1) string {mustBeMember(st_unit, ...
                                   {'uutc', 'msec', 'second', 'minute', 'hour', 'day'})} = 'uutc'
    end % positional

    % ======================================================================
    % main
    % ======================================================================
    % set paras
    % ----------
    sample_time = zeros(size(sample_index));
    sample_yn = false(size(sample_index));
    [sorted_si, orig_index] = sort(sample_index);
    cont = this.SessionContinuity;

    % get sample uUTC timepoints
    % --------------------------
    x = [cont.SampleIndexStart; cont.SampleIndexEnd];
    y = [cont.SampleTimeStart; cont.SampleTimeEnd];
    [x, ind] = sort(x);
    y = y(ind);
    t_uutc = interp1(x, y, sorted_si, 'linear', 'extrap');
    t_uutc = round(t_uutc); % round to the nearest uUTC

    % if valid
    % --------
    sorted_sample_yn = false(size(sorted_si));
    sorted_sample_yn(sorted_si >= min(x) & sorted_si <= max(x)) = true;

    % time
    % ----
    switch lower(st_unit)
        case 'msec'
            sorted_sample_time = t_uutc / 1e3;
        case 'second'
            sorted_sample_time = t_uutc / 1e6;
        case 'minute'
            sorted_sample_time = t_uutc / (60 * 1e6);
        case 'hour'
            sorted_sample_time = t_uutc / (60 * 60 * 1e6);
        case 'day'
            sorted_sample_time = t_uutc / (24 * 60 * 60 * 1e6);
        case 'uutc'
            sorted_sample_time = t_uutc;
    end % switch

    % output
    % ------
    sample_time(orig_index) = sorted_sample_time;
    sample_yn(orig_index) = sorted_sample_yn;

end

% =========================================================================
% subroutines
% =========================================================================

% [EOF]
