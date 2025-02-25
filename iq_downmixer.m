function complex_envelope = iq_downmixer(signal, osr, br, fc, fs)
    % IQ Downmixer using CIC filter for decimation
    % Input:
    %   signal  - Input modulated signal (RF domain)
    %   osr     - Oversampling rate
    %   br      - Bit rate
    %   fc      - Carrier frequency
    %   fs      - Sampling frequency
    % Output:
    %   complex_envelope - Downmixed baseband signal (complex envelope)

    %% **Step 1: IQ Downmixing（下变频）**
    t = ((1 : numel(signal))' - 1) / fs;
    upsampled_envelope = 2 * exp(-1j * 2 * pi * fc * t) .* signal; % 乘本地振荡器，搬移到基带

    %% **Step 2: Setup CIC Decimator**
    R = round(fs / (br * osr)); % 计算降采样因子，使输出接近目标采样率
    N = 5;  % CIC 级联级数，影响低通滤波效果
    M = 1;  % 差分阶数，通常为 1

    % 创建 Matlab 内置 CIC 降采样滤波器
    cic_decim = dsp.CICDecimator(R, M, N);

    %% **Step 3: Ensure Signal Length is a Multiple of R**
    L = length(upsampled_envelope);
    use_zero_padding = true; % 选择填充 0 还是截断信号

    if use_zero_padding
        padding_size = mod(-L, R);
        if padding_size > 0
            upsampled_envelope = [upsampled_envelope; zeros(padding_size, 1)];
        end
    else
        L_truncated = floor(L / R) * R;
        upsampled_envelope = upsampled_envelope(1:L_truncated);
    end

    %% **Step 4: Apply CIC Filter**
    filtered_signal = cic_decim(upsampled_envelope); % 执行 CIC 低通滤波 + 降采样
    cic_gain = (R * M)^N;
    filtered_signal = filtered_signal / cic_gain;
    %% **Step 5: Adjust Signal Length Using Interpolation**
    original_length = round(length(signal) * (br * osr) / fs); % 目标长度
    actual_length = length(filtered_signal); % 实际长度

    % 进行插值调整，恢复原始信号长度
    t_original = linspace(0, 1, original_length+1);
    t_actual = linspace(0, 1, actual_length);
    complex_envelope = interp1(t_actual, filtered_signal, t_original, 'linear');
    complex_envelope = complex_envelope.';
    complex_envelope = complex_envelope / max(abs(complex_envelope));
end