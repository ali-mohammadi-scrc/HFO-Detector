function [RawSignalThreshold, FilteredSignalThreshold] = FindThresholds (Signal, FilteredSignal, Envelope, LowFreq, SamplingRate, CDFLevel_Raw)
indHighEntr = [];
%%
SecBegins = 0:SamplingRate:length(Signal);
SecBegins = SecBegins(1:end-1) + 1;
Sec = 1;
while (length(indHighEntr) < 2.5 * SamplingRate && Sec <= length(SecBegins)) || Sec < length(SecBegins)/10
    Begin = SecBegins(Sec);
    End = Begin + SamplingRate - 1;
    ASecSig = Signal(Begin:End);
    [StockwellTransform, ~ , ~] = st(ASecSig, LowFreq + 1, 500, 1/SamplingRate, 1);
    StockwellEntropy = abs(StockwellTransform(:,:)) .^ 2;
    P = bsxfun(@rdivide, StockwellEntropy, sum(StockwellEntropy, 1));
    Entropy = zeros(1, size(StockwellEntropy, 2));
    for Freq = 1:length(Entropy)
        Entropy(Freq) = -sum(P(:, Freq) .* log(P(:, Freq)));
    end
    BaselineThreshold = log(size(StockwellEntropy, 1)) * 0.9;
    HighEntropies = find(Entropy > BaselineThreshold);
    if ~isempty(HighEntropies)
        HighEntropies(HighEntropies < 0.02 * SamplingRate) = [];
        HighEntropies(HighEntropies > 0.98 * SamplingRate) = [];
    end
    if ~isempty(HighEntropies)
        Discontinuity = find(HighEntropies(2:end) - HighEntropies(1:end-1) > 1);
        if HighEntropies(1) == SamplingRate * 0.02
            Discontinuity = [1 Discontinuity];
        end
        if HighEntropies(end) == SamplingRate * 0.98
            Discontinuity = [Discontinuity length(HighEntropies)];
        end
        if isempty(Discontinuity)
            Discontinuity = length(HighEntropies);
        end
        for i = 1:length(Discontinuity)-1
            j = (Discontinuity(i) + 1):Discontinuity(i + 1);
            if (length(j) >= 10 * SamplingRate * 1e-3)
                HighEntropies(j)= HighEntropies(j) + (Sec - 1) * SamplingRate;
                if ~sum(abs(FilteredSignal(HighEntropies(j))) > 10)
                    indHighEntr = [indHighEntr HighEntropies(j)];
                end
            end
        end
    end
    Sec = Sec + 1;
end
baseline = Envelope(indHighEntr);
[f,x] = ecdf(baseline);
RawSignalThreshold = x(f > CDFLevel_Raw);
RawSignalThreshold = RawSignalThreshold(1);
baseline = FilteredSignal(indHighEntr);
[f,x] = ecdf(baseline);
FilteredSignalThreshold = x(f > 0.99);
FilteredSignalThreshold = FilteredSignalThreshold(1);
end