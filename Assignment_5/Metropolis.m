classdef Metropolis < handle
    properties
        currentState
        logTarget
        samples
    end
    
    methods (Access = private)
        function accepted = accept(self, proposal)
            acceptanceProbability = min(0,self.logTarget(proposal) - self.logTarget(self.currentState));
            if log(rand()) < acceptanceProbability
                self.currentState = proposal;
                accepted = true;
            else
                accepted = false;
            end
        end
    end

    methods
        function self = Metropolis(logTarget, initialState)
            self.logTarget = logTarget;
            self.currentState = initialState;
        end
        
        function self = adapt(self, blockLengths)
            sig = 1;
            acceptanceTarget = 0.4;
            gamma = 0.05;
            blockAmount = numel(blockLengths);
            acceptanceRates = zeros(1, blockAmount);
            
            for i = 1:blockAmount
                for j = 1:blockLengths(i)
                    proposal = normrnd(self.currentState, sig);
                    if self.accept(proposal)
                        acceptanceRates(i) = acceptanceRates(i) + 1;
                    end
                end
                acceptanceRates(i) = acceptanceRates(i) / blockLengths(i);
                
                if acceptanceRates(i) < acceptanceTarget
                    sig = 1 * (1 - gamma);
                else
                    sig = 1 * (1 + gamma);
                end
                
            end
        end
        
        function self = sample(self, n) 
            self.samples = zeros(1, n);
            for i = 1:n
                proposal = normrnd(self.currentState, 1);
                if self.accept(proposal)
                    self.samples(i) = proposal;
                else
                    self.samples(i) = self.currentState;
                end
            end
           

        end
        
        function summary = summary(self)
            summary.mean = mean(self.samples);
            summary.c025 = prctile(self.samples, 2.5);
            summary.c975 = prctile(self.samples, 97.5);
        end
    end
end
