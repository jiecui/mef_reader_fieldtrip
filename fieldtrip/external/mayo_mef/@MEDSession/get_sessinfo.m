function varargout = get_sessinfo(this)
    % MEDSESSION.GET_SESSINFO get session information from MED data
    %
    % Syntax:
    %   [channame, start_end, unit, sess_info] = get_sessinfo(this)
    %
    % Input(s):
    %   this            - [obj] MEDSession object
    %
    % Output(s):
    %   channame        - [string] the name(s) of the data channel in the
    %                     directory of session.
    %   begin_stop      - [1 x 2 array] [begin time/index, stop time/index] of
    %                     the entire signal
    %   unit            - [str] unit of begin_stop: 'Index' (default), 'uUTC',
    %                     'Second', 'Minute', 'Hour', and 'Day'
    %   sess_info       - [table] N x 13 tabel: 'ChannelName', 'SamplingFreq',
    %                     'Begin', 'Stop', 'Samples' 'IndexEntry',
    %                     'DiscountinuityEntry', 'SubjectEncryption',
    %                     'SessionEncryption', 'DataEncryption', 'Version',
    %                     'Institution', 'SubjectID', 'AcquistitionSystem',
    %                     'CompressionAlgorithm', where N is the number of
    %                     channels.
    %
    % Example:
    %
    % Note:
    %
    % References:
    %
    % See also MEDSession_1p0, get_info_data.

    % Copyright 2023 Richard J. Cui. Created: Tue 02/21/2023 11:21:04.215 PM
    % $Revision: 0.1 $  $Date: Tue 02/21/2023 11:21:04.228 PM $
    %
    % Rocky Creek Dr. NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % =========================================================================
    % Main process
    % =========================================================================
    % table of channel info
    % ---------------------
    [sess_info, unit] = this.get_info_data;
    % TODO
end % function get_sessinfo

% [EOF]
