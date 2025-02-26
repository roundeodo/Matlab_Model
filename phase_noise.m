%% Phase Noise Function
function noisy_signal = phase_noise(signal, fs, phase_noise_power)
% 参数说明：
% signal: 输入复数基带信号
% fs: 采样率(Hz)
% phase_noise_power: 相位噪声功率(dBc/Hz)
% 转换为线性功率
phase_noise_lin = 10^(phase_noise_power/10); 
% 生成相位噪声序列
N = length(signal);
% 维纳过程（标准布朗运动）+ 低通滤波
delta_phi = sqrt(phase_noise_lin) * cumsum(randn(N, 1)); % 生成布朗运动
[b,a] = butter(3, 0.1, 'low'); % 3阶低通滤波器
delta_phi = filter(b, a, delta_phi); % 滤波
% 应用相位噪声
noisy_signal = signal .* exp(1j*delta_phi);
% 可选：显示相位噪声谱
% figure;
% pwelch(delta_phi, [], [], [], fs);
% title('Phase Noise PSD');
end