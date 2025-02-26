function IQ_synced = costas_loop(IQ_signal, loop_gain)
    % 提取 I 和 Q 分量
    I = real(IQ_signal);
    Q = imag(IQ_signal);
    
    % 初始化相位误差
    phase_error = 0.02;
    
    % 生成本地载波（相位调整）
    for k = 1:length(IQ_signal)
        local_cos = cos(phase_error);
        local_sin = sin(phase_error);
        
        % 旋转 IQ 以补偿相位误差
        I_corr(k) = I(k) * local_cos - Q(k) * local_sin;
        Q_corr(k) = I(k) * local_sin + Q(k) * local_cos;
        
        % 计算误差信号（Costas 误差）
        phase_error = phase_error + loop_gain * (I_corr(k) * Q_corr(k));
    end
    
    IQ_synced = I_corr + 1j * Q_corr; % 重新组合 IQ
end
