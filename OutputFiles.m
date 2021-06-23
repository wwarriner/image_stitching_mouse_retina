classdef OutputFiles < handle
    methods
        function obj = OutputFiles(output_folder)
            obj.output_folder = output_folder;
        end
        
        function write_slo_image(obj, image, subject_name)
            parts = [string(subject_name) "slo"];
            file = obj.generate_file(parts, ".tif");
            imwrite(image, file);
        end
        
        function write_slo_rgb_image(obj, image, subject_name)
            parts = [string(subject_name) "slo" "rgb"];
            file = obj.generate_file(parts, ".tif");
            imwrite(image, file);
        end
        
        function write_octa_image(obj, image, subject_name, image_index)
            parts = [string(subject_name) "octa" num2str(image_index)];
            file = obj.generate_file(parts, ".tif");
            imwrite(image, file);
        end
        
        function write_octa_rgb_image(obj, image, subject_name, image_index)
            parts = [string(subject_name) "octa" "rgb" num2str(image_index)];
            file = obj.generate_file(parts, ".tif");
            imwrite(image, file);
        end
    end
    
    properties (Access = private)
        output_folder (1,1) string
    end
    
    methods (Access = private)
        function file = generate_file(obj, parts, ext)
            name = obj.generate_name(parts, ext);
            file = fullfile(obj.output_folder, name);
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

