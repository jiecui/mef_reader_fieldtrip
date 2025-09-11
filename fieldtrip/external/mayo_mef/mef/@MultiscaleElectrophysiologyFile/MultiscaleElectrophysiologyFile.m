classdef MultiscaleElectrophysiologyFile < handle
    % Class MULTISCALEELECTROPHYSIOLOGYFILE process MEF channel data
    %
    % Syntax:
    %   this = MultiscaleElectrophysiologyFile;
    %
    % Input(s):
    %
    % Output(s):
    %
    % Note:
    %
    % See also .

    % Copyright 2020-2025 Richard J. Cui. Created: Tue 02/04/2020  2:21:31.965 PM
    % $Revision: 0.6 $  $Date: Thu 09/11/2025 09:23:05.190 AM $
    %
    % Rocky Creek Dr NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.jie.cui@gmail.com

    % ======================================================================
    % properties
    % ======================================================================
    % MEF information
    % ---------------
    properties (SetAccess = protected)
        MEFVersion = [] % MEF version to serve, can be set only in
        % constructor
        MPS = 1e6 % microseconds per seconds
    end %  properties: protected

    % MEF channel info
    % ----------------
    properties (SetAccess = protected, Hidden = true)
        FilePath % [str] filepath of MEF channel file
        FileName % [str] filename of MEF channel file including ext
        Header % [struct] header information of MEF file
        BlockIndexData % [table] data of block indices (see
        % readBlockIndexData.m for the detail)
        Continuity % [table] data segments of conituous sampling (see
        % analyzeContinuity.m for the detail)
        ChanSamplingFreq % sampling frequency of channel (Hz)
        SampleTimeInterval % sample time interval = [lower, upper] (uUTC),
        % indicating the lower and upper bound of the
        % time interval between two successive samples
    end % properties: protected, hidden

    properties
    end % properties

    % ======================================================================
    % methods
    % ======================================================================
    % the constructor
    % ----------------
    methods

        function this = MultiscaleElectrophysiologyFile()

        end % function

    end

    % other metheds
    % -------------
    methods
        varargout = getSampleTimeInterval(this, varargin) % bound of sampling interval
        varargout = SampleTime2Index(this, varargin) % time --> index
        varargout = SampleIndex2Time(this, varargin) % index --> time
        varargout = setContinuity(this, varargin) % set Continuity table
        varargout = SampleUnitConvert(this, varargin) % convert units of time points
        varargout = getRecordOffset(this, varargin) % get offset time of recording in specified unit
    end % methods

end

% [EOF]
