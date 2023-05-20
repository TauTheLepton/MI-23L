classdef Aggregator < handle

    properties
        data
        model_general
        model_brexit
        models
        models_cluster
    end
    
    methods
        function obj = Aggregator(data,r,min_cluster_size,poly_deg)
            obj.data = data;
            % make general model for all data
            obj.model_general = Model(data,r);
            obj.model_general.fit(poly_deg);
            % make model for just the uk data
            obj.model_brexit = Model( ...
                data(data.DLUGOSC_ZALADUNKU < 2 & data.SZEROKOSC_ZALADUNKU > 50,:),r);
            obj.model_brexit.fit(poly_deg);
            % make dedicated models for all clusters
            cluster_data = divide_cluster(data,min_cluster_size);
            obj.models = cell(size(cluster_data));
            obj.models_cluster = cell(size(cluster_data));
            for idx=1:max(size(cluster_data))
                obj.models{idx} = Model(cluster_data{idx},r);
                obj.models{idx}.fit(poly_deg);
                obj.models_cluster{idx} = cluster_data{idx}.KLASTER(1);
            end
            obj.models_cluster
        end
        
        function result = predict(obj,test_data)
            s = size(test_data.KOSZT);
            result = zeros(s);
            for idx=1:s(1)
                result(idx) = obj.predict_one(test_data(idx,:));
            end
        end

        function result = predict_one(obj,test_sample)
            result = obj.model_general.predict(test_sample.CALKOWITA_ODLEGLOSC);
            if test_sample.DLUGOSC_ZALADUNKU < 2 & test_sample.SZEROKOSC_ZALADUNKU > 50
                result = obj.predict_one4brexit(test_sample);
            else
                for idx=1:max(size(obj.models))
                    if obj.models_cluster{idx} == test_sample.KLASTER
                        result = obj.models{idx}.predict(test_sample.CALKOWITA_ODLEGLOSC);
                    end
                end
            end
        end

        function result = predict_one4brexit(obj,test_sample)
            result = obj.model_brexit.predict(test_sample.CALKOWITA_ODLEGLOSC);
        end

    end
end

