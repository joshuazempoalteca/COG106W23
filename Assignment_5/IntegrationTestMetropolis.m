%% Simulate signal detection data
sdtList = SignalDetection.simulate(1, [-1, 0, 1], 40, 40);

%% Define the log-likelihood function
logPosterior = @(a) -SignalDetection.rocLoss(a, sdtList) + ...
    log(normpdf(a, 0, 10));

%% Initialize Metropolis-Hastings sampler with initial state 0
sampler = Metropolis(logPosterior, 0);

% Adapt the sampler
sampler = sampler.adapt([2000 2000 2000]);

% Sample from the posterior distribution
sampler = sampler.sample(4000);

% Compute summary statistics
result = sampler.summary();

% Print the estimated value of a with 95% credible interval
fprintf('Estimated a: %f (%f, %f)\n', ...
    result.mean, result.c025, result.c975);

%% Plot the ROC curve and posterior distribution
xaxis = 0:0.01:1;
rocCurve    = SignalDetection.rocCurve(xaxis, result.mean);
rocCurve025 = SignalDetection.rocCurve(xaxis, result.c025);
rocCurve975 = SignalDetection.rocCurve(xaxis, result.c975);

% Plot the ROC curve
subplot(2, 3, [1 2 4 5]);
SignalDetection.plot_roc(sdtList);
hold on;
patch([xaxis fliplr(xaxis)], [rocCurve025 fliplr(rocCurve975)], ...
    'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
plot(xaxis, rocCurve, 'r', 'LineWidth', 2)
hold off;

sgtitle('Bayesian ROC Curve Fitting');
title('ROC curve');
ylabel('Hit Rate');
xlabel('False Positive Rate');

% Plot the traceplot
subplot(2, 3, 3);
plot(sampler.samples);
title('Trace plot');
xlabel('iteration');
ylabel('a');

% Plot the posterior histogram
subplot(2, 3, 6);
histogram(sampler.samples, 'Normalization', 'pdf', 'BinWidth', 0.05);
title('Histogram');
xlabel('a');
ylabel('Density');
