function plain = fec_decode(encoded)

    trellis = poly2trellis(7, [171 133]);
    %hard decode
    plain = vitdec(encoded, trellis, 30, "term", "hard");

    %soft decode
    % plain = vitdec(encoded, trellis, 35, 'term', 'soft', 8);
    
    plain = plain(1:end-6);
end