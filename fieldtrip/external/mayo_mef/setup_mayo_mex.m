function setup_mayo_mex(options)
    % SETUP_MAYO_MEX make mex binary necessary for reading MEF dataset
    %
    % Syntax:
    %   setup_mayo_mex()
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
    % See also make_mex_mef, test_mayo_mef.

    % Copyright 2020 Richard J. Cui. Created: Fri 05/15/2020 10:33:00.474 AM
    % $ Revision: 0.2 $  $ Date: Sun 01/29/2023  7:18:00.509 PM $
    %
    % Mayo Foundation for Medical Education and Research
    % Mayo Clinic St. Mary Campus
    % Rochester, MN 55905, USA
    %
    % Email: richard.cui@utoronto.ca (permanent), Cui.Jie@mayo.edu (official)

    % ======================================================================
    % parse inputs
    % ======================================================================
    arguments
    end % positional

    arguments
        options.DHNRootPath (1, 1) string = '' % full path to DHN root directory
        options.ForceBuildMex (1, 1) logical = false
    end % optional

    % ======================================================================
    % main
    % ======================================================================
    % parameters
    % ----------
    dhn_root = options.DHNRootPath; % if empty, use default root directory
    force_build_mex = options.ForceBuildMex;

    % * set default DHN root directory
    if isempty(dhn_root)

        switch computer
            case 'MACI64' % Mac
                user = getenv('USER');
                dhn_root = fullfile(filesep, 'Users', user, 'DHN');
            case 'GLNXA64' % Linux
                user = getenv('USER');
                dhn_root = fullfile(filesep, 'home', user, 'DHN');
            case 'PCWIN64' % Windows
                driver = getenv('HOMEDRIVE');
                user = getenv('HOMEPATH');
                dhn_root = fullfile(driver, user, 'DHN');
            otherwise
                ft_error('MAYO_MEF:setup_mayo_mex', ...
                    'Unknown computer type %s. MED is not supported.\n', ...
                    computer)
        end % switch

    end % if

    if isfolder(dhn_root)
        % add DHN root directory to MATLAB path
        addpath(genpath(dhn_root))
        med_mex_path = fullfile(dhn_root, 'read_MED', 'mex');
    else
        ft_warning('MAYO_MEF:setup_mayo_mex', ...
            'DHN root directory %s does not exist. please install read_MED package (http://darkhorseneuro.com) or manually set DHN root directory\n', dhn_root)
        med_mex_path = string(1, 0);
    end % if

    % get current directory
    % ---------------------
    cur_dir = pwd;

    % check MEF mex binary
    % --------------------
    fprintf('Setting up MEF mex binary...\n')

    % directory of setup_mayo_mex.m assumed in mayo_mef
    mayo_mef = fileparts(mfilename('fullpath'));

    if force_build_mex
        cd([mayo_mef, filesep, 'mex_mef'])
        make_mex_mef
    else % check mex files in mayo_mef
        valid_mex = check_mex_files(mayo_mef);

        if valid_mex == false
            cd([mayo_mef, filesep, 'mex_mef'])
            make_mex_mef
        end % if

    end % if

    % check MED mex binary
    % --------------------
    fprintf('Setting up MED mex binary...\n')

    % TODO: check if MED mex files are valid

    % return to original directory
    % ----------------------------
    cd(cur_dir)

end

% ==========================================================================
% subroutines
% ==========================================================================
function valid_mex = check_mex_files(mex_path)
    % SETUP_MAYO_MEX.CHECK_MEX_FILES check if mex files are valid

    arguments
        mex_path (1, 1) string % full path to mex files
    end % positional

end % function

% [EOF]
