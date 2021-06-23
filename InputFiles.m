classdef InputFiles < handle
    %{
    Expects folder structure like the following. There can not be any other
    subfolders except subjects and volumes. Other files are allowed in each
    volume folder. All volumes must have the same number of sample images.
    
    root
    |-- subject_1
        |-- volume_1
            |-- crop.txt (CropData)
            |-- offset.txt (OCTA offset in SLO)
            |-- sample_0.tif (SLO)
            |-- sample_1.tif (OCTA)
            |-- ...
            |-- sample_N.tif (OCTA)
        |-- volume_2
            |-- crop.txt (CropData)
            |-- offset.txt (OCTA offset in SLO)
            |-- sample_0.tif (SLO)
            |-- sample_1.tif (OCTA)
            |-- ...
            |-- sample_N.tif (OCTA)
        |-- volume_3
            |-- crop.txt (CropData)
            |-- offset.txt (OCTA offset in SLO)
            |-- sample_0.tif (SLO)
            |-- sample_1.tif (OCTA)
            |-- ...
            |-- sample_N.tif (OCTA)
    |-- subject_2
    |-- ...
    %}
    methods 
        function obj = InputFiles(root_folder)
            root_folder = string(root_folder);
            
            obj.root = root_folder;
        end
        
        function value = get_subject_count(obj)
            value = obj.get_folders(obj.root);
            value = height(value);
        end
        
        function value = get_subject_folder_name(obj, subject)
            value = obj.get_folders(obj.root);
            value = string(value{subject, "name"});
        end
        
        function value = get_volume_count(obj, subject)
            subject_folder = obj.get_folder(obj.root, subject);
            value = obj.get_folders(subject_folder);
            value = height(value);
        end
        
        function value = get_octa_image_count(obj, subject, volume)
            volume_files = obj.get_volume_files(subject, volume, ".tif");
            value = numel(volume_files(2:end));
        end
        
        function value = read_octa_image(obj, subject, volume, image)
            image_file = obj.get_octa_image(subject, volume, image);
            image_data = imread(image_file);
            image_data = rgb2gray(image_data);
            
            crop_data = obj.read_crop_data(subject, volume);
            if ~isempty(crop_data)
                rect = crop_data.get_crop_rectangle(image);
                image_data = imcrop(image_data, rect);
            end
            
            value = image_data;
        end
        
        function value = read_slo_images(obj, subject)
            count = obj.get_volume_count(subject);
            slo = cell(count, 1);
            for volume = 1 : count
                slo{volume} = obj.read_slo_image(subject, volume);
            end
            value = slo;
        end
        
        function value = read_offsets(obj, subject)
            count = obj.get_volume_count(subject);
            offsets = zeros(count, 2);
            for volume = 1 : count
                offsets(volume, :) = obj.read_offset_data(subject, volume);
            end
            value = offsets;
        end
        
        function value = read_octa_images(obj, subject, image)
            volume_count = obj.get_volume_count(subject);
            octa_images = cell(volume_count, 1);
            for volume = 1 : volume_count
                octa_images{volume} = obj.read_octa_image(subject, volume, image);
            end
            value = octa_images;
        end
        
        function value = read_slo_image(obj, subject, volume)
            image_file = obj.get_slo_image(subject, volume);
            image_data = imread(image_file);
            
            rect = obj.get_slo_crop_rectangle();
            image_data = imcrop(image_data, rect);
            image_data = rgb2gray(image_data);
            
            target_scale = obj.compute_slo_target_scale(subject, volume);
            image_data = imresize(image_data, target_scale);
            
            value = image_data;
        end
        
        function value = read_offset_data(obj, subject, volume)
            target_scale = obj.compute_slo_target_scale(subject, volume);
            
            file = obj.get_offset_file(subject, volume);
            data = readtable(file, "readvariablenames", false, "format", "auto");
            data = data{1, 1:2};
            data = data .* target_scale;
            value = data;
        end
    end
    
    properties (Access = private)
        root (1,1) string
    end
    
    properties (Access = private, Constant)
        SLO_PX = 496;
        SLO_TO_OCTA = 1 / 372;
    end
    
    methods (Access = private)
        function value = read_crop_data(obj, subject, volume)
            file = obj.get_crop_file(subject, volume);
            value = CropData(file);
        end
        
        function value = compute_slo_target_scale(obj, subject, volume)
            octa_crop_data = obj.read_crop_data(subject, volume);
            % uses min(), rigid transform only, have to choose 1
            if isempty(octa_crop_data)
                im = obj.read_octa_image(subject, volume, 1);
                octa_size = min(size(im));
            else
                octa_size = min(octa_crop_data.get_size());
            end
            
            slo_to_octa_scale = obj.SLO_PX .* obj.SLO_TO_OCTA;
            target_size = octa_size .* slo_to_octa_scale;
            target_scale = target_size ./ obj.SLO_PX;
            value = target_scale;
        end
        
        function value = get_slo_crop_rectangle(obj)
            value = [1 1 obj.SLO_PX obj.SLO_PX];
        end
        
        function value = get_crop_file(obj, subject, volume)
            volume_files = obj.get_volume_files(subject, volume, ".txt");
            value = volume_files(1); % hack, use text matching on name
        end
        
        function value = get_offset_file(obj, subject, volume)
            volume_files = obj.get_volume_files(subject, volume, ".txt");
            value = volume_files(2); % hack, use text matching on name
        end
        
        function value = get_slo_image(obj, subject, volume)
            volume_files = obj.get_volume_files(subject, volume, ".tif");
            value = volume_files(1); % file with (0) in name is SLO by convention
        end
        
        function value = get_octa_image(obj, subject, volume, image)
            volume_files = obj.get_volume_files(subject, volume, ".tif");
            value = volume_files(image + 1); % index 1 is SLO
        end
        
        function value = get_volume_files(obj, subject, volume, extension)
            subject_folder = obj.get_folder(obj.root, subject);
            volume_folder = obj.get_folder(subject_folder, volume);
            volume_files = get_contents(volume_folder);
            volume_files = get_files_with_extension(volume_files, extension);
            volume_files = get_full_paths(volume_files);
            value = natsort(volume_files);
        end
    end
    
    methods (Access = private, Static)
        function value = get_files(folder, extension)
            contents = get_contents(folder);
            contents = get_files_with_extension(contents, extension);
            value = get_full_paths(contents);
        end
        
        function value = get_folder(folder, index)
            value = InputFiles.get_folders(folder);
            value = value(index, :);
            value = fullfile(value.folder, value.name);
            value = string(value);
        end
        
        function value = get_folders(folder)
            value = get_contents(folder);
            value = value(value.isdir, :);
        end
    end
end

