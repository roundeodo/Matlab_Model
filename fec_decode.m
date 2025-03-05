function plain = fec_decode(encoded, extract_way)

    trellis = poly2trellis(7, [171 133]);
    %hard decode
    if extract_way == "hard"
    plain = vitdec(encoded, trellis, 35, "term", "hard");
    
    %soft decode
    else
    plain = vitdec(encoded, trellis, 35, 'term', 'soft', 6);
    end

    plain = plain(1:end-6);
end