function plain = fec_decode(encoded)

    trellis = poly2trellis(7, [171 133]);

    tracebackLength = 30;  % 一般 5*(K-1) ~ 6*(K-1)

    plain = vitdec(encoded, trellis, tracebackLength, 'term', 'hard');
    plain = plain(1:end-6);
end