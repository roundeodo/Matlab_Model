function root = buildVaricodeTree(table)
    % 初始化根节点
    root = struct('left', [], 'right', [], 'ascii', []);

    % 遍历所有码字
    for asciiVal = 1:length(table)
        codeStr = table(asciiVal);  % 形如 "101011" 等
        node = root;
        % 对码字逐字符插入
        for c = codeStr
            if c == '0'
                if isempty(node.left)
                    node.left = struct('left', [], 'right', [], 'ascii', []);
                end
                node = node.left;
            elseif c == '1'
                if isempty(node.right)
                    node.right = struct('left', [], 'right', [], 'ascii', []);
                end
                node = node.right;
            else
                error('Varicode code has invalid character (not 0 or 1).');
            end
        end

        % 在叶子节点存储 ASCII 值(减1是因为你的表里 ascii= i-1)
        node.ascii = asciiVal - 1;
    end
end
