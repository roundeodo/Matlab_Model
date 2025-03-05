function bits = extract_bits(signal, clock, osr, extract_way)

% sample the signal at the times indicated by the clock
t = ((1 : numel(signal))' - 1) / osr;
symbols = interp1(t, signal, clock);

% convert to bits binary extract
if extract_way == "hard"
 bits = (symbols > 0);


%multiple level extract
else 
 bits = round(31*symbols / max(abs(symbols)));
 bits = bits + 31;
end
 bits = [bits(3:end);bits(1);bits(2)];
end