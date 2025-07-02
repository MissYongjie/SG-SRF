clear;
close all
addpath(genpath(pwd))

%% �������ݼ�
dataset = 'dataset#1';
Load_dataset
fprintf(['\n ���ݼ������...... ' '\n'])

%% ����scribble��ע
scribble_map = scribble;

%% �趨Ns�б�
Ns_list = 1000:500:5000; % 1000, 1500, ..., 5000
results = []; % ���治ͬNs�����ܽ��

for Ns_idx = 1:length(Ns_list)
    fprintf('\n ================================ \n');
    fprintf(' Running with opt.Ns = %d \n', Ns_list(Ns_idx));
    fprintf(' ================================ \n');

    %% ��������
    opt.Ns = Ns_list(Ns_idx);
    opt.lambda = 0.1;
    opt.beta = 1;
    opt.eta = 0.5;
    opt.alfa = 0.05;
    opt.fuse_type = 'dot_fixed_Gradient';
    
    % ��ͬ���ݼ�΢��
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

    %% ���� SG-SRF
    fprintf(['\n ���� Scribble �Ľṹ�ع鿪ʼ����...... ' '\n'])
    time = clock;
    [regression_t1, regression_t2, DI_t1, DI_t2, CM] = SG_SRF_main(image_t1, image_t2, Ref_gt, scribble_map, weight_map, opt);
    fprintf('\n ����ʱ���ܼƣ�%i ��\n', etime(clock,time));
    
    %% ��������
    Ref_gt(Ref_gt == 255) = 1;
    [tp, fp, tn, fn, fplv, fnlv, ~, ~, OA, kappa] = performance(CM, Ref_gt);
    F1 = 2*tp/(2*tp+fp+fn);
    fprintf(' ���: OA = %4.3f, Kappa = %4.3f, F1 = %4.3f\n', OA, kappa, F1);

    % ��������ָ��
    results = [results; [opt.Ns, OA, kappa, F1]];
    
    %% ����仯�����ͼ
    save_folder = 'Abs_SG_SRF_Ns_CM_results'; % �����ļ���
    if ~exist(save_folder, 'dir')
        mkdir(save_folder);
    end
    filename_cm = fullfile(save_folder, strcat(dataset, '_Ns', num2str(opt.Ns), '_CM.png'));
    filename_cm_rgb = fullfile(save_folder, strcat(dataset, '_Ns', num2str(opt.Ns), '_CM_RGB.png'));
    
    % ����Ҷ�CMͼ
    imwrite(uint8(255*mat2gray(CM)), filename_cm);
    % ����RGB���ӻ�ͼ
    rgb_image = CMplotRGB(CM, Ref_gt);
    imwrite(rgb_image, filename_cm_rgb);
    
    fprintf(' CM saved: %s\n', filename_cm);
    fprintf(' RGB CM saved: %s\n', filename_cm_rgb);
end

%% ������������ʵ����
save('abs_different_Ns.mat', 'results');

%% ��ӡ������
fprintf(dataset);
fprintf('\nFinal Results:\n');
fprintf('Ns\tOA\tKappa\tF1\n');
for i = 1:size(results,1)
    fprintf('%d\t%.4f\t%.4f\t%.4f\n', results(i,1), results(i,2), results(i,3), results(i,4));
end
