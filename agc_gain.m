function out = agc_gain(in)

% TODO: Implement this yourself!
% TIP: What can the output bits tell you about the signal amplitude
% beforing decoding?
fs = 100e3;  % 采样率 100 kHz
fc = 20e3;   % 载波频率 20 kHz
bw = 5e3;    % 允许的带宽 5 kHz
n = 50;      % 滤波器阶数

% 设计带通滤波器（18kHz ~ 22kHz）
bpf = fir1(n, [fc-bw, fc+bw] / (fs/2), 'bandpass');

% 对输入信号进行带通滤波
filtered_in = filter(bpf, 1, in);

% 使用滤波后的信号计算 AGC
gain = 1 / max(abs(filtered_in) + eps);
out = in * gain;
end

