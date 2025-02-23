function signal = iq_upmixer(complex_envelope, osr, br, fc, fs)

% calculate number of output samples
n1 = numel(complex_envelope);  %envelope是包络的数据   是离散序列  使用numel函数返回这个数据中的样本个数  这个样本的采样率是OSR * bit rate  即每秒有osr * bit rate个采样点
%然后这个信号的持续时间Tsignal 就是n1/(br * osr)

n2 = round((n1 - 1) * fs / (br * osr)) + 1; %fs是目标采样率   n1 -1 是按照br * osr 这个速率采样出来的  所以要先归一化 然后求按照fs的速率来采 会有多少个采样点 然后这里注意索引


% resample the complex envelope to the new sample rate
t1 = ((1 : n1)' - 1) / (br * osr);
t2 = ((1 : n2)' - 1) / fs;
upsampled_envelope = interp1(t1, complex_envelope, t2);

% IQ upmixer
signal = real(exp(1j * 2 * pi * fc * t2) .* upsampled_envelope);

end