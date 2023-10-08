function varargout = project_setup(proj_root, options)
    % PROJECT_SETUP setup the project MED_FIELDTRIP
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

    % 2022 Richard J. Cui. Created: Sun 07/22/2023  4:04:40.660 PM
    % $Revision: 0.4 $  $Date: Sun 10/08/2023 10:48:26.588 AM $
    %
    % Rocky Creek Dr. NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % ======================================================================
    % parse inputs
    % ======================================================================
    arguments
        proj_root (1, :) char = pwd % project root directory (default: current directory)
    end % positional

    arguments
        options.CreateMselJson (1, 1) logical = false % create msel.json (default: false)
    end % optional

    % ======================================================================
    % main
    % ======================================================================
    % parameters
    % ----------
    creat_msel_json = options.CreateMselJson;

    % setup directories
    % -----------------
    fprintf('adding directories to project path...\n');
    cd(proj_root)
    addpath(genpath('./analysis'))
    addpath(genpath('../proj_util'))
    % * add fieldtrip
    % fprintf('adding fieldtrip root directory...\n')
    % ft_home = '../../../../ComputationalToolbox/neurophysiology_signals_analysis/fieldtrip';
    % addpath(ft_home)
    % ft_defaults

    % * add DHN
    cprintf('*blue', 'adding Dark hourse neuron...\n')
    dhn_root = '/Users/Jie/DHN';
    sys_loc = get_system_loc();

    switch sys_loc
        case "cortex"
            addpath(genpath(dhn_root))
        otherwise
            cprintf('[1 .5 0]', 'Warning: Dark hourse neuron is not known on %s.\n', sys_loc)
    end % switch

    % fuse the bucket if on GCP
    % -------------------------
    if sys_loc == "gcp"
        fprintf('setting external editor...\n')
        setenv('EDITOR', 'vim')

        fprintf('fusing GCP bucket...\n')
        % * check mouting point
        [status, cmdout] = system('ls ~/FuseMount');

        if status == 0 && isempty(cmdout) == true
            cmd = 'gcsfuse --implicit-dirs ml-8880-phi-shared-aif-us-p ~/FuseMount';

            if system(cmd) > 0
                cprintf([1 .5 0], 'Warning: fuse GCP bucket failed.\n');
            end % if

        else
            cprintf([1 .5 0], 'Warning: GCP bucket has been already fused or fusing is failed\n')
        end % if

    end % if

    % update MSEL dataset
    % -------------------
    fprintf('updating MSEL dataset...\n');
    data_loc = get_data_loc();
    md = MselDataset(DataLocation = data_loc, CreateMselJson = creat_msel_json);

    % output
    % ------
    fprintf('project setup complete!\n');

    if nargout > 0
        varargout{1} = md;
    end % if

end % function project_setup

% [EOF]
