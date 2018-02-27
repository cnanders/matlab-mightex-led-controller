cDir = fileparts(mfilename('fullpath'));
addpath(fullfile(cDir, '..', 'src'));

comm = mightex.UniversalLedController();
comm.init();
st = comm.getChannelData(1)
st = comm.getChannelData(2)

comm.setNormalModeCurrent(3, 400);

%comm.setNormalModeCurrentMaxAndCurrent(3, 500, 50);
%comm.setNormalModeCurrentMaxAndCurrent(4, 800, 50);
%comm.setWorkingMode(3, comm.cMODE_TYPE_NORMAL);

st = comm.getChannelData(3);
st = comm.getChannelData(4);