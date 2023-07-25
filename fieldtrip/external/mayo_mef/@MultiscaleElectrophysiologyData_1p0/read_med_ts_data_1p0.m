function data = read_med_ts_data_1p0(this, channel_path, options)
    % MULTISCALEELECTROPHYSIOLOGYDATA_1P0.READ_MED_TS_DATA_1P0 read the MED 1.0 data from a time-series channel
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

    % Copyright 2023 Richard J. Cui. Created: Sat 07/22/2023 10:51:35.758 PM
    % $Revision: 0.1 $  $Date: Sat 07/22/2023 10:51:35.762 PM $
    %
    % Rocky Creek Dr. NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % ======================================================================
    % parse inputs
    % ======================================================================
    arguments
        this (1, 1) multiscaleElectrophysiologyData_1p0
        channel_path (1, 1) string {mustBeNonzeroLengthText} % the path to the channel
    end % positional

    arguments
        options.Password (1, 1) string = "" % the password to the file
        options.range_type (1, 1) string {mustBeMember(options.range_type, ["time", "index"])} = "index" % the range type
        options.begin (1, 1) double
        options.stop (1, 1) double
    end % optional

    pw = options.Password;
    range_type = options.range_type;
    begin = options.begin;
    stop = options.stop;

    % ======================================================================
    % main
    % ======================================================================

end % function read_med_ts_data_1p0

% [EOF]
