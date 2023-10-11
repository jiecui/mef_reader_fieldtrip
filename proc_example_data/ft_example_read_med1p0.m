% FT_EXAMPLE_READ_MED3P0 an example to read MED 3.0 data set into FieldTrip

%% set the parameters
clearvars

% look for session path of data
p = mfilename('fullpath');
sesspath = fullfile(fileparts(p), 'med_1p0', 'example_data.medd');

% set the password
password = struct('Level1Password', 'L1_password', 'Level2Password', ...
    'L2_password', 'AccessLevel', 2);

%% read the MED 1.0 data into MATLAB using class MEDFieldTrip_1p0

% get the object to read data into MATLAB
med_ft = MEDFieldTrip_1p0(sesspath, password);

% inspect the channels in the session
% note that the channel names are in alphabetic order, which is the default
% order
disp('Channel Names: ')
disp(med_ft.ChannelName)

% now let's import the the first 10 seconds data of two channels
% 'chan_0001' and 'chan_0002' into MATLAB
med_ft.SelectedChannel = ["chan_0001", "chan_0002"];
med_ft.StartEnd = [0 10]; % you can specify the number of samples too
% for examples [1 2561] or seconds [0 10]
med_ft.SEUnit = 'second'; % the unit for reading data can be 'index',
% 'second', 'uutc', 'minute', 'hour' and 'day'
[X, t] = med_ft.importSession;
fs = med_ft.SamplingFrequency;

figure
ph = plot(t / fs, X);
legend(ph, med_ft.SelectedChannel, 'Interpreter', 'none')
xlim([0, 1]) % zoom into the 1st second data
xlabel('Time (s)')
ylabel('Amplitude')
title('MED 1.0 data read by MEDFieldTrip_1p0', 'Interpreter', 'none')

%% read the MED 1.0 data using FieldTrip routines
% read data header with ft_read_header()
hdr = ft_read_header(sesspath, 'password', password);

% read data with ft_read_data() but specifying time interval using seconds
% Let's import 10 seconds data at the beginning of the recording
in_unit = 'second';
be_second = [0, 10]; % 10-second time of data from the start
out_unit = 'index';
be_sample = med_ft.SessionUnitConvert(be_second, InUnit = in_unit, OutUnit = out_unit);
dat = ft_read_data(sesspath, ...
    'begsample', be_sample(1), ...
    'endsample', be_sample(2), ...
    'header', hdr, ...
    'password', password, ...
    'chanindx', [1 2]); % the order of read data can be decided by
% key-value 'chanindx'

t = linspace(be_second(1), be_second(2), be_sample(2) - be_sample(1) + 1);
figure
plot(t, dat')
xlim([0 1] + be_second(1)) % zoom into the 1st second data
xlabel('Time (s)')
legend(hdr.label{1}, hdr.label{2}, 'interpreter', 'none')
title('MED 1.0 data read by ft_read_data()', 'Interpreter', 'none')

%% read data with ft_preprocessing()
% Let's import 5 trials/epochs. Each trial is 1.50 second long.  The
% trigger time of the 5 trials are at 0.5, 2.0, 3.5, 5.0 and 6.5 seconds,
% with the pre-stimulus length of 0.5 second.

% setup trial information
trig = [.5, 2, 3.5, 5, 6.5]; % in seconds
n_trig = length(trig); % number of triggers
trigger = med_ft.SessionUnitConvert(trig, InUnit = in_unit, OutUnit = out_unit)';
prestim = med_ft.SessionUnitConvert(.5, InUnit = in_unit, OutUnit = out_unit) * ones(n_trig, 1);
poststim = med_ft.SessionUnitConvert(1., InUnit = in_unit, OutUnit = out_unit) * ones(n_trig, 1);
trl = [trigger - prestim + 1, trigger + poststim, -prestim];

% read the data
cfg = [];
cfg.dataset = sesspath;
cfg.password = password;
cfg.header = hdr;
cfg.trl = trl;
dat_ieeg = ft_preprocessing(cfg);

% plot the data
cfg.viewmode = 'vertical';
brwview = ft_databrowser(cfg, dat_ieeg);

%% Copyright (c) 2020 MNL group
% Created on Sun 03/22/2020  9:03:27.318 PM
% Revision: 0.9  Date: Mon 10/09/2023 11:05:07.975 PM
%
% Multimodal Neuroimaging Lab (Dr. Dora Hermes)
% Mayo Clinic St. Mary Campus
% Rochester, MN 55905
%
% Email: richard.cui@utoronto.ca (permanent), Cui.Jie@mayo.edu (official)
