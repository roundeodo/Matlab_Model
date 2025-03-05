function raw = gmsk_demodulate(complex_envelope, osr)

% TODO: This is a very simple demodulator to get you started. There are
% lots of things that can be improved!
% TIP: Search for demodulation methods online. Are you going for the
% coherent or incoherent approach?

%fs = 20.0e3;
% apply a simple filter
%phase_noise_power = -20; % 相位噪声功率(dBc/Hz)
%complex_envelope = phase_noise(complex_envelope, fs, phase_noise_power);

% 设计匹配滤波器（与发送端相同）
bt = 0.5;       % 确保与发射端一致
matched_filter = gaussian_filter(bt, osr); % 直接使用发射端的高斯滤波器

% 对下变频后的信号进行匹配滤波
complex_envelope = conv(complex_envelope, matched_filter, 'same');


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