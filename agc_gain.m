function out = agc_gain(in)

% TODO: Implement this yourself!
% TIP: What can the output bits tell you about the signal amplitude
% beforing decoding?

out = in./max(abs(in));

end

