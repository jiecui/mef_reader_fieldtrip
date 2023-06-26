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
    % $Revision: 0.2 $  $Date: Fri 05/05/2023 12:44:41.427 AM $
    %
    % Rocky Creek Dr. NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % ======================================================================
    % parse inputs
    % ======================================================================
    arguments
        this (1, 1) MultiscaleElectrophysiologyData_1p0
    end % positional

    % ======================================================================
    % main
    % ======================================================================
    meta_data = this.ChannelMetadata;

    % get the continuity table
    % ------------------------
    seg_cont = struct2table(meta_data.contigua);
    seg_cont.start_time_string = string(seg_cont.start_time_string);
    seg_cont.end_time_string = string(seg_cont.end_time_string);

    % TODO: correct end_time for an approimate uniform sampling rate of each segment
    % ------------------------------------------------------------------------------
    % seg_cont.end_time = seg_cont.start_time + ...
    %     (seg_cont.end_index - seg_cont.start_index) * 1e6 / meta_data.sampling_rate;

    % update
    % -------
    this.Continuity = seg_cont;

end % function analyzeContinuity

% [EOF]
