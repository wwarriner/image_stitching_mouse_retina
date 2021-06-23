classdef OutputFiles < handle
    methods
        function obj = OutputFiles(output_folder)
            obj.output_folder = output_folder;
        end
        
        function write_slo_image(obj, image, subject_name)
            parts = [string(subject_name) obj.SLO];
            file = obj.generate_file(obj.SLO, parts, ".tif");
            imwrite(image, file);
        end
        
        function write_slo_rgb_image(obj, image, subject_name)
            parts = [string(subject_name) obj.SLO obj.RGB];
            file = obj.generate_file(obj.SLO, parts, ".tif");
            imwrite(image, file);
        end
        
        function write_octa_image(obj, image, subject_name, image_index)
            parts = [string(subject_name) obj.OCTA num2str(image_index)];
            file = obj.generate_file(obj.OCTA, parts, ".tif");
            imwrite(image, file);
        end
        
        function write_octa_rgb_image(obj, image, subject_name, image_index)
            parts = [string(subject_name) obj.OCTA obj.RGB num2str(image_index)];
            sub = [obj.OCTA, obj.RGB];
            sub = strjoin(sub, "_");
            file = obj.generate_file(obj.RGB, parts, ".tif");
            imwrite(image, file);
        end
    end
    
    properties (Access = private)
        output_folder (1,1) string
    end
    
    properties (Access = private, Constant)
        SLO = "slo"
        OCTA = "octa"
        RGB = "rgb"
    end
    
    methods (Access = private)
        function file = generate_file(obj, subfolder, parts, ext)
            name = obj.generate_name(parts, ext);
            folder = fullfile(obj.output_folder, subfolder);
            [~, ~] = mkdir(folder);
            file = fullfile(folder, name);
        end
    end
    
    methods (Access = private, Static)
        function name = generate_name(parts, ext)
            assert(startsWith(ext, "."));
            name = strjoin(parts, "_");
            name = name + ext;
        end
    end
end

