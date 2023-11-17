classdef ftUnit
    
    properties
        ftHW
        ftCW
        ftFreq
    end
    
    methods
        
        function obj = set.ftHW(obj,ftHW)
            obj.ftHW = ftHW(:);
        end
        
        function obj = set.ftCW(obj,ftCW)
            obj.ftCW = ftCW(:);
        end
        
        function obj = set.ftFreq(obj,ftFreq)
            obj.ftFreq = ftFreq(:);
        end
        
    end
    
end

