clear
 close all


%% Settings

% baseband modeling parameters
use_fec = true; % enable/disable forward error correction
bt = 0.5; % gaussian filter bandwidth
snr = 12; % in-band signal to noise ratio (dB)
osr = 16; % oversampling ratio

% RF modeling parameters
use_rf = true; % enable/disable RF model
adc_levels = 32; % number of ADC output codes (NB: #bits = log2[#levels])
br = 100; % bit rate (bit/s)
fc = 20.0e3; % carrier frequency (Hz)
fs = 50e3; % sample frequency (Hz)

% plotting parameters
plot_raw_data = true;
plot_rf_signal = true;

% input message
message_in = 'abcdefghijklmnopqrstuvwxyz';
disp(message_in);


%% Modulation

% varicode encoding
plain_in = varicode_encode(message_in);

% FEC encoding (optional)
if use_fec
    encoded_in = fec_encode(plain_in);
else
    encoded_in = plain_in;
end

% GMSK modulation
complex_envelope_in = gmsk_modulate(encoded_in, bt, osr);

% upmixing
if use_rf
    signal_in = iq_upmixer(complex_envelope_in, osr, br, fc, fs);
end


%% Channel model

% add noise
if use_rf
    signal_out = signal_add_noise(signal_in, snr, br, fs);
else
    complex_envelope_out = complex_envelope_add_noise(complex_envelope_in, snr, osr);
end


%% Demodulation

if use_rf
    
    % automatic gain control
    signal_agc = agc_gain(signal_out);
    
    % quantization
    signal_quantized = quantize(signal_agc, adc_levels);
    
    % downmixing
    complex_envelope_out = iq_downmixer(signal_quantized, osr, br, fc, fs);
    
end

% GMSK demodulation
raw_out = gmsk_demodulate(complex_envelope_out, osr);

% clock recovery
clock_out = clock_recovery(raw_out, osr);

% extract bits
encoded_out = extract_bits(raw_out, clock_out, osr);

% FEC decoding (optional)
if use_fec
    plain_out = fec_decode(encoded_out);
else
    plain_out = encoded_out;
end

% varicode decoding
message_out = varicode_decode(plain_out);
ascii_array = str2double(message_out);
str = sprintf('%c',ascii_array);
disp(str);
%% Plotting

raw_in = repelem(encoded_in * 2 - 1, osr, 1);

if plot_raw_data
    figure('Name', 'Raw data');
    time_in = ((1 : numel(raw_in))' - 1) / osr;
    time_out = ((1 : numel(raw_out))' - 1) / osr;
    h = plot(time_in, raw_in, '-', ...
             time_out, raw_out, '-', ...
             clock_out, encoded_out * 2 - 1, 'sk');
    set(h, {'MarkerFaceColor'}, get(h, 'Color')); 
    grid();
end

if plot_rf_signal && use_rf
    figure('Name', 'RF signal');
    time_in = ((1 : numel(signal_in))' - 1) / osr;
    time_out = ((1 : numel(signal_out))' - 1) / osr;
    plot(time_in, signal_in, '-', ...
         time_out, signal_out, '-');
    grid();
end

% %% complex_envelope_in Plotting
% t = (1:length(complex_envelope_in)); % 时间索引
% figure;
% subplot(2,1,1);
% plot(t, real(complex_envelope_in)); % 画 I 分量
% title('实部 I (In-phase component)');
% xlabel('样本索引');
% ylabel('幅度');
% grid on;
% 
% subplot(2,1,2);
% plot(t, imag(complex_envelope_in)); % 画 Q 分量
% title('虚部 Q (Quadrature component)');
% xlabel('样本索引');
% ylabel('幅度');
% grid on;
% 
% figure;
% plot(t, abs(complex_envelope_in)); % 画出幅度
% title('复包络幅度 |complex\_envelope|');
% xlabel('样本索引');
% ylabel('幅度');
% grid on;
% 
% figure;
% plot(t, angle(complex_envelope_in)); % 画出相位
% title('复包络的相位 angle(complex\_envelope)');
% xlabel('样本索引');
% ylabel('相位 (弧度)');
% grid on;
% 
% 
% figure;
% plot(real(complex_envelope_in), imag(complex_envelope_in), '.');
% title('GMSK IQ 轨迹');
% xlabel('I 分量');
% ylabel('Q 分量');
% axis equal;
% grid on;
% 
% %% Plotting upmixed signal
% t = (0:length(signal_in)-1); % 时间索引
% figure;
% plot(t, signal_in);
% title('上变频后信号的时域波形');
% xlabel('样本索引');
% ylabel('幅度');
% grid on;
% 
% 
% N = length(signal_in); % 信号长度
% f = (-N/2:N/2-1) * (fs/N); % 频率轴
% 
% % 计算 FFT
% S_f = fftshift(abs(fft(signal_in)));
% 
% % 画出频谱
% figure;
% plot(f, S_f);
% title('上变频后信号的频谱');
% xlabel('频率 (Hz)');
% ylabel('幅度');
% grid on;
