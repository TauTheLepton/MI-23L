classdef Model < handle

    properties
        poly
        ranges
        data
    end
    
    methods
        function obj = Model(data,r)
            switch nargin
                case 2
                    obj.read_data(data,r);
                case 1
                    obj.read_data(data,obj.make_ranges(data));
                otherwise
                    throw(MException('Model:WrongNumberOfArguments', ...
                        'Wrong number of arguments! Must be either 1 or 2.'))
            end
        end

        function r = make_ranges(obj,data)
            dat = rmoutliers([data.CALKOWITA_ODLEGLOSC, data.KOSZT]);
            x=dat(:,1);
            y=dat(:,2);
            Lv = ischange(y, 'linear', 'MaxNumChanges',10);
            Idx = [1 find(Lv)', numel(y)];
            rang = x(Idx(:));
            rang = sort(rang);
            r = [1 rang' max(data.CALKOWITA_ODLEGLOSC)+1];
        end
        
        function read_data(obj,data,r)
            for i=1:max(size(r))-1
                obj.ranges{i} = struct('min', r(i), 'max', r(i+1));
                obj.data{i} = data( ...
                    data.CALKOWITA_ODLEGLOSC >= obj.ranges{i}.min & ...
                    data.CALKOWITA_ODLEGLOSC < obj.ranges{i}.max,:);
            end
        end

        function fit(obj,degree)
            for i=1:max(size(obj.ranges))
                obj.poly{i} = polyfit( ...
                    obj.data{i}.CALKOWITA_ODLEGLOSC, ...
                    obj.data{i}.KOSZT, degree);
            end
        end

        function result = predict(obj,val)
            i = 1;
            while i < size(obj.ranges,2) && (val < obj.ranges{i}.min || val >= obj.ranges{i}.max)
                i = i+1;
                continue
            end
            result = polyval(obj.poly{i}, val);
        end

        function result = predict_many(obj,val)
            s = size(val);
            result = zeros(s);
            for i=1:s(1)
                result(i) = obj.predict(val(i));
            end
        end
    end
end

