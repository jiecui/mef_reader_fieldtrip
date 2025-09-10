classdef MultiscaleElectrophysiologyFile_3p0 < MultiscaleElectrophysiologyFile
    % Class MultiscaleElectrophysiologyFile_3p0 process MEF 3.0 channel data
    %
    % Syntax:
    %   this = MultiscaleElectrophysiologyFile_3p0;
    %   this = __(wholename);
    %   this = __(filepath, filename);
    %   this = __(__, 'Level1Password', level_1_pw);
    %   this = __(__, 'Level2Password', level_2_pw);
    %   this = __(__, 'AccessLevel', access_level);
    %
    % Input(s):
    %   wholename       - [str] (optional) session fullpath plus channel
    %                     name of MEF file
    %   filepath        - [str] (optional) fullpath of session recorded in
    %                     MEF file
    %   filename        - [str] (optional) name of MEF channel file,
    %                     including ext
    %   level_1_pw      - [str] (para) password of level 1 (default = '')
    %   level_2_pw      - [str] (para) password of level 2 (default = '')
    %   access_level    - [str] (para) data decode level to be used
    %                     (default = 1)
    %
    % Output(s):
    %   this            - [obj] MultiscaleElectrophysiologyFile_3p0 object
    %
    % Note:
    %   This class processes a signal channel of data recorded in MEF
    %   ver 3.0 format.
    %
    % See also .

    % Copyright 2020-2025 Richard J. Cui. Created: Tue 02/04/2020  2:21:31.965 PM
    % $Revision: 0.6 $  $Date: Wed 09/10/2025 10:18:31.653 AM $
    %
    % 1026 Rocky Creek Dr NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % =====================================================================
    % properties
    % =====================================================================
    % MEF file info
    % -------------
    properties (SetAccess = protected, Hidden = true)
        Level1Password (1, :) char % [str] level 1 password
        Level2Password (1, :) char % [str] level 2 password
        AccessLevel (1, 1) double % [num] access level of data
        Channel (1, 1) struct % [struct] channel information structure
    end

    % ======================================================================
    % methods
    % ======================================================================
    % the constructor
    % ----------------
    methods

        function this = MultiscaleElectrophysiologyFile_3p0(file1st, file2nd, options)
            % construct MultiscaleElectrophysiologyFile_3p0 object
            % ====================================================
            % parse inputs
            % ------------
            arguments
                file1st (1, :) char = '' % fullpath+filename or filepath
                file2nd (1, :) char = '' % filename if file1st is filepath
                options.Level1Password (1, :) char = '' % level 1 password
                options.Level2Password (1, :) char = '' % level 2 password
                options.AccessLevel (1, 1) double {mustBeMember(options.AccessLevel, [1, 2])} = 1 % access level
                options.Channel (1, 1) struct = struct() % channel info
            end % optional

            level1_pw = options.Level1Password;
            level2_pw = options.Level2Password;
            access_level = options.AccessLevel;
            channel = options.Channel;

            % operations during construction
            % ------------------------------
            % (1) call superclass constructors
            this@MultiscaleElectrophysiologyFile;

            % (2) set and check MEF version
            if isempty(this.MEFVersion) == true
                this.MEFVersion = 3.0;
            elseif this.MEFVersion ~= 3.0
                error('MultiscaleElectrophysiologyFiel_3p0:invalidMEFVer', ...
                'invalid MEF version; this function can serve only MEF 3.0')
            end % if

            % (3) set channel info
            if ~isempty(file1st)

                if isempty(file2nd)
                    [f_path, fn, ext] = fileparts(file1st);
                    f_name = [fn, ext];
                else
                    f_path = file1st;
                    f_name = file2nd;
                end

                this.FilePath = f_path;
                this.FileName = f_name;
                this.Level1Password = level1_pw;
                this.Level2Password = level2_pw;
                this.AccessLevel = access_level;

                % read header
                switch this.AccessLevel
                    case 1
                        password = this.Level1Password;
                    case 2
                        password = this.Level2Password;
                end % switch

                wholename = fullfile(this.FilePath, this.FileName);

                if exist(wholename, 'file') ~= 7
                    error('MultiscaleElectrophysiology_3p0:invalidChannel', ...
                        'cannot find channel %s', wholename)
                end % if

                % read header
                if isfield(channel, 'header') == false || isempty(fieldnames(channel))
                    [header, channel] = this.readHeader(wholename, password, this.AccessLevel);
                    this.Header = header;
                    this.Channel = channel;
                else
                    this.Header = channel.header;
                    this.Channel = channel;
                end % if

                % check version
                mef_ver = sprintf('%d.%d', this.Header.mef_version_major, ...
                    this.Header.mef_version_minor);

                if str2double(mef_ver) ~= this.MEFVersion
                    warning('The MEF file is compressed with MEF format version %s, rather than %0.1f. The results may be unpredictable', ...
                        mef_ver, this.MEFVersion)
                    warning('test %s', mef_ver)
                end % if

                % (3) set sampling information
                this.ChanSamplingFreq = channel.metadata.section_2.sampling_frequency;
                this.getSampleTimeInterval;
            end % if

        end % function

    end

    % other metheds
    % -------------
    methods
        [header, channel] = readHeader(this, varargin) % read universal head and channel metadata of MEF 3.0
        bid = readBlockIndexData(this, varargin) % read block indices
        seg_cont = analyzeContinuity(this, varargin) % analyze continuity of data sampling
        [x, t] = importSignal(this, varargin) % input MEF 3.0 time series channel
        data = read_mef_ts_data_3p0(this, channel_path, varargin) % lower level of inputing channel data
        pw = processPassword(this, varargin) % process MEF 3.0 password
    end % methods

end

% [EOF]
