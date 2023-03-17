classdef SignalDetection
    properties
        hits
        misses
        falseAlarms
        correctRejections
    end
    
    methods
        function obj = SignalDetection(hits, misses, falseAlarms, correctRejections)
            obj.hits = hits;
            obj.misses = misses;
            obj.falseAlarms = falseAlarms;
            obj.correctRejections = correctRejections;
        end
        
        function H = hit_rate(obj)
            H = obj.hits / (obj.hits + obj.misses);
        end
        
        function FA = FA(obj)
            FA = obj.falseAlarms / (obj.falseAlarms + obj.correctRejections);
        end
       
        function d_prime = d_prime(obj)
            d_prime = norminv(hit_rate(obj)) - norminv(obj.FA()); %change norminv
        end
        
        function C = criterion(obj)
          C =  -0.5 *(norminv(obj.hit_rate()) + norminv(obj.FA())); %change norminv
        end
    end
end