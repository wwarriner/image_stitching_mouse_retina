function tforms = translate_transforms(tforms, offsets)
%{
tforms is M vec of MATLAB transform objects
offsets is Mx2 double
%}

count = numel(tforms);
for i = 1 : count
    translation_m = eye(3);
    translation_m(3, 1:2) = offsets(i, 1:2);
    translation = rigid2d(translation_m);
    tforms(i).T = tforms(i).T * translation.T;
end

end

