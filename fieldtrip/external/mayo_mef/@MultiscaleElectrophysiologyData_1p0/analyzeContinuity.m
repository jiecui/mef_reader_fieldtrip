function seg_cont = analyzeContinuity(this)
    % MULTISCALEELECTROPHYSIOLOGYDATA_1P0.ANALYZECONTINUITY (summary)
    %
    % Syntax:
    %
    % Input(s):
    %   this            - [obj] MultiscaleElectrophysiologyData_1p0 object
    %
    % Output(s):
    %   seg_cont        - [table] N x 6, information of segments of continuity
    %                     of sampling in the data file.  The 6 variable names
    %                     are:
    %                     start_index       : [num] sample index of data segment start
    %                     end_index         : [num] sample index of data segment end
    %                     start_time        : [num] sample time of data segment start (in uUTC)
    %                     start_time_string : [string] sample time of data segment start (in string)
    %                     end_time          : [num] sample time of data segment end (in uUTC)
    %                     end_time_string   : [string] sample time of data segment end (in string)
    %
    % Example:
    %
    % Note:
    %
    % References:
    %
    % See also .

    % Copyright 2023 Richard J. Cui. Created: Fri 04/14/2023 12:11:12.027 AM
    % $Revision: 0.1 $  $Date: Fri 04/14/2023 12:11:12.033 AM $
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
    end % positional

    % ======================================================================
    % main
    % ======================================================================
    meta_data = this.ChannelMetaData;

    % get the continuity table
    % ------------------------
    seg_cont = struct2table(meta_data.contigua);
    seg_cont.start_time_string = string(seg_cont.start_time_string);
    seg_cont.end_time_string = string(seg_cont.end_time_string);

    % update
    % -------
    this.Continuity = seg_cont;

end % function analyzeContinuity

% [EOF]
