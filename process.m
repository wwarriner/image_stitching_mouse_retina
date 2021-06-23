function process(root_folder)

ifi = InputFiles(root_folder);

output_folder = fullfile(root_folder, "..", "out"); 
[~, ~] = mkdir(output_folder);
ofi = OutputFiles(output_folder);

subject_count = ifi.get_subject_count();
for subject = 1 : subject_count
    subject_name = ifi.get_subject_folder_name(subject);
    
    slo_images = ifi.read_slo_images(subject);
    transforms = register(slo_images);
    [slo, slo_rgb] = combine(slo_images, transforms);
    ofi.write_slo_image(slo, subject_name);
    ofi.write_slo_rgb_image(slo_rgb, subject_name);
    
    offsets = ifi.read_offsets(subject);
    octa_transforms = translate_transforms(transforms, offsets);
    
    volume_count = ifi.get_volume_count(subject);
    octa_counts = zeros(volume_count, 1);
    for volume = 1 : volume_count
        octa_counts(volume) = ifi.get_octa_image_count(subject, volume);
    end
    assert(all(octa_counts == octa_counts(1), "all"));
    octa_count = octa_counts(1);
    
    for image = 1 : octa_count
        octa_images = ifi.read_octa_images(subject, image);
        [octa, octa_rgb] = combine(octa_images, octa_transforms);
        ofi.write_octa_image(octa, subject_name, image);
        ofi.write_octa_rgb_image(octa_rgb, subject_name, image);
    end
end

end