function complex_envelope = gmsk_modulate(bits, bt, osr)

% convert bits to symbols (+1 / -1)
symbols = bits * 2 - 1;%符号扩展  从0/1 映射到+1 / -1

% apply gaussian filter
filt = gaussian_filter(bt, osr);
data_filtered = conv(repelem(symbols, osr, 1), filt, 'same');%repelem是对符号进行扩展 这样在一个符号周期内，就有更对的采样点
%然后这里把扩展后的数据 和 高斯滤波器 做卷积  所以就会得到filtered之后的data

% calculate phase
phase = [0; cumsum(data_filtered) * 0.5 * pi / osr];%cumsum是求和函数 所以这里是在
%模拟积分的过程  把滤波后的信号逐步累加，形成相位轨迹？
% *0.5是因为要把频率的变化转为相位的变化  /osr是归一化   归一化到符号级别而不是采样点级别
% generate complex envelope
complex_envelope = exp(1j * phase);

end