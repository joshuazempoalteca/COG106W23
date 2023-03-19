function tests = TestSignalDetection
  tests = functiontests(localfunctions);
end

function testDPrimeZero(testCase)

  obj      = SignalDetection(15, 5, 15, 5);
  actual   = obj.d_prime();
  expected = 0;
  verifyEqual(testCase, actual, expected, 'AbsTol', 1e-6);

end

function testDPrimeNonzero(testCase)

  obj      = SignalDetection(15, 10, 15, 5);
  actual   = obj.d_prime();
  expected = -0.421142647060282;
  verifyEqual(testCase, actual, expected, 'AbsTol', 1e-6);

end

function testCriterionZero(testCase)

  obj = SignalDetection(5, 5, 5, 5);
  actual = obj.criterion();
  expected = 0;
  testCase.verifyEqual(actual, expected, 'AbsTol', 1e-6);

end

function testCriterionNonzero(testCase)

  obj = SignalDetection(15, 10, 15, 5);
  actual = obj.criterion();
  expected = -0.463918426665941;
  testCase.verifyEqual(actual, expected, 'AbsTol', 1e-6);

end

function testAddition(testCase)

  obj = SignalDetection(1, 1, 2, 1) + SignalDetection(2, 1, 1, 3);
  actual   = obj.criterion();
  expected = SignalDetection(3, 2, 3, 4).criterion;
  testCase.verifyEqual(actual, expected, 'AbsTol', 1e-6);

end

function testMultiplication(testCase)

  obj = SignalDetection(1, 2, 3, 1) * 4;
  actual   = obj.criterion();
  expected = SignalDetection(4, 8, 12, 4).criterion;
  testCase.verifyEqual(actual, expected, 'AbsTol', 1e-6);

end

%% Object Corruption Test
function testCorruption(testCase)

    obj = SignalDetection(5, 5, 5, 5);
    obj.hits = 15;
    obj.misses = 10;
    obj.falseAlarms = 15;
    obj.correctRejections = 5;
    actual = obj.criterion();
    expected = -0.463918426665941;
    testCase.verifyEqual(actual, expected, 'AbsTol', 1e-6);
end

%% A4 tests
function test_simulate_single(testCase)
    % Test that SignalDetection.simulate returns the expected number of
    % SignalDetection objects with the expected properties 
    % Test with a single criterion value
    dPrime = 1.5;
    criteriaList = 0;
    signalCount = 1000;
    noiseCount = 1000;
    sdtList = SignalDetection.simulate(dPrime, criteriaList, ...
        signalCount, noiseCount);
    testCase.verifyEqual(length(sdtList), 1);
    sdt = sdtList(1);
    
    testCase.verifyEqual(sdt.hits, sdtList(1).hits);
    testCase.verifyEqual(sdt.misses, sdtList(1).misses);
    testCase.verifyEqual(sdt.falseAlarms, sdtList(1).falseAlarms);
    testCase.verifyEqual(sdt.correctRejections, sdtList(1).correctRejections);
end

function test_simulate_multiple(testCase)
    % Test that SignalDetection.simulate returns the expected number of
    % SignalDetection objects with the expected properties     
    % Test with multiple criterion values
    dPrime = 1.5;
    criteriaList = [-0.5, 0, 0.5];
    signalCount = 1000;
    noiseCount = 1000;
    sdtList = SignalDetection.simulate(dPrime, criteriaList, ...
        signalCount, noiseCount);
    testCase.verifyEqual(length(sdtList), 3);
    for i = 1:length(sdtList)
        sdt = sdtList(i);
        testCase.verifyLessThanOrEqual(sdt.hits, signalCount);
        testCase.verifyLessThanOrEqual(sdt.misses, signalCount);
        testCase.verifyLessThanOrEqual(sdt.falseAlarms, noiseCount);
        testCase.verifyLessThanOrEqual(sdt.correctRejections, noiseCount);
    end
end

function test_nLogLikelihood(testCase)
    sdt = SignalDetection(10, 5, 3, 12);
    hit_rate = 0.5;
    false_alarm_rate = 0.2;
    expected_nll = - ( ...
          10 * log(hit_rate) ...
        +  5 * log(1-hit_rate) ...
        +  3 * log(false_alarm_rate) ...
        + 12 * log(1-false_alarm_rate));
    testCase.verifyEqual(sdt.nLogLikelihood(hit_rate, false_alarm_rate), ...
        expected_nll, 'AbsTol', 1e-6);
end

function test_rocLoss(testCase)
    sdtList = [
        SignalDetection( 8, 2, 1, 9),
        SignalDetection(14, 1, 2, 8),
        SignalDetection(10, 3, 1, 9),
        SignalDetection(11, 2, 2, 8),
    ];
    a = 0;
    expected = 99.3884206555698;
    testCase.verifyEqual(SignalDetection.rocLoss(a, sdtList), expected, ...
        'AbsTol', 1e-4);
end
 
function test_integration(testCase)
    dPrime = 1;
    sdtList = SignalDetection.simulate(dPrime, [-1, 0, 1], 1e7, 1e7);
    aHat = SignalDetection.fit_roc(sdtList);
    testCase.verifyEqual(aHat, dPrime, 'AbsTol', 0.02);
    close(gcf)
end
