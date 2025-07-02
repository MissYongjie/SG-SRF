clear;
close all;
addpath(genpath(pwd))

%% �������ݼ�
dataset = 'dataset#2'; 
Load_dataset
fprintf(['\n ���ݼ������...... ' '\n'])

%% ��������
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

%% �������� scribble �� weight_map
load('datasets\dataset#2_scribbles.mat');
% ������������� all_data

num_samples = length(scribbles); 

% ��������Ŀ¼
if ~exist('scribble_images', 'dir')
    mkdir('scribble_images');
end
if ~exist('weight_map_images', 'dir')
    mkdir('weight_map_images');
end
if ~exist('CM_images', 'dir')
    mkdir('CM_images');
end

% ��ʼ��ָ������
metrics = zeros(num_samples, 3); % [OA, kappa, F1]

for idx = 1:num_samples
    fprintf('\n ======================================== \n');
    fprintf('���ڴ���� %d/%d �� scribble...\n', idx, num_samples);
    
    scribble_map = scribbles{idx};
    weight_map = weight_maps{idx};
    
    % ����scribble
    scribble_img = uint8(scribble_map) * 255; % logicalתuint8
    scribble_filename = sprintf('scribble_images/scribble_%03d.png', idx);
    imwrite(scribble_img, scribble_filename);
    
    % ����weight_map
    weight_map_norm = uint8(255 * mat2gray(weight_map)); % ��ͨ����һ����[0,255]
    weight_map_filename = sprintf('weight_map_images/weight_map_%03d.png', idx);
    imwrite(weight_map_norm, weight_map_filename);
    
    % ���� Scribble_SRF
    time = clock;
    [regression_t1, regression_t2, DI_t1, DI_t2, CM] = SG_SRF_main(image_t1, image_t2, Ref_gt, scribble_map, weight_map, opt);
    fprintf(['\n ��ǰ����ʱ��: %i ��\n', etime(clock, time)])
    
    % �������ɵı仯���ͼ��CM��
    CM_filename = sprintf('CM_images/CM_%03d.png', idx);
    imwrite(CM, CM_filename);
    
    % ���� CM
    [tp,fp,tn,fn,fplv,fnlv,~,~,OA,kappa] = performance(CM,Ref_gt);
    F1 = 2*tp/(2*tp+fp+fn);
    result = 'SG_SRF: OA is %4.3f; Kc is %4.3f; F1 is %4.3f \n';
    fprintf(result,OA,kappa,F1);
    
    % ����ָ��
    metrics(idx,:) = [OA, kappa, F1];
end

%% ���ܱ�����
save('abs_different_scribbles.mat', 'metrics');
fprintf('\n ����ʵ��ȫ����ɣ�����ͼƬ��ָ���ѱ��棡\n');
