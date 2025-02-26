function out = agc_gain(in)

% TODO: Implement this yourself!
% TIP: What can the output bits tell you about the signal amplitude
% beforing decoding?
    alpha = 0.01;         % smoothing factor
    target_rms = 0.5;     % RMS(based on adc measuring range)
  
    N = length(in);       % signal length
    out = zeros(size(in));
    power_est = 0;        % short-time power estimate
    
    for n = 1:N
        % Instantaneous power
        inst_power = abs(in(n))^2;
        
        % Update power estimate
        % power_est(n) = (1 - alpha)*power_est(n-1) + alpha*inst_power
        power_est = (1 - alpha)*power_est + alpha * inst_power;
        
        % Cal gain
        if power_est > 0
            gain = target_rms / sqrt(power_est);
        else
            gain = 1;  % 避免除0
        end
        
        % adjust output
        out(n) = in(n) * gain;
    end
    
end

