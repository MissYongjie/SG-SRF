function [Zx, deltx, Zy, delty, RelDiff] = Scribble_structural_regression_fusion(X, Y, Lx, Ly, Lf, opt, weight_map)
    Niter = 10; % 最大迭代次数
    lambdax = opt.lambda;
    lambday = opt.lambda;
    beta = opt.beta;
    eta = opt.eta;
    u1 = 0.4;
    u2 = 0.4;

    [My, N] = size(Y);
    [Mx, ~] = size(X);

    % 保证 weight_map 大小一致
    if size(weight_map, 1) ~= My || size(weight_map, 2) ~= N
        weight_map = imresize(weight_map, [My, N]);
    end

    % 初始化变量
    deltx = zeros(My, N);
    Px = zeros(My, N);
    W1x = zeros(My, N);
    W2x = zeros(My, N);

    delty = zeros(Mx, N);
    Py = zeros(Mx, N);
    W1y = zeros(Mx, N);
    W2y = zeros(Mx, N);

    inv_TxmuI = inv(4 * Lx + u1 * eye(N));
    inv_TymuI = inv(4 * Ly + u1 * eye(N));
    inv_TfmuI = inv(4 * Lf * beta + u2 * eye(N));

    for i = 1:Niter
        deltx_old = deltx;
        delty_old = delty;

        % Z 更新
        Zx = (u1 * (Y + deltx) - W1x) * inv_TxmuI;
        Qx = (u1 * Zx - u1 * Y + W1x + u2 * Px - W2x) ./ (u1 + u2);
        deltx = delt_update(Qx .* weight_map, deltx, delty, lambdax, eta, u1 + u2, 21, opt.fuse_type);

        Px = (u2 * deltx + W2x) * inv_TfmuI;

        W1x = W1x + u1 * (Zx - Y - deltx);
        W2x = W2x + u2 * (deltx - Px);

        Zy = (u1 * (X + delty) - W1y) * inv_TymuI;
        Qy = (u1 * Zy - u1 * X + W1y + u2 * Py - W2y) ./ (u1 + u2);
        delty = delt_update(Qy .* weight_map, delty, deltx, lambday, eta, u1 + u2, 21, opt.fuse_type);

        Py = (u2 * delty + W2y) * inv_TfmuI;

        W1y = W1y + u1 * (Zy - X - delty);
        W2y = W2y + u2 * (delty - Py);

        % 计算相对变化
        RelDiff(i) = norm(deltx - deltx_old, 'fro') / norm(deltx, 'fro') + ...
                     norm(delty - delty_old, 'fro') / norm(delty, 'fro');
        if i > 3 && RelDiff(i) < 1e-2
            break;
        end
    end
end
