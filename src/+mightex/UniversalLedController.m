classdef UniversalLedController < handle
    %UNIVERSALLEDCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        cMODE_TYPE_DISABLE = 'DISABLE'
        cMODE_TYPE_NORMAL = 'NORMAL'
        cMODE_TYPE_STROBE = 'STROBE'
        cMODE_TYPE_TRIGGER = 'TRIGGER'
    end
    
    properties (Access = public)
        cNameOfLib
        cPathDll
        cPathHeader
        u8DeviceIndex = uint8(0)
        hDevice % handle of the device
        
        % Storage for cached values of current.  When NaN, need to update
        % cache
        dCurrentCache = nan(1, 4);
        
    end
    
    methods
        
        function this = UniversalLedController(varargin)
            
            % Initialize default path for dll and header files
            
            
            this.setDefaultPathOfDllAndHeader();
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}));
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
        end
        
        
        
        
        
        function init(this)
                            
                
            if ~libisloaded(this.cNameOfLib)
                loadlibrary(...
                    this.cPathDll, ...
                    this.cPathHeader ...
                );
            end
            
            % Detect the number of Mightex Devices
            
            this.detectAvailableDevices()
            this.openDevice(); 
            this.echoOff();
            
        end
        
        function echoOff(this)
            
            cCmd = 'ECHOOFF';
            
            u8Response = calllib(...
                this.cNameOfLib, ...
                'MTUSB_LEDDriverSendCommand', ...
                this.hDevice, ...
                cCmd ...
            );
            
        end
        
        
        
        
        % @param {uint8 1x1} u8Ch - channel e.g., 1, 2, 3, 4
        % @param {char 1xm} cModeType - see this.cMODE_TYPE_*
        function setWorkingMode(this, u8Ch, cModeType)
            
            switch cModeType
                case this.cMODE_TYPE_DISABLE
                    u8Mode = 0;
                case this.cMODE_TYPE_NORMAL
                    u8Mode = 1;
                case this.cMODE_TYPE_STROBE
                    u8Mode = 2;
                case this.cMODE_TYPE_TRIGGER
                    u8Mode = 3;
            end
               
            cCmd = sprintf('MODE %1.0f %1.0f', u8Ch, u8Mode);
            this.sendCmd(cCmd);
            
        end
        
        % @param {uint8 1x1} u8Ch - channel e.g., 1, 2, 3, 4
        % @param {double 1x1} dCurrentMax - max current in mA [0 - 1000]
        % @param {double 1x1} dCurrent - working current in mA [0 - dCurrentMax]
        function setNormalModeCurrentMaxAndCurrent(this, u8Ch, dCurrentMax, dCurrent)
           
            this.dCurrentCache(u8Ch) = NaN; % bust cache
            cCmd = sprintf(...
                'NORMAL %1.0f %1.0f %1.0f', ...
                u8Ch, ...
                dCurrentMax, ...
                dCurrent...
            );
            this.sendCmd(cCmd);
        end
        
        % @param {uint8 1x1} u8Ch - channel e.g., 1, 2, 3, 4
        % @param {double 1x1} dCurrent - current in mA [0 - 1000]
        function setNormalModeCurrent(this, u8Ch, dCurrent)
            
            this.dCurrentCache(u8Ch) = NaN; % bust cache
            cCmd = sprintf(...
                'CURRENT %1.0f %1.0f', ...
                u8Ch, ...
                dCurrent...
            );
            this.sendCmd(cCmd);
        end
        
        function c = getDeviceInfo(this)
            
            
            c = calllib(...
                this.cNameOfLib, ...
                'MTUSB_LEDDriverSendCommand', ...
                this.hDevice, ...
                'DEVICEINFO' ...
            );
            
            
        end
        
        function d = getWorkingMode(this, u8Ch)
            
            cCmd = sprintf(...
                '?MODE %1.0d', ...
                u8Ch ...
            );
            cResponse = calllib(...
                this.cNameOfLib, ...
                'MTUSB_LEDDriverSendCommand', ...
                this.hDevice, ...
                cCmd ...
            )
                    
            
        end
        
        % Returns the normal mode Imax value of a channell 
        % @param {uint8 1x1} u8Ch - channel e.g., 1, 2, 3, 4
        % @return {double 1x1} 
        function d = getCurrentMaxNormalMode(this, u8Ch)
             d = calllib(...
                this.cNameOfLib, ...
                'MTUSB_LEDDriverGetChannelNormalIMAX', ...
                this.hDevice, ...
                uint8(u8Ch) ...
            );
        end
        
        
        function d = getCurrentNormalModeCached(this, u8Ch)
            
            % Update cache if necessary
            if isnan(this.dCurrentCache(u8Ch))
                this.dCurrentCache(u8Ch) = this.getCurrentNormalMode(u8Ch);
                fprintf(...
                    'mightex.UniversalLedController updating current cache of channel %d to %1.3f\n', ...
                    u8Ch, ...
                    this.dCurrentCache(u8Ch) ...
                );
                    
            end
            
            d = this.dCurrentCache(u8Ch);
            
        end
        % Returns the normal mode current value of a channell 
        % @param {uint8 1x1} u8Ch - channel e.g., 1, 2, 3, 4
        % @return {double 1x1} 
        function d = getCurrentNormalMode(this, u8Ch)
            
             % Per Alex Jansen from Mightex instructinos, 
             % need to call the getCurrentMaxNormalMode 
             % first.  I think it writes a value to memory on the hardware
             % that the GetChannelNormalISET function reads
             
             d = this.getCurrentMaxNormalMode(u8Ch);
             d = calllib(...
                this.cNameOfLib, ...
                'MTUSB_LEDDriverGetChannelNormalISET', ...
                this.hDevice, ...
                uint8(u8Ch) ...
            );
        end
        
        %{
        function [dCurrentMax, dCurrentSet] = getNormalModeParameters(this, u8Ch)
            
            
            cCmd = sprintf(...
                '?CURRENT %1.0d', ...
                u8Ch ...
            );
            cResponse = calllib(...
                this.cNameOfLib, ...
                'MTUSB_LEDDriverSendCommand', ...
                this.hDevice, ...
                cCmd ...
            )
            
            dCurrentMax = 0;
            dCurrentSet = 0;
            
        end
        %}
        
        
        
        function st = getChannelData(this, u8Ch)
            
            % This one is a tricky because you have to pass in
            % pointers that are modified by the function call.
            %
            % One pointer is of C type int, which is MATLAB type int32
            %
            % The other pointer is of type TLedChannelData, which is a
            % C struct type defined in the header file. Need to use
            % libstruct() to generate the pointer of a C-defined type
            
            % Pointer for mode to be filled by command.  Be careful here
            % becasus need to use get() on the pointer to read its value.
            % Make sure to read the docs on libpointer if you are not
            % familiar with it.

            ptrMode = libpointer('int32Ptr', 1);
            %fprintf('Output of get(ptrMode) ******\n');
            %get(ptrMode)

            strobeProfilePtr = libpointer('int32Ptr', zeros(128, 2));
            triggerProfilePtr = libpointer('int32Ptr', zeros(128, 2));

            % Pointer of type TLedChannelData to be filled by command
            stDefault.Normal_CurrentMax = int32(0);
            stDefault.Normal_CurrentSet = int32(0);
            stDefault.Strobe_CurrentMax = int32(0);
            stDefault.Strobe_RepeatCnt = int32(0);
            stDefault.Strobe_Profile = int32(ones(128, 2)); % strobeProfilePtr;
            stDefault.Trigger_CurrentMax = int32(0);
            stDefault.Trigger_Polarity = int32(0);
            stDefault.Trigger_Profile = int32(ones(128, 2)); % triggerProfilePtr; 

            ptrTLedChannelData = libstruct('TLedChannelData', stDefault);
            
            % DISPLAY FOR DEBUGGING ONLY
            %fprintf('Output of get(sc) ***** \n');
            %get(ptrTLedChannelData)

            dTic = tic;
            u8Out = calllib(...
                this.cNameOfLib, ...
                'MTUSB_LEDDriverGetCurrentPara', ...
                this.hDevice, ...
                u8Ch, ...
                ptrTLedChannelData, ...
                ptrMode ...
            );
            dToc = toc(dTic);
            fprintf('+mightex/UniversalLedController calllib %1.1f ms\n', dToc * 1000);
            
            st.Normal_CurrentMax = ptrTLedChannelData.Normal_CurrentMax;
            st.Normal_CurrentSet = ptrTLedChannelData.Normal_CurrentSet;
            st.Strobe_CurrentMax = ptrTLedChannelData.Strobe_CurrentMax;
            st.Strobe_RepeatCnt = ptrTLedChannelData.Strobe_RepeatCnt;
            st.Strobe_Profile = ptrTLedChannelData.Strobe_Profile;
            st.Trigger_CurrentMax = ptrTLedChannelData.Trigger_CurrentMax;
            st.Trigger_Polarity = ptrTLedChannelData.Trigger_Polarity;
            st.Trigger_Profile = ptrTLedChannelData.Trigger_Profile; 
            st.Mode = ptrMode.Value;
            
        end
        
        function disconnect(this)
            % TBD
        end
                
    end
    
    methods (Access = protected)
        
        function msg(this, cMsg)
            fprintf('+mightex/UniversalLedController %s\n', cMsg);
        end
        
        
        function sendCmd(this, cCmd)
            u8Out = calllib(this.cNameOfLib, 'MTUSB_LEDDriverSendCommand', this.hDevice, cCmd);
            if u8Out == -1
                cMsg = sprintf('sendCmd(%s) ERROR', cCmd);
                this.msg(cMsg);
            else
                cMsg = sprintf('sendCmd(%s) success', cCmd);
                this.msg(cMsg);
            end
        end
        
        function setDefaultPathOfDllAndHeader(this)
            
            cDir = fileparts(mfilename('fullpath'));
            cDirSdk = fullfile(cDir, '..', '..', 'sdk');
            cArch = computer('arch');
            
            switch cArch
                case 'win32'
                    this.cNameOfLib = 'Mightex_LEDDriver_SDK';
                    this.cPathDll = fullfile(cDirSdk, 'lib', 'Mightex_LEDDriver_SDK.dll');
                    this.cPathHeader = fullfile(cDirSdk, 'lib', 'Mightex_LEDDriver_SDK.h');
                case 'win64'
                    
                    
                    % this.cNameOfLib = 'Mightex_LEDDriver_SDK';
                    % this.cPathDll = fullfile(cDirSdk, 'x64_lib', 'Mightex_LEDDriver_SDK.dll');
                    
                    this.cNameOfLib = 'Mightex_LEDDriver_SDK_Stdcall';
                    this.cPathDll = fullfile(cDirSdk, 'x64_lib', 'Mightex_LEDDriver_SDK_Stdcall.dll');
                    this.cPathHeader = fullfile(cDirSdk, 'x64_lib', 'Mightex_LEDDriver_SDK_c_compatible.h');
                    
                otherwise
                    % Assume 32-bit
                    this.cNameOfLib = 'Mightex_LEDDriver_SDK';
                    this.cPathDll = fullfile(cDirSdk, 'lib', 'Mightex_LEDDriver_SDK.dll');
                    this.cPathHeader = fullfile(cDirSdk, 'lib', 'Mightex_LEDDriver_SDK.h');
            end
           
            
            
        end
        
        function detectAvailableDevices(this)
            
            dNum = calllib(...
                this.cNameOfLib, ...
                'MTUSB_LEDDriverInitDevices' ...
            );
            if(dNum == 0)
                this.msg('no devices detected.');
                return;
            else
                this.msg(sprintf('detected %1.0f device(s).', dNum));
            end
        end
        
        function openDevice(this)
            this.hDevice = calllib(...
                this.cNameOfLib, ...
                'MTUSB_LEDDriverOpenDevice', ...
                this.u8DeviceIndex ...
            );
            if this.hDevice == -1
                this.msg('error opening device.');
                return;
            else
                this.msg('device opened successfully.');
            end
        end
        
        function l = hasProp(this, c)
            
            l = false;
            if ~isempty(findprop(this, c))
                l = true;
            end
            
        end
    end
    
end

