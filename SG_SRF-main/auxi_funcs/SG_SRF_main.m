function [regression_t1, regression_t2, DI_t1, DI_t2, CM] = SG_SRF_main(image_t1, image_t2, Ref_gt, scribble_map, weight_map, opt)
    % 预处理
    image_t1 = double(image_t1);
    image_t2 = double(image_t2);
    h = fspecial('average', 5);
    image_t1 = imfilter(image_t1, h, 'symmetric');
    image_t2 = imfilter(image_t2, h, 'symmetric');

    [Cosup, ~] = GMMSP_Cosegmentation(image_t1, image_t2, opt.Ns);
    
    
    [t1_feature, t2_feature, norm_par] = MMfeature_extraction(Cosup, image_t1, image_t2);

    % 生成权重图
    sigma = opt.sigma; 
    weight_map = exp(-bwdist(scribble_map).^2 / (2 * sigma^2));
    weight_map = weight_map / max(weight_map(:)); % 归一化
    % ---------------聚合 weight_map 到超像素级别-----------------------
    superpixel_weights_mean = zeros(max(Cosup(:)), 1); % 均值
    superpixel_weights_max = zeros(max(Cosup(:)), 1);  % 最大值
    superpixel_weights_min = zeros(max(Cosup(:)), 1);  % 最小值

    for i = 1:max(Cosup(:))
        % 获取当前超像素内的权重值
        current_weights = weight_map(Cosup == i);
        superpixel_weights_mean(i) = mean(current_weights(:)); % 超像素均值
        superpixel_weights_max(i) = max(current_weights(:));   % 超像素最大值
        superpixel_weights_min(i) = min(current_weights(:));   % 超像素最小值
    end

    % 生成 weight_map 的超像素特征矩阵
    % 大小为 3 × N_s，其中 N_s 是超像素的数量
    weight_map_sp = [superpixel_weights_mean'; ...
                           superpixel_weights_max'; ...
                           superpixel_weights_min'; ...
                           superpixel_weights_mean'; ...
                           superpixel_weights_max'; ...
                           superpixel_weights_min'];
    % ---------------聚合 weight_map 到超像素级别-----------------------
    % 结构图
    opt.kmax = round(sqrt(size(t1_feature, 2)) * 1);
    [ADJ_t1] = AdaptiveStructureGraph(t1_feature', t1_feature', opt.kmax);
    [ADJ_t2] = AdaptiveStructureGraph(t2_feature', t2_feature', opt.kmax);
    ADJ_fuse = min(ADJ_t1, ADJ_t2);

    Lx = LaplacianMatrix(ADJ_t1);
    Ly = LaplacianMatrix(ADJ_t2);
    Lf = LaplacianMatrix(ADJ_fuse);

    % 结构回归融合
    [Zx, deltx, Zy, delty, ~] = Scribble_structural_regression_fusion(t1_feature, t2_feature, Lx, Ly, Lf, opt, weight_map_sp);

    % 回归图
    [regression_t1, ~, ~] = suplabel2ImFeature(Cosup, Zy, size(image_t1, 3));
    regression_t1 = DenormImage(regression_t1, norm_par(1:size(image_t1, 3)));
    DI_t1 = suplabel2DI(Cosup, sum(deltx.^2, 1));

    [regression_t2, ~, ~] = suplabel2ImFeature(Cosup, Zx, size(image_t2, 3));
    regression_t2 = DenormImage(regression_t2, norm_par(size(image_t1, 3) + 1:end));
    DI_t2 = suplabel2DI(Cosup, sum(delty.^2, 1));

    % 变化图提取
    fx = sqrt(sum(deltx.^2, 1));
    fy = sqrt(sum(delty.^2, 1));
    [CM, ~] = MRF_CoSegmentation(Cosup, opt.alfa, t1_feature, t2_feature, fx, fy);
end
