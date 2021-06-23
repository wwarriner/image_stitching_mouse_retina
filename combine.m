function [canvas, rgb] = combine(images, transforms)

canvas = create_blank(images, transforms);
view = create_view(images, transforms);

% debug
rgb = repmat(canvas, [1 1 3]);

count = numel(images);
for i = 1 : count
    image = images{i};
    sz = size(image);
    transform = transforms(i);
    warped = imwarp(image, transform, "outputview", view);
    mask = imwarp(true(sz(1), sz(2)), transform, "outputview", view);
    canvas(mask) = warped(mask);
    
    % debug
    rgb(:, :, i) = warped;
end

end


function view = create_view(images, transforms)
    limits = compute_limits(images, transforms);
    view = imref2d(...
        round([limits.height limits.width]), ...
        limits.x, ...
        limits.y ...
        );
end


function image = create_blank(images, transforms)

limits = compute_limits(images, transforms);
image = zeros(...
    round([limits.height limits.width]), ...
    "like", images{1} ...
    );

end


function limits = compute_limits(images, transforms)

count = numel(images);

xlim = zeros(count, 2);
ylim = zeros(count, 2);
for i = 1 : count
    transform = transforms(i);
    sz = size(images{i});
    [xlim(i, :), ylim(i, :)] = outputLimits(transform, [1 sz(2)], [1 sz(1)]);
end

limits.xmin = min([1; xlim(:)]);
limits.xmax = max([1; xlim(:)]);
limits.ymin = min([1; ylim(:)]);
limits.ymax = max([1; ylim(:)]);
limits.x = [limits.xmin limits.xmax];
limits.y = [limits.ymin limits.ymax];
limits.width = diff(limits.x);
limits.height = diff(limits.y);

end

