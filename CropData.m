classdef CropData < handle
    %{
    File must be 5-column CSV, no header row. Lookup returns data from table
    whose first column is the next-largest value of the input value.

    1. First row is extracted for height/width. Slice ignored.
    2. Remaining table is sorted by first column.
    3. First column of first row set to 1.
    
    Columns:
        1. first slice this row applies to (first value is ignored, always
            treated as 1)
        2-3. X, Y of top-left corner (except first row, see below)
    
    Rows:
        1. <ignored>, width, height of rectangle
        2+. first slice, x, y of top-left corner
    %}
    methods
        function obj = CropData(file_path)
            data = readtable(...
                file_path, ...
                "readvariablenames", false, ...
                "format", "auto" ...
                );
            assert(width(data) == 3);
            
            if isempty(data)
                w = [];
                h = [];
            else
                % first row is w, h
                w = data{1, 2};
                h = data{1, 3};
                data = data(2:end, :);

                % sort remainder and replace first slice of first row with 1
                data = sortrows(data, 1);
                data{1, 1} = 1;
            end
            
            obj.w = w;
            obj.h = h;
            obj.data = data;
        end
        
        function value = isempty(obj)
            value = isempty(obj.data);
        end
        
        function sz = get_size(obj)
            sz = [obj.w obj.h];
        end
        
        function r = get_crop_rectangle(obj, slice)
            %{
            Returns empty array if table is empty.
            %}
            r = [];
            for row = 1 : height(obj.data)
                if slice < obj.data{row, 1}
                    continue;
                else
                    r = [obj.data{row, 2:3} obj.w obj.h];
                end
            end
        end
    end
    
    properties (Access = private)
        w (1,1) double
        h (1,1) double
        data table
    end
end

