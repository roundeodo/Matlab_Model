function raw = gmsk_demodulate(complex_envelope, osr)

% TODO: This is a very simple demodulator to get you started. There are
% lots of things that can be improved!
% TIP: Search for demodulation methods online. Are you going for the
% coherent or incoherent approach?

% apply a simple filter
filt = ones(osr / 2 + 1);
complex_envelope = conv(complex_envelope, filt / sum(filt), 'same');

% extract phase
phase = unwrap(angle(complex_envelope));

% calculate derivative
raw = diff(phase) * osr / (0.5 * pi);

end