classdef Aggregator

    properties
        models
        models_cluster
    end
    
    methods
        function obj = Aggregator(data,r)
            cluster_data = divide_cluster(data,30);
            obj.models = cell(size(cluster_data));
            obj.models_cluster = cell(size(cluster_data));
            for idx=1:max(size(cluster_data))
                obj.models{idx} = Model(cluster_data{idx},r);
                obj.models{idx} = obj.models{idx}.fit(1);
                obj.models_cluster{idx} = cluster_data{idx}.KLASTER(1);
            end
        end
        
        function result = predict(obj,test_data)
            s = size(test_data);
            result = zeros(s);
            test_data(1,:).KLASTER
            for idx=1:s(1)
                obj.predict_one(test_data(idx,:))
                result(idx) = obj.predict_one(test_data(idx,:));
            end
        end

        function result = predict_one(obj,test_sample)
            for idx=1:max(size(obj.models))
                if obj.models_cluster{idx} == test_sample.KLASTER
                    result = obj.models{idx}.predict(test_sample.CALKOWITA_ODLEGLOSC);
                end
            end
        end
    end
end

