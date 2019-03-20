cDir = fileparts(mfilename('fullpath'));
addpath(fullfile(cDir, '..', 'src'));

comm = mightex.UniversalLedController(...
    'u8DeviceIndex', uint8(0) ...
);
comm.init();

comm.getNormalModeParameters(2)

comm.getCurrentWorkingMode(1)
comm.getCurrentWorkingMode(2)
comm.getCurrentWorkingMode(4)


tic
st = comm.getChannelData(4)
toc



% tic
% st = comm.getChannelData(2)
% toc


tic
comm.setNormalModeCurrent(3, 400);
toc

return;

%comm.setNormalModeCurrentMaxAndCurrent(3, 500, 50);
%comm.setNormalModeCurrentMaxAndCurrent(4, 800, 50);
%comm.setWorkingMode(3, comm.cMODE_TYPE_NORMAL);

st = comm.getChannelData(3)
st = comm.getChannelData(4)