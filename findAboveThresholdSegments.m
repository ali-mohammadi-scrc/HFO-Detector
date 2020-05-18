function Segments = findAboveThresholdSegments (Signal, Threshold)
    Crossed = find(Signal > Threshold);
    Breaks = find((Crossed - [-2; Crossed(1:end-1)]) > 1);
    Segments = [Crossed(Breaks), [Crossed(Breaks(2:end) - 1); Crossed(end)] + 1];
    if Crossed(end) == length(Signal)
        Segments(end, 2) = Segments(end, 2) - 1;
    end
end