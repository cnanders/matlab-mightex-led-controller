classdef UniversalLedControllerVirtual < handle
    %UNIVERSALLEDCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        cMODE_TYPE_DISABLE = 'DISABLE'
        cMODE_TYPE_NORMAL = 'NORMAL'
        cMODE_TYPE_STROBE = 'STROBE'
        cMODE_TYPE_TRIGGER = 'TRIGGER'
    end
    
    properties (Access = public)
        
        
    end
    
    properties (Access = private)
        
        % {uint8 1x1} storage for working mode.  See cMODE_TYPE_*
        u8Mode = [1 1 1 1]
        dCurrentMax = [1000 1000 1000 1000];
        dCurrent = [810 820 830 840];
        
    end
    
    methods
        
        function this = UniversalLedControllerVirtual(varargin)
            
            % Initialize default path for dll and header files
                        
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}));
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
        end
        
       
        
        function init(this)
                                            
        end
        
        function echoOff(this)
            
            
        end
        
        
        % @param {uint8 1x1} u8Ch - channel e.g., 1, 2, 3, 4
        % @param {char 1xm} cModeType - see this.cMODE_TYPE_*
        function setWorkingMode(this, u8Ch, cModeType)
            
            switch cModeType
                case this.cMODE_TYPE_DISABLE
                    this.u8Mode(u8Ch) = 0;
                case this.cMODE_TYPE_NORMAL
                    this.u8Mode(u8Ch) = 1;
                case this.cMODE_TYPE_STROBE
                    this.u8Mode(u8Ch) = 2;
                case this.cMODE_TYPE_TRIGGER
                    this.u8Mode(u8Ch) = 3;
            end
               
            
            
        end
        
        % @param {uint8 1x1} u8Ch - channel e.g., 1, 2, 3, 4
        % @param {double 1x1} dCurrentMax - max current in mA [0 - 1000]
        % @param {double 1x1} dCurrent - working current in mA [0 - dCurrentMax]
        function setNormalModeCurrentMaxAndCurrent(this, u8Ch, dCurrentMax, dCurrent)
           
            this.dCurrentMax(u8Ch) = dCurrentMax;
            this.dCurrent(u8Ch) = dCurrent;
            
            
        end
        
        % @param {uint8 1x1} u8Ch - channel e.g., 1, 2, 3, 4
        % @param {double 1x1} dCurrent - current in mA [0 - 1000]
        function setNormalModeCurrent(this, u8Ch, dCurrent)
            this.dCurrent(u8Ch) = dCurrent;
        end
        
        function c = getDeviceInfo(this)
            c = 'mightex.UniversalLedControllerVirtual';
        end
        
        function d = getWorkingMode(this, u8Ch)
            d = this.u8Mode(u8Ch);
        end
        
        % Returns the normal mode Imax value of a channell 
        % @param {uint8 1x1} u8Ch - channel e.g., 1, 2, 3, 4
        % @return {double 1x1} 
        function d = getCurrentMaxNormalMode(this, u8Ch)
             d = this.dCurrentMax(u8Ch);
        end
        
        
        function d = getCurrentNormalModeCached(this, u8Ch)
            d = this.getCurrentNormalMode(u8Ch);
        end
        % Returns the normal mode current value of a channell 
        % @param {uint8 1x1} u8Ch - channel e.g., 1, 2, 3, 4
        % @return {double 1x1} 
        function d = getCurrentNormalMode(this, u8Ch)
             d = this.dCurrent(u8Ch);
        end
        
        
        function st = getChannelData(this, u8Ch)
            
            st = struct();
            st.Normal_CurrentMax = this.dCurrentMax(u8Ch);
            st.Normal_CurrentSet = this.dCurrent(u8Ch);
            st.Strobe_CurrentMax = 0;
            st.Strobe_RepeatCnt = 0;
            st.Strobe_Profile = 0;
            st.Trigger_CurrentMax = 0;
            st.Trigger_Polarity = 0;
            st.Trigger_Profile = 0; 
            st.Mode = this.u8Mode(u8Ch);
            
        end
        
        function disconnect(this)
            % TBD
        end
                
    end
    
    methods (Access = protected)
        
        
        function msg(this, cMsg)
            
        end
        
        function detectAvailableDevices(this)
            
            
        end
        
        function openDevice(this)
            
        end
        
        function l = hasProp(this, c)
            
            l = false;
            if ~isempty(findprop(this, c))
                l = true;
            end
            
        end
    end
    
end

