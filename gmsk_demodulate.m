function raw = gmsk_demodulate(complex_envelope, osr)

% TODO: This is a very simple demodulator to get you started. There are
% lots of things that can be improved!
% TIP: Search for demodulation methods online. Are you going for the
% coherent or incoherent approach?

% apply a simple filter
IQ_synced = costas_loop(complex_envelope,0.01);
I = real(IQ_synced);
Q = imag(IQ_synced);
fc = 1 / (2 * osr);  % 截止频率 = Rb/2 归一化
B = fir1(50, fc * 2);  % 低通滤波器

% **(3) 滤波平滑 IQ 信号**
I_filtered = filter(B, 1, I);
Q_filtered = filter(B, 1, Q);

% **(4) 计算瞬时相位**
phase = unwrap(atan2(Q_filtered, I_filtered));


% calculate derivative
raw = diff(phase) * osr / (0.5 * pi);
raw = raw.';
end