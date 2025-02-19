function complex_envelope = iq_downmixer(signal, osr, br, fc, fs)

% TODO: You may want to implement a better downsampling filter.
% TIP: Look up 'CIC' filters as inspiration for an efficient hardware 
% implementation. Also think about how you will generate the LO signal in
% hardware, looking up 'CORDIC' will set you in a correct direction.

% IQ downmixer
t = ((1 : numel(signal))' - 1) / fs;
upsampled_envelope = 2 * exp(-1j * 2 * pi * fc * t) .* signal;

% apply a simple downsampling filter
filt = ones(2 * round(fs / (br * osr)) + 1);
upsampled_envelope = conv(upsampled_envelope, filt / sum(filt), 'same');

% calculate number of output samples
n1 = numel(upsampled_envelope);
n2 = round((n1 - 1) * (br * osr) / fs) + 1;

% resample the complex envelope to the new sample rate
t1 = ((1 : n1)' - 1) / fs;
t2 = ((1 : n2)' - 1) / (br * osr);
complex_envelope = interp1(t1, upsampled_envelope, t2);

end