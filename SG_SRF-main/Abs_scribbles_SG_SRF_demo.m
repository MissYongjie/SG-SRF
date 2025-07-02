clear;
close all;
addpath(genpath(pwd))

%% 加载数据集
dataset = 'dataset#2'; 
Load_dataset
fprintf(['\n 数据加载完成...... ' '\n'])

%% 参数设置
opt.Ns = 5000;
opt.lambda = 0.1;
opt.beta =1;
opt.eta = 0.6;
opt.alfa = 0.05; % MRF segmentation parameter
opt.sigma = 180;
opt.fuse_type = 'dot_fixed_Gradient';

if strcmp(dataset, 'dataset#4') == 1 || strcmp(dataset, 'dataset#5') == 1
    opt.eta = 0.3;
    opt.sigma = 50;
elseif strcmp(dataset, 'dataset#6') == 1
    opt.fuse_type = 'dot_fixed';
    opt.sigma = 60; 
elseif strcmp(dataset, 'dataset#1') == 1 
    opt.sigma = 100;
elseif strcmp(dataset, 'dataset#2') == 1
    opt.sigma = 180;
%     opt.eta = 0.6;
%     opt.alfa = 0.2;
elseif strcmp(dataset, 'dataset#3') == 1 
    opt.sigma = 70;
elseif strcmp(dataset, 'California') == 1 
    opt.lambda = 0.5;
    opt.beta = 20;
    opt.eta = 1;
    opt.alfa = 0.1;
    opt.sigma = 60;
end

%% 加载所有 scribble 和 weight_map
load('datasets\dataset#2_scribbles.mat');
% 假设变量名字是 all_data

num_samples = length(scribbles); 

% 创建保存目录
if ~exist('scribble_images', 'dir')
    mkdir('scribble_images');
end
if ~exist('weight_map_images', 'dir')
    mkdir('weight_map_images');
end
if ~exist('CM_images', 'dir')
    mkdir('CM_images');
end

% 初始化指标数组
metrics = zeros(num_samples, 3); % [OA, kappa, F1]

for idx = 1:num_samples
    fprintf('\n ======================================== \n');
    fprintf('正在处理第 %d/%d 个 scribble...\n', idx, num_samples);
    
    scribble_map = scribbles{idx};
    weight_map = weight_maps{idx};
    
    % 保存scribble
    scribble_img = uint8(scribble_map) * 255; % logical转uint8
    scribble_filename = sprintf('scribble_images/scribble_%03d.png', idx);
    imwrite(scribble_img, scribble_filename);
    
    % 保存weight_map
    weight_map_norm = uint8(255 * mat2gray(weight_map)); % 单通道归一化到[0,255]
    weight_map_filename = sprintf('weight_map_images/weight_map_%03d.png', idx);
    imwrite(weight_map_norm, weight_map_filename);
    
    % 运行 Scribble_SRF
    time = clock;
    [regression_t1, regression_t2, DI_t1, DI_t2, CM] = SG_SRF_main(image_t1, image_t2, Ref_gt, scribble_map, weight_map, opt);
    fprintf(['\n 当前运行时间: %i 秒\n', etime(clock, time)])
    
    % 保存生成的变化检测图（CM）
    CM_filename = sprintf('CM_images/CM_%03d.png', idx);
    imwrite(CM, CM_filename);
    
    % 评估 CM
    [tp,fp,tn,fn,fplv,fnlv,~,~,OA,kappa] = performance(CM,Ref_gt);
    F1 = 2*tp/(2*tp+fp+fn);
    result = 'SG_SRF: OA is %4.3f; Kc is %4.3f; F1 is %4.3f \n';
    fprintf(result,OA,kappa,F1);
    
    % 保存指标
    metrics(idx,:) = [OA, kappa, F1];
end

%% 汇总保存结果
save('abs_different_scribbles.mat', 'metrics');
fprintf('\n 消融实验全部完成，所有图片和指标已保存！\n');
