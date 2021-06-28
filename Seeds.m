classdef Seeds < handle
    methods
        function obj = Seeds(file_path)
            t = readtable(file_path);
            m = containers.Map();
            for i = 1 : height(t)
                m(char(t{i, 1})) = t{i, 2};
            end
            obj.map = m;
        end
        
        function seed = get(obj, subject_name)
            seed = obj.map(subject_name);
        end
    end
    
    properties (Access = private)
        map containers.Map
    end
end

