function [I_out, Q_out] = cordic(I_in, Q_in, fc, fs)
    % CORDIC定点下变频混频（修复维度错误版）
    % 输入：
    %   I_in, Q_in : 实部和虚部信号（必须为列向量）
    %   fc         : 载波频率 (Hz)
    %   fs         : 采样率 (Hz)
    % 输出：
    %   I_out, Q_out : 下变频后的基带信号
    
    %% === 参数设置 ===
    iter = 10;          % CORDIC迭代次数
    word_len = 12;      % 定点总位宽
    frac_len = 10;      % 小数位宽
    
    %% === 输入维度检查 ===
    if ~iscolumn(I_in) || ~iscolumn(Q_in)
        error('输入I_in和Q_in必须为列向量!');
    end
    num_samples = length(I_in);
    
    %% === 初始化相位累加器 ===
    persistent phase_acc;
    if isempty(phase_acc)
        phase_acc = fi(0, 1, word_len, frac_len); % 初始相位为0
    end
    
    %% === 预计算CORDIC参数 ===
    % 旋转角度表（定点）
    angles = fi(atan(2.^-(0:iter-1)), 1, word_len, frac_len);
    % 增益补偿因子（定点）
    K = fi(prod(1./sqrt(1 + 2.^(-2*(0:iter-1)))), 1, word_len, frac_len);
    
    %% === 相位增量计算（定点） ===
    phase_inc = fi(-2*pi*fc/fs, 1, word_len, frac_len); % 注意负号
    
    %% === 主处理循环（逐个采样点处理） ===
    I_out = zeros(num_samples, 1, 'double');
    Q_out = zeros(num_samples, 1, 'double');
    
    for n = 1:num_samples
        % 更新相位累加器（模拟NCO）
        phase_acc(:) = phase_acc + phase_inc;
        current_phase = fi(phase_acc, 1, word_len, frac_len);
        
        % 初始化CORDIC变量（每个采样点独立）
        x = fi(I_in(n) * K, 1, word_len, frac_len);
        y = fi(Q_in(n) * K, 1, word_len, frac_len);
        z = fi(current_phase, 1, word_len, frac_len);
        
        % CORDIC迭代核心
        for i = 1:iter
            % 确定旋转方向（d为标量值）
            if z < 0
                d = -1;
            else
                d = 1;
            end
            
            % 算术右移（等效乘法）
            y_shifted = bitsra(y, i-1);
            x_shifted = bitsra(x, i-1);
            
            % 更新坐标（确保所有变量为标量）
            x_new = x - d * y_shifted;
            y_new = y + d * x_shifted;
            z = z - d * angles(i);
            
            % 传递到下一迭代
            x = x_new;
            y = y_new;
        end
        
        % 保存当前采样点结果（转换为双精度）
        I_out(n) = double(x);
        Q_out(n) = double(y);
    end
end