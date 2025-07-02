clear;
close all
addpath(genpath(pwd))

%% 加载数据集
dataset = 'dataset#1';
Load_dataset
fprintf(['\n 数据加载完成...... ' '\n'])

%% 加载scribble标注
scribble_map = scribble;

%% 设定Ns列表
Ns_list = 1000:500:5000; % 1000, 1500, ..., 5000
results = []; % 保存不同Ns的性能结果

for Ns_idx = 1:length(Ns_list)
    fprintf('\n ================================ \n');
    fprintf(' Running with opt.Ns = %d \n', Ns_list(Ns_idx));
    fprintf(' ================================ \n');

    %% 参数设置
    opt.Ns = Ns_list(Ns_idx);
    opt.lambda = 0.1;
    opt.beta = 1;
    opt.eta = 0.5;
    opt.alfa = 0.05;
    opt.fuse_type = 'dot_fixed_Gradient';
    
    % 不同数据集微调
    if strcmp(dataset,'dataset#4') || strcmp(dataset,'dataset#5')
        opt.eta = 0.3;
        opt.alfa = 0.05;
        opt.sigma = 50;
    elseif strcmp(dataset,'dataset#6')
        opt.fuse_type = 'dot_fixed';
        opt.eta = 0.5;
        opt.alfa = 0.05;
        opt.sigma = 60;
    elseif strcmp(dataset,'dataset#1')
        opt.eta = 0.5;
        opt.alfa = 0.05;
        opt.sigma = 100;
    elseif strcmp(dataset,'dataset#2')
        opt.sigma = 180;
        opt.eta = 0.6;
        opt.alfa = 0.2;
    elseif strcmp(dataset,'dataset#3')
        opt.eta = 0.5;
        opt.alfa = 0.05;
        opt.sigma = 70;
    end

    %% 运行 SG-SRF
    fprintf(['\n 基于 Scribble 的结构回归开始运行...... ' '\n'])
    time = clock;
    [regression_t1, regression_t2, DI_t1, DI_t2, CM] = SG_SRF_main(image_t1, image_t2, Ref_gt, scribble_map, weight_map, opt);
    fprintf('\n 运行时间总计：%i 秒\n', etime(clock,time));
    
    %% 性能评估
    Ref_gt(Ref_gt == 255) = 1;
    [tp, fp, tn, fn, fplv, fnlv, ~, ~, OA, kappa] = performance(CM, Ref_gt);
    F1 = 2*tp/(2*tp+fp+fn);
    fprintf(' 结果: OA = %4.3f, Kappa = %4.3f, F1 = %4.3f\n', OA, kappa, F1);

    % 保存性能指标
    results = [results; [opt.Ns, OA, kappa, F1]];
    
    %% 保存变化检测结果图
    save_folder = 'Abs_SG_SRF_Ns_CM_results'; % 保存文件夹
    if ~exist(save_folder, 'dir')
        mkdir(save_folder);
    end
    filename_cm = fullfile(save_folder, strcat(dataset, '_Ns', num2str(opt.Ns), '_CM.png'));
    filename_cm_rgb = fullfile(save_folder, strcat(dataset, '_Ns', num2str(opt.Ns), '_CM_RGB.png'));
    
    % 保存灰度CM图
    imwrite(uint8(255*mat2gray(CM)), filename_cm);
    % 保存RGB可视化图
    rgb_image = CMplotRGB(CM, Ref_gt);
    imwrite(rgb_image, filename_cm_rgb);
    
    fprintf(' CM saved: %s\n', filename_cm);
    fprintf(' RGB CM saved: %s\n', filename_cm_rgb);
end

%% 保存所有消融实验结果
save('abs_different_Ns.mat', 'results');

%% 打印整体结果
fprintf(dataset);
fprintf('\nFinal Results:\n');
fprintf('Ns\tOA\tKappa\tF1\n');
for i = 1:size(results,1)
    fprintf('%d\t%.4f\t%.4f\t%.4f\n', results(i,1), results(i,2), results(i,3), results(i,4));
end
