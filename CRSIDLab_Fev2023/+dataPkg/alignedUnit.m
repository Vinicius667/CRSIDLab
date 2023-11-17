classdef alignedUnit < dataPkg.dataUnit
    properties
        psd = dataPkg.psdUnit;
        tvpsd = dataPkg.tvpsdUnit;
    end
    methods
        function obj = set.psd(obj,psd)
            if isa(psd,'dataPkg.psdUnit')
                obj.psd = psd;
            else
                error('psd must be a psdUnit object (dataPkg.psdUnit)')
            end
        end
        function obj = set.tvpsd(obj,tvpsd)
            if isa(tvpsd,'dataPkg.tvpsdUnit')
                obj.tvpsd = tvpsd;
            else
                error('tvpsd must be a tvpsdUnit object (dataPkg.tvpsdUnit)')
            end
        end
    end
end