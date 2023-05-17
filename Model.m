classdef Model
    %MODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        poly
        ranges
        data
    end
    
    methods
        function obj = Model(data,r)
            switch nargin
                case 2
                    obj = obj.read_data(data,r);
                case 1
                    obj = obj.read_data(data,obj.make_ranges(data));
                otherwise
                    throw(MException('Model:WrongNumberOfArguments', ...
                        'Wrong number of arguments! Must be either 1 or 2.'))
            end
        end

        function r = make_ranges(obj,data)
%             FIXME make something that makes sense
            r = min(data.CALKOWITA_ODLEGLOSC):15:50-15;
            r = [r, 50:50:100-50];
            r = [r, 100:100:max(data.CALKOWITA_ODLEGLOSC)+100];
        end
        
        function obj = read_data(obj,data,r)
            for i=1:max(size(r))-1
                obj.ranges{i} = struct('min', r(i), 'max', r(i+1));
                obj.data{i} = data( ...
                    data.CALKOWITA_ODLEGLOSC >= obj.ranges{i}.min & ...
                    data.CALKOWITA_ODLEGLOSC < obj.ranges{i}.max,:);
            end
        end

        function obj = fit(obj,degree)
            for i=1:max(size(obj.ranges))
                obj.poly{i} = polyfit( ...
                    obj.data{i}.CALKOWITA_ODLEGLOSC, ...
                    obj.data{i}.KOSZT, degree);
            end
        end

        function result = predict(obj,val)
            i = 1;
            while val < obj.ranges{i}.min || val >= obj.ranges{i}.max
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

