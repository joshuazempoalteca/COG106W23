classdef SignalDetection < handle
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
            d_prime = norminv(hit_rate(obj)) - norminv(obj.FA());
        end
     
        function C = criterion(obj)
          C =  -0.5 *(norminv(obj.hit_rate()) + norminv(obj.FA())); 
        end
        % Add two SignalDetection objects
        function summation = plus(obj1, obj2)
            summation = SignalDetection(obj1.hits + obj2.hits, obj1.misses + ...
                obj2.misses, obj1.falseAlarms + obj2.falseAlarms, ...
                obj1.correctRejections + obj2.correctRejections);
        end
        % Multiply a SignalDetection object by a scalar
        function scaled = mtimes(obj, k)
            scaled = SignalDetection(obj.hits * k, obj.misses * k, ...
                obj.falseAlarms * k, obj.correctRejections * k);
        end

        function plot_sdt(obj)
            x = linspace(-4,4,200);
            Noise = normpdf(x, 0, 1);
            Signal = normpdf(x,obj.d_prime(),1);
            
            plot(x,Noise);
            hold on;
            plot(x,Signal)
            ylim([0, .5])
            xline(((obj.d_prime/2) + obj.criterion), '--k', 'HandleVisibility','off')
            line([0 obj.d_prime],[max(Noise) max(Signal)])
            legend('Noise', 'Signal')
            hold off;
        end
   
        function ell = nLogLikelihood(obj, hit_rate, false_alarm_rate)
           ell = - (obj.hits * log(hit_rate) +  obj.misses * log(1-hit_rate) ...
               + obj.falseAlarms * log(false_alarm_rate) + obj.correctRejections * log(1-false_alarm_rate));
        end
        
    end
    
    methods (Static) 
        function sdtList = simulate(dprime, criteriaList,signalcount, noiseCount)
            sdtList = [];
            for i=1:length(criteriaList)
                k = criteriaList(i) + (dprime/2);
                hit_Rate = 1 -(normcdf(k-dprime));
                FA_rate = 1 - (normcdf(k));

                Hits = binornd(signalcount, hit_Rate);
                Misses = signalcount - Hits;

                fas = round(binornd(noiseCount, FA_rate), 2);
                while fas == 0 %keep doing it
                    fas = round(binornd(noiseCount, FA_rate), 2); 
                end
                correct_Rejection = noiseCount - fas;

                sdtList = [sdtList; SignalDetection(Hits, Misses, fas, correct_Rejection)];
            end
        end
        
        function plot_roc(sdtList)
            hold on;
           for i=1:length(sdtList)
               sdt = sdtList(i);
               hit_rate = sdt.hits ./ (sdt.hits + sdt.misses);
               FA = sdt.falseAlarms ./ (sdt.falseAlarms + sdt.correctRejections);
               plot(FA, hit_rate, 'o-')
           end
           plot([0 1], [0 1], '--','Color', [0.5 0.5 0.5])
           ylim([0, 1]);
           xlim([0, 1]);

           xlabel('False Alarm Rate')
           ylabel('Hit Rate')
           title('ROC Curve')
        end
        
        function hit_rate = rocCurve(false_alarm_rate, a)
            hit_rate = zeros(1, length(false_alarm_rate));
            for i =1:length(false_alarm_rate)
             hit_rate = normcdf(a + norminv(false_alarm_rate));
            end
        end 

        function L = rocLoss(a, sdtList)
            ell = [];
            for i=1:length(sdtList)
                FA_rate = FA(sdtList(i));
                hit_rate = SignalDetection.rocCurve(FA_rate, a);
            
                ell = [ell; nLogLikelihood(sdtList(i), hit_rate, FA_rate)];
            end
             L = sum(ell);
        end

        function fit_roc = fit_roc(sdtList) 
            fun = @(a) SignalDetection.rocLoss(a,sdtList);
            
            start = 0;
            fit_roc = fminsearch(fun,start);
            
            x = linspace(0,1);
            y = SignalDetection.rocCurve(x, fit_roc);
            SignalDetection.plot_roc(sdtList)
            hold on;
            plot(x, y)
        end

        function obj = load(filename)
            saved = load(filename);
            obj = saved.obj;
        end
    end

end