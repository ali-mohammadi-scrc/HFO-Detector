%%
Ch = 23;
for S = 1:Channels(Ch).Num
    Data = data.x(data.BipChOrder(1, Ch), :) - data.x(data.BipChOrder(2, Ch), :);
    FilteredData = filtfilt(RFb, RFa, Data);
    RFilteredData = FilteredData;
    FilteredData = filtfilt(FRFb, FRFa, Data);
    FRFilteredData = FilteredData;
    FRandRSegments = Channels(Ch).FRandR;
    Start = FRandRSegments(S, 1);
    End = FRandRSegments(S, 2);
    OriginalStart = Start;
    OriginalEnd = End;
    if Start < 501
        Start = 1;
        End = 1001;
    elseif End > length(Data)
        End = length(Data);
        Start = End - 1000;
    else
        Mid = round((Start + End)/2);
        End = Mid + 500;
        Start = End - 1000;
    end
    Time = (Start:(End - 1))/SR;
    FRandRPts = (OriginalStart:OriginalEnd) - Start + 1;
    figure
    subplot(3, 1, 1)
    plot(Time, FRFilteredData(Start:End-1))
    xlim([Time(1) Time(end)])
    hold on
    plot(Time(FRandRPts), FRFilteredData(OriginalStart:OriginalEnd))
    xlim([Time(1) Time(end)])
    hold off
    subplot(3, 1, 2)
    plot(Time, RFilteredData(Start:End-1))
    xlim([Time(1) Time(end)])
    hold on
    plot(Time(FRandRPts), RFilteredData(OriginalStart:OriginalEnd))
    xlim([Time(1) Time(end)])
    hold off
    subplot(3, 1, 3)
    [s, f, t] = spectrogram(Data(Start:End), 2);
    Power = abs(s);
    FreqRange = f * 1000 / pi;
    FreqInds = find((FreqRange <= 520) & (FreqRange >= 78));
    contourf(Time, FreqRange(FreqInds), 20*log10(Power(FreqInds, :)));
    g = gca;
    g.YTickLabel = num2str(FreqRange(FreqInds(1:6:end)));
    g.YTick = FreqRange(FreqInds(1:6:end));
end