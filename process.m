function process(root_folder)

ifi = InputFiles(root_folder);
seeds = Seeds(fullfile(root_folder, "seeds.csv"));

subject_count = ifi.get_subject_count();
for subject = 1 : subject_count
    subject_name = ifi.get_subject_folder_name(subject);
    fprintf("processing %s" + newline, subject_name);
    seed = seeds.get(subject_name);
    
    % OUTPUT SETUP
    output_folder = fullfile(root_folder, "..", "out", subject_name);
    ofi = OutputFiles(output_folder);
    
    % SLO REGISTER
    fprintf("  slo...");
    try
        slo_images = ifi.read_slo_images(subject);
    catch
        fprintf("can't read slo (check crop file), skipping" + newline);
        continue;
    end
    if numel(slo_images) < 2
        fprintf("only 1 volume, skipping..." + newline);
        continue;
    end
    transforms = register(slo_images, seed);
    [slo, slo_rgb] = combine(slo_images, transforms);
    ofi.write_slo_image(slo, subject_name);
    ofi.write_slo_rgb_image(slo_rgb, subject_name);
    fprintf("done!" + newline);
    
    % OCTA TRANSFORM
    fprintf("  octa...");
    try
        offsets = ifi.read_offsets(subject);
    catch
        fprintf("can't read octa (check offset file), skipping" + newline);
        continue;
    end
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
    
    fprintf("done!" + newline);
end

end