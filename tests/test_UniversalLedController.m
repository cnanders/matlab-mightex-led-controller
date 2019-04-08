cDir = fileparts(mfilename('fullpath'));
addpath(fullfile(cDir, '..', 'src'));

comm = mightex.UniversalLedController(...
    'u8DeviceIndex', uint8(0) ...
);
comm.init();

tic
comm.getCurrentMaxNormalMode(1)
comm.getCurrentMaxNormalMode(2)
comm.getCurrentMaxNormalMode(3)
comm.getCurrentMaxNormalMode(4)
toc

tic
comm.getCurrentNormalMode(1)
comm.getCurrentNormalMode(2)
comm.getCurrentNormalMode(3)
comm.getCurrentNormalMode(4)
toc


% comm.getNormalModeParameters(2)

%{
tic
comm.setNormalModeCurrentMaxAndCurrent(1, 950, 850);
comm.setNormalModeCurrentMaxAndCurrent(2, 960, 860);
comm.setNormalModeCurrentMaxAndCurrent(3, 970, 870);
comm.setNormalModeCurrentMaxAndCurrent(4, 980, 880);
toc


%comm.setNormalModeCurrentMaxAndCurrent(3, 500, 50);
%comm.setNormalModeCurrentMaxAndCurrent(4, 800, 50);
%comm.setWorkingMode(3, comm.cMODE_TYPE_NORMAL);

st = comm.getChannelData(1)
st = comm.getChannelData(2)
st = comm.getChannelData(3)
st = comm.getChannelData(4)
%}