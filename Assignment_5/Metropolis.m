classdef Metropolis < handle
    properties
        currentState
        logTarget
        sig
        samples
        blockLengths
    end
    
    methods (Access = private)
        function accepted = accept(self, proposal)
            acceptanceProbability = exp(self.logTarget(proposal) - self.logTarget(self.currentState));
            if rand() < acceptanceProbability
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
        
        function self = adapt(self)
            acceptanceTarget = 0.4;
            gamma = 0.05;
            numBlocks = numel(self.blockLengths);
            acceptanceRates = zeros(1, numBlocks);
            
            for i = 1:numBlocks
                for j = 1:self.blockLengths(i)
                    proposal = normrnd(self.currentState, self.sig);
                    if self.accept(proposal)
                        acceptanceRates(i) = acceptanceRates(i) + 1;
                    end
                end
                acceptanceRates(i) = acceptanceRates(i) / self.blockLengths(i);
                
                if acceptanceRates(i) < acceptanceTarget
                    self.sig = self.sig * (1 - gamma);
                else
                    self.sig = self.sig * (1 + gamma);
                end
            end
        end
        
        function self = sample(self, n)
            self.samples = zeros(1, n);
            for i = 1:n
                proposal = normrnd(self.currentState, self.sig);
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
