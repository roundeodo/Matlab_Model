function clock = clock_recovery(signal, osr)

% TODO: Implement this yourself!
% TIP: Add some non-ideal effects to your signal and come up with an algorithm
% which can provide a stable clock despite these effects.

n = floor(numel(signal) / osr);
clock = (1 : n)' - 0.5;

end