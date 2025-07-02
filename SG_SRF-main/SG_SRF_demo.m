clear;
close all;
addpath(genpath(pwd));  % Add current folder and subfolders to path / 添加当前目录及子目录到路径

%% ============================================================================
%  Step 1: Load Dataset / 加载数据集
% ============================================================================
dataset = 'dataset#1';   % Set dataset name: dataset#1 ~ dataset#6 / 设置数据集名称
Load_dataset             % Load image_t1, image_t2, Ref_gt, scribble / 加载图像和标注
fprintf('\n 数据加载完成...\n');

%% ============================================================================
%  Step 2: Parameter Configuration / 参数设置
% ============================================================================
opt.Ns = 5000;            % Number of superpixels / 超像素数
opt.lambda = 0.1;         
opt.beta = 1;            
opt.eta = 0.5;           
opt.alfa = 0.05;         
opt.fuse_type = 'dot_fixed_Gradient';  

% Dataset-specific parameter tuning / 针对不同数据集的参数微调
switch dataset
    case {'dataset#4', 'dataset#5'}
        opt.eta = 0.3;
        opt.sigma = 50;
    case 'dataset#6'
        opt.fuse_type = 'dot_fixed';
        opt.eta = 0.5;
        opt.sigma = 60;
    case 'dataset#1'
        opt.sigma = 100;
    case 'dataset#2'
        opt.sigma = 180;
        opt.eta = 0.6;
        opt.alfa = 0.2;
    case 'dataset#3'
        opt.sigma = 70;
end

%% ============================================================================
%  Step 3: Load Scribble Annotations / 加载 Scribble 标注
% ============================================================================
scribble_map = scribble;  % Binary or RGB scribble indicating change region / 用于引导回归的粗标注图

%% ============================================================================
%  Step 4: Run SG-SRF Algorithm / 执行结构回归主流程
% ============================================================================
fprintf('\n 正在执行 Scribble-Guided Structural Regression Fusion...\n');
time = clock;

[regression_t1, regression_t2, DI_t1, DI_t2, CM] = SG_SRF_main( ...
    image_t1, image_t2, Ref_gt, scribble_map, weight_map, opt);

fprintf('\n 总运行时间：%i 秒\n', round(etime(clock, time)));
fprintf('\n======================================================================\n');

%% ============================================================================
%  Step 5: Visualization of Results / 可视化回归与差异图
% ============================================================================
fprintf('\n 显示可视化结果...\n');
figure;
subplot(331); imshow(image_t1);                title('原始影像 t1');
subplot(332); imshow(image_t2);                title('原始影像 t2');
subplot(333); imshow(Ref_gt);                  title('真值图');
subplot(334); imshow(uint8(regression_t1));    title('回归影像 t1');
subplot(335); imshow(uint8(regression_t2));    title('回归影像 t2');
subplot(336); imshow(CM);                      title('变化图');
subplot(337); imshow(remove_outlier(DI_t1), []); title('反向 DI');
subplot(338); imshow(remove_outlier(DI_t2), []); title('正向 DI');
subplot(339); imshow(CMplotRGB(CM, Ref_gt));   title('变化图 RGB');

%% ============================================================================
%  Step 6: PR Curve and AUP Evaluation / 精度召回曲线与AUP评估
% ============================================================================
fprintf('\n 计算 PR 曲线与 AUP...\n');
[Precision_forward, Recall_forward] = PR_plot(DI_t1, Ref_gt, 500);
[Precision_backward, Recall_backward] = PR_plot(DI_t2, Ref_gt, 500);

[AUP_forward, ~] = AUC_Diagdistance(Precision_forward, Recall_forward);
[AUP_backward, ~] = AUC_Diagdistance(Precision_backward, Recall_backward);

figure;
plot(Recall_forward, Precision_forward); hold on;
plot(Recall_backward, Precision_backward);
legend('Forward DI', 'Backward DI');
title('PR Curves');

fprintf('SG_SRF: Forward AUP = %4.3f; Backward AUP = %4.3f\n', AUP_forward, AUP_backward);

%% ============================================================================
%  Step 7: Evaluate CM Performance (OA, Kappa, F1) / 性能评估
% ============================================================================
[tp, fp, tn, fn, ~, ~, ~, ~, OA, kappa] = performance(CM, Ref_gt);
F1 = 2 * tp / (2 * tp + fp + fn);
fprintf('SG_SRF: OA = %4.3f; Kappa = %4.3f; F1 = %4.3f\n', OA, kappa, F1);

if F1 < 0.3
    fprintf('\n F1值过低，请检查参数 eta 是否合适！\n');
end

%% ============================================================================
%  Step 8: Save Outputs / 保存变化图与回归结果
% ============================================================================
fprintf('\n? 正在保存变化图与回归结果...\n');

% Change Map
imwrite(CM, strcat(dataset, '_SG_SRF_CM.png'));
imwrite(CMplotRGB(CM, Ref_gt), strcat(dataset, '_SG_SRF_CM_RGB.png'));

% Regression Results
imwrite(uint8(regression_t1), strcat(dataset, '_SG_SRF_regression_t1.png'));
imwrite(uint8(regression_t2), strcat(dataset, '_SG_SRF_regression_t2.png'));

%% ============================================================================
%  Step 9: Save DI and Thresholded Binary Change Maps / 保存差异图与二值图
% ============================================================================
% === Forward DI ===
DI_t1 = image_normlized(DI_t1, 'optical');
level1 = graythresh(DI_t1);
DI_t1_CM = imbinarize(DI_t1, level1);

imwrite(DI_t1, strcat(dataset, '_SG_SRF_DI_t1.png'));
imwrite(DI_t1_CM, strcat(dataset, '_SG_SRF_DI_t1_CM.png'));
imwrite(CMplotRGB(DI_t1_CM, Ref_gt), strcat(dataset, '_SG_SRF_DI_t1_CM_RGB.png'));

[tp, fp, tn, fn, ~, ~, ~, ~, OA, kappa] = performance(DI_t1_CM, Ref_gt);
F1 = 2 * tp / (2 * tp + fp + fn);
fprintf('SG_SRF_t1: OA = %4.3f; Kappa = %4.3f; F1 = %4.3f\n', OA, kappa, F1);

% === Backward DI ===
DI_t2 = image_normlized(DI_t2, 'optical');
level2 = graythresh(DI_t2);
DI_t2_CM = imbinarize(DI_t2, level2);

imwrite(DI_t2, strcat(dataset, '_SG_SRF_DI_t2.png'));
imwrite(DI_t2_CM, strcat(dataset, '_SG_SRF_DI_t2_CM.png'));
imwrite(CMplotRGB(DI_t2_CM, Ref_gt), strcat(dataset, '_SG_SRF_DI_t2_CM_RGB.png'));

[tp, fp, tn, fn, ~, ~, ~, ~, OA, kappa] = performance(DI_t2_CM, Ref_gt);
F1 = 2 * tp / (2 * tp + fp + fn);
fprintf('SG_SRF_t2: OA = %4.3f; Kappa = %4.3f; F1 = %4.3f\n', OA, kappa, F1);

fprintf('\n 所有处理完成... \n');
