clear
close all
clc
%% Loading Data & Filter
load('Ripple_Filter.mat');
RFa = a;
RFb = b;
%%
load('FRipple_Filter.mat');
FRFa = a;
FRFb = b;
%%
load('SampleData.mat');
% load('GR_HL1.mat');
SR = data.fs;
% SR = 2000;
%% Detection
MinOscillations = 6;
Channels = struct('Ripple', zeros(size(data.BipChOrder, 2), 1), 'FastRipple', zeros(size(data.BipChOrder, 2), 1), 'FRandR', zeros(size(data.BipChOrder, 2), 1), 'Num', zeros(size(data.BipChOrder, 2), 1));
for i = 1:size(data.BipChOrder, 2)
    %%
    Data = data.x(data.BipChOrder(1, i), :) - data.x(data.BipChOrder(2, i), :);
%     Data = data;
    %% for Ripple Detection 
    FilteredData = filtfilt(RFb, RFa, Data);
    RFilteredData = FilteredData;
    Envelope = smooth(abs(hilbert(FilteredData)), SR/80);
    %%
    [RawSignalThreshold, FilteredSignalThreshold] = FindThresholds (Data, FilteredData, Envelope, 80, SR, 0.95);
    AboveLowThresholdSegments = findAboveThresholdSegments(Envelope, RawSignalThreshold * 0.99);
    AboveThresholdSegments = findAboveThresholdSegments(Envelope, RawSignalThreshold); 
    LongEnoughSegments = find((AboveThresholdSegments(:, 2) - AboveThresholdSegments(:, 1)) >= round(SR * 0.02))';
    Segments = zeros(size(LongEnoughSegments));
    for S = 1:length(Segments)
        Segments(S) = find(AboveLowThresholdSegments(:, 1) <= AboveThresholdSegments(LongEnoughSegments(S), 1) & AboveLowThresholdSegments(:, 2) >= AboveThresholdSegments(LongEnoughSegments(S), 1));
    end
    Segments = unique(Segments);
    Peaks = zeros(length(Segments), 1);
    for S = 1:length(Segments)
        Peaks(S) = max(Envelope(AboveLowThresholdSegments(Segments(S), 1):AboveLowThresholdSegments(Segments(S), 2)));
    end
    Segments = Segments(Peaks <= 30);
    %%
    demeantFilteredSignal = FilteredData - mean(FilteredData);
    NOscillations = zeros(length(Segments), 1);
    for S = 1:length(Segments)
        Sig = demeantFilteredSignal(AboveLowThresholdSegments(Segments(S), 1):AboveLowThresholdSegments(Segments(S), 2));
        CrossingPoints = unique(find(Sig(1:end-1) .* Sig(2:end) < 0));
        Peaks = zeros(length(CrossingPoints) - 1, 1);
        for j = 1:length(Peaks)
            [~, Peaks(j)] = max(abs(Sig(CrossingPoints(j):CrossingPoints(j + 1))));
            Peaks(j) = Peaks(j) + CrossingPoints(j) - 1;
        end
        FinePeaks = [0, abs(Sig(Peaks)) > FilteredSignalThreshold, 0];
        Oscs = diff(find(FinePeaks == 0)) - 1;
        NOscillations(S) = max(Oscs);
    end
    Segments = Segments(NOscillations >= MinOscillations);
    Segments = [AboveLowThresholdSegments(Segments, 1), AboveLowThresholdSegments(Segments, 2)];
    %%
    for S = 1:(size(Segments, 1)-1)
        if (Segments(S + 1, 1) - Segments(S, 2)) < 0.02 * SR
            Segments(S + 1, 1) = Segments(S, 1);
            Segments(S, 2) = Segments(S + 1, 2);
        end
    end
    for S = (size(Segments, 1)-1):-1:1
        if (Segments(S + 1, 1) - Segments(S, 2)) < 0.02 * SR
            Segments(S + 1, 1) = Segments(S, 1);
            Segments(S, 2) = Segments(S + 1, 2);
        end
    end
    [~, SegmentInds] = unique(Segments(:, 1));
    RippleSegments = Segments(SegmentInds, :);
    %% Fast Ripple Detection 
    FilteredData = filtfilt(FRFb, FRFa, Data);
    FRFilteredData = FilteredData;
    Envelope = smooth(abs(hilbert(FilteredData)), SR/250);
    %%
    [RawSignalThreshold, FilteredSignalThreshold] = FindThresholds (Data, FilteredData, Envelope, 250, SR, 0.7);
    AboveLowThresholdSegments = findAboveThresholdSegments(Envelope, RawSignalThreshold * 0.99);
    AboveThresholdSegments = findAboveThresholdSegments(Envelope, RawSignalThreshold); 
    LongEnoughSegments = find((AboveThresholdSegments(:, 2) - AboveThresholdSegments(:, 1)) >= round(SR * 0.01))';
    Segments = zeros(size(LongEnoughSegments));
    for S = 1:length(Segments)
        Segments(S) = find(AboveLowThresholdSegments(:, 1) <= AboveThresholdSegments(LongEnoughSegments(S), 1) & AboveLowThresholdSegments(:, 2) >= AboveThresholdSegments(LongEnoughSegments(S), 1));
    end
    Segments = unique(Segments);
    Peaks = zeros(length(Segments), 1);
    for S = 1:length(Segments)
        Peaks(S) = max(Envelope(AboveLowThresholdSegments(Segments(S), 1):AboveLowThresholdSegments(Segments(S), 2)));
    end
    Segments = Segments(Peaks <= 30);
    %%
    demeantFilteredSignal = FilteredData - mean(FilteredData);
    NOscillations = zeros(length(Segments), 1);
    for S = 1:length(Segments)
        Sig = demeantFilteredSignal(AboveLowThresholdSegments(Segments(S), 1):AboveLowThresholdSegments(Segments(S), 2));
        CrossingPoints = unique(find(Sig(1:end-1) .* Sig(2:end) < 0));
        Peaks = zeros(length(CrossingPoints) - 1, 1);
        for j = 1:length(Peaks)
            [~, Peaks(j)] = max(abs(Sig(CrossingPoints(j):CrossingPoints(j + 1))));
            Peaks(j) = Peaks(j) + CrossingPoints(j) - 1;
        end
        FinePeaks = [0, abs(Sig(Peaks)) > FilteredSignalThreshold, 0];
        Oscs = diff(find(FinePeaks == 0)) - 1;
        NOscillations(S) = max(Oscs);
    end
    Segments = Segments(NOscillations >= MinOscillations);
    Segments = [AboveLowThresholdSegments(Segments, 1), AboveLowThresholdSegments(Segments, 2)];
    %%
    for S = 1:(size(Segments, 1)-1)
        if (Segments(S + 1, 1) - Segments(S, 2)) < 0.02 * SR
            Segments(S + 1, 1) = Segments(S, 1);
            Segments(S, 2) = Segments(S + 1, 2);
        end
    end
    for S = (size(Segments, 1)-1):-1:1
        if (Segments(S + 1, 1) - Segments(S, 2)) < 0.02 * SR
            Segments(S + 1, 1) = Segments(S, 1);
            Segments(S, 2) = Segments(S + 1, 2);
        end
    end
    [~, SegmentInds] = unique(Segments(:, 1));
    FastRippleSegments = Segments(SegmentInds, :);
    %% FR&R
    FRandRSegments = RippleSegments(:, 1);
    for S = 1:length(FRandRSegments)
        FRandRSegments(S) = sum((RippleSegments(S, 1) < FastRippleSegments(:, 2)) & (RippleSegments(S, 2) > FastRippleSegments(:, 1)));
    end
    FRandRSegments = RippleSegments(FRandRSegments > 0, :);
    %%
    Channels(i).Ripple = RippleSegments;
    Channels(i).FastRipple = FastRippleSegments;
    Channels(i).FRandR = FRandRSegments;
    Channels(i).Num = size(FRandRSegments, 1);
    %%
end
%%