classdef Metropolis < handle
    properties 
       logtarget
       initialState
       samples
    end
    
    methods
        function obj = Metropolis(logTarget, initialState)
            obj.logTarget = logTarget;
            obj.initialState = initialState
            
        end
      
        function self = adapt(self)

        end
        
        function self = sample(self, n)

        end
       
        function summ = summary(self)
            
        end
        
        function 
        end

        function 
        end

        function 
        end

        function 
        end
   
        function 
        end
        
    end
    
    methods (private) 
        function  yesno = accept(self, proposal);
            if
                = True
            else
                = False
            end
        end
    end
end