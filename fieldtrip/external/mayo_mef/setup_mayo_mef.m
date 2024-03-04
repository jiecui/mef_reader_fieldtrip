% startup script to add the required path (without the potential overkill of using genpath),
% and execute the setup of the mex files

p = mfilename('fullpath');
[p, f, e] = fileparts(p);
addpath(p);
addpath(fullfile(p, 'med'));
addpath(fullfile(p, 'mef'));

p = which('read_MED.m');
[p, f, e] = fileparts(p);
if endsWith(p, 'read_MED')
  % this is conform a DarkHorseNeuro install, as per its install.sh file,
  % which is expected to be the folder organization according to setup_mayo_mex.m
  DHNRootPath = p(1:end-8);
  setup_mayo_mex('DHNRootPath', DHNRootPath);
else 
  error('read_MED should be on the MATLAB path, and installed according to https://darkhorseneuro.com');
end

