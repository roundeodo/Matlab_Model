function bits = extract_bits(signal, clock, osr)

% sample the signal at the times indicated by the clock
t = ((1 : numel(signal))' - 1) / osr;
symbols = interp1(t, signal, clock);

% convert to bits binary extract
 bits = (symbols > 0);

%multiple level extract
 % bits = round(127*symbols / max(abs(symbols)));
 % bits = bits + 127;
 bits = [bits(3:end);bits(1);bits(2)];
end