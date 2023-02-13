classdef MultiscaleElectrophysiologyData_1p0 < MultiscaleElectrophysiologyData
    % Class MULTISCALEELECTROPHYSIOLOGYDATA_1P0 process MED 1.0 channel data
    %
    % Syntax:
    %   this = MultiscaleElectrophysiologyDile_1p0();
    %   this = __(wholename);
    %   this = __(filepath, filename);
    %   this = __(__, 'Password', password);
    %
    % Input(s):
    %   wholename       - [char] (optional) session fullpath plus channel
    %                     name of MED file
    %   filepath        - [str] (optional) fullpath of session recorded in
    %                     MEF file
    %   filename        - [str] (optional) name of MEF channel file,
    %                     including ext
    %   password        - [char] (opt) password structure of MED 1.0 data (see
    %                     MEDSession_1p0)
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

    % Copyright 2023 Richard J. Cui. Created: Sun 02/12/2023 10:20:18.872 PM
    % $Revision: 0.1 $  $Date: Sun 02/12/2023 10:20:18.872 PM $
    %
    % Rocky Creek Dr. NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % =====================================================================
    % properties
    % =====================================================================
    % MED file info
    % -------------
    properties (SetAccess = protected, Hidden = true)
        Password (1, :) char = ''; % password to decrypt MED file
    end % properties

    % =====================================================================
    % methods
    % =====================================================================
    % the constructor
    % ----------------
    methods

        function this = MultiscaleElectrophysiologyData_1p0(file1st, file2nd, options)
            % constructor of class MultiscaleElectrophysiologyData_1p0
            % --------------------------------------------------------
            % * parse input
            arguments
                file1st (1, :) char = '';
                file2nd (1, :) char = '';
            end % positional

            arguments
                options.Password (1, :) char = '';
            end % optional

            if ~isempty(file1st)

                if isempty(file2nd)
                    [fp, fn, ext] = fileparts(file1st);
                    filepath = fp;
                    filename = [fn, ext];
                else
                    filepath = file1st;
                    filename = file2nd;
                end % if

            else
                filepath = '';
                filename = '';
            end % if

            % operations during construction
            % ------------------------------
            % * call superclass constructor(s)
            this@MultiscaleElectrophysiologyData();

            % * set and check MED version
            if this.MEDVersion == 0
                this.MEDVersion = 1.0;
            elseif this.MEDVersion ~= 1.0
                error('MultiscaleElectrophysiologyData_1p0:InvalidMEDVer', ...
                    'Invalid MED version %f. Can only handle 1.0.', this.MEDVersion);
            end % if

        end

    end % methods

end % classdef

% [EOF]
