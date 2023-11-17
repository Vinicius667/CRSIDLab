classdef patientData
    properties
        info = dataPkg.patientInfo;
        sig = dataPkg.patientSig;
        sys = struct;
        tvsys = struct;
    end
    methods
        function obj = set.info(obj,info)
            if isa(info,'dataPkg.patientInfo')
                obj.info = info;
            else
                error('info must be a patientInfo object (dataPkg.patientInfo)')
            end
        end
        function obj = set.sig(obj,sig)
            if isa(sig,'dataPkg.patientSig')
                obj.sig = sig;
            else
                error('sig must be a patientSig object (dataPkg.patientSig)')
            end
        end
        function obj = set.sys(obj,sys)
            varName = fieldnames(sys);
            for i = 1:length(varName)
                if ~isa(sys.(varName{i}),'dataPkg.patientSys')
                    error(['sys must be a struct and all fields must be'...
                        ' patientSys data objects.'])
                end
            end
            obj.sys = sys;
        end
        function obj = set.tvsys(obj,tvsys)
            varName = fieldnames(tvsys);
            for i = 1:length(varName)
                if ~isa(tvsys.(varName{i}),'dataPkg.patientSys')
                    error(['tvsys must be a struct and all fields must be'...
                        ' patientSys data objects.'])
                end
            end
            obj.tvsys = tvsys;
        end
    end
end