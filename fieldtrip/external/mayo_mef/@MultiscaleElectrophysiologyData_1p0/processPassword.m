function pw = processPassword(this, password, options)
    % MULTISCALEELECTROPHYSIOLOGYDATA_1P0.PROCESSPASSWORD process password of MED 1.0 data
    %
    % Syntax:
    %   pw = processPassword(this)
    %   pw = __(__, password)
    %   pw = __(__, 'Level1Password', level_1_pw)
    %   pw = __(__, 'Level2Password', level_2_pw)
    %   pw = __(__, 'AccessLevel', access_level)
    %
    % Input(s):
    %   this            - [obj] MultiscaleElectrophysiologyFile_3p0 object
    %   password        - [struct] (opt) password structure
    %                     .Level1Password
    %                     .Level2Password
    %                     .AccessLevel
    %   level_1_pw      - [str] (para) password of level 1 (default = '')
    %   level_2_pw      - [str] (para) password of level 2 (default = '')
    %   access_level    - [str] (para) data decode level to be used
    %                     (default = 1)
    %
    %
    % Output(s):
    %   pw              - [str] password at the selected level
    %
    % Example:
    %
    % Note:
    %   if 'password' is provided, the options will be ignored.
    %
    % References:
    %
    % See also .

    % Copyright 2023 Richard J. Cui. Created: Thu 03/02/2023 12:38:04.168 AM
    % $Revision: 0.1 $  $Date: Thu 03/02/2023 12:38:04.175 AM $
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
        password (1, 1) struct = struct('Level1Password', '', ...
            'Level2Password', '', 'AccessLevel', 1)
    end % positional

    arguments
        options.level_1_pw (1, 1) string = ''
        options.level_2_pw (1, 1) string = ''
        options.access_level (1, 1) string = '1'
    end % optional

    % ======================================================================
    % main
    % ======================================================================
    
end % function processPassword

% [EOF]
