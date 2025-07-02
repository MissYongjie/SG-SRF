function [regression_t1, regression_t2, DI_t1, DI_t2, CM] = SG_SRF_main(image_t1, image_t2, Ref_gt, scribble_map, weight_map, opt)
    % Ԥ����
    image_t1 = double(image_t1);
    image_t2 = double(image_t2);
    h = fspecial('average', 5);
    image_t1 = imfilter(image_t1, h, 'symmetric');
    image_t2 = imfilter(image_t2, h, 'symmetric');

    [Cosup, ~] = GMMSP_Cosegmentation(image_t1, image_t2, opt.Ns);
    
    
    [t1_feature, t2_feature, norm_par] = MMfeature_extraction(Cosup, image_t1, image_t2);

    % ����Ȩ��ͼ
    sigma = opt.sigma; 
    weight_map = exp(-bwdist(scribble_map).^2 / (2 * sigma^2));
    weight_map = weight_map / max(weight_map(:)); % ��һ��
    % ---------------�ۺ� weight_map �������ؼ���-----------------------
    superpixel_weights_mean = zeros(max(Cosup(:)), 1); % ��ֵ
    superpixel_weights_max = zeros(max(Cosup(:)), 1);  % ���ֵ
    superpixel_weights_min = zeros(max(Cosup(:)), 1);  % ��Сֵ

    for i = 1:max(Cosup(:))
        % ��ȡ��ǰ�������ڵ�Ȩ��ֵ
        current_weights = weight_map(Cosup == i);
        superpixel_weights_mean(i) = mean(current_weights(:)); % �����ؾ�ֵ
        superpixel_weights_max(i) = max(current_weights(:));   % ���������ֵ
        superpixel_weights_min(i) = min(current_weights(:));   % ��������Сֵ
    end

    % ���� weight_map �ĳ�������������
    % ��СΪ 3 �� N_s������ N_s �ǳ����ص�����
    weight_map_sp = [superpixel_weights_mean'; ...
                           superpixel_weights_max'; ...
                           superpixel_weights_min'; ...
                           superpixel_weights_mean'; ...
                           superpixel_weights_max'; ...
                           superpixel_weights_min'];
    % ---------------�ۺ� weight_map �������ؼ���-----------------------
    % �ṹͼ
    opt.kmax = round(sqrt(size(t1_feature, 2)) * 1);
    [ADJ_t1] = AdaptiveStructureGraph(t1_feature', t1_feature', opt.kmax);
    [ADJ_t2] = AdaptiveStructureGraph(t2_feature', t2_feature', opt.kmax);
    ADJ_fuse = min(ADJ_t1, ADJ_t2);

    Lx = LaplacianMatrix(ADJ_t1);
    Ly = LaplacianMatrix(ADJ_t2);
    Lf = LaplacianMatrix(ADJ_fuse);

    % �ṹ�ع��ں�
    [Zx, deltx, Zy, delty, ~] = Scribble_structural_regression_fusion(t1_feature, t2_feature, Lx, Ly, Lf, opt, weight_map_sp);

    % �ع�ͼ
    [regression_t1, ~, ~] = suplabel2ImFeature(Cosup, Zy, size(image_t1, 3));
    regression_t1 = DenormImage(regression_t1, norm_par(1:size(image_t1, 3)));
    DI_t1 = suplabel2DI(Cosup, sum(deltx.^2, 1));

    [regression_t2, ~, ~] = suplabel2ImFeature(Cosup, Zx, size(image_t2, 3));
    regression_t2 = DenormImage(regression_t2, norm_par(size(image_t1, 3) + 1:end));
    DI_t2 = suplabel2DI(Cosup, sum(delty.^2, 1));

    % �仯ͼ��ȡ
    fx = sqrt(sum(deltx.^2, 1));
    fy = sqrt(sum(delty.^2, 1));
    [CM, ~] = MRF_CoSegmentation(Cosup, opt.alfa, t1_feature, t2_feature, fx, fy);
end
