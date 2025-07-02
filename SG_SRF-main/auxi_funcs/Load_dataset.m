if strcmp(dataset,'dataset#1') == 1 
    load('datasets\hetdata\dataset#1.mat')
    opt.type_t1 = 'optical';
    opt.type_t2 = 'optical';
elseif strcmp(dataset,'dataset#2') == 1 
    load('datasets\hetdata\dataset#2.mat')
    opt.type_t1 = 'optical';
    opt.type_t2 = 'optical';
elseif strcmp(dataset,'dataset#3') == 1 
    load('datasets\hetdata\dataset#3.mat')
    opt.type_t1 = 'optical';
    opt.type_t2 = 'optical';   
elseif strcmp(dataset,'dataset#4') == 1 
    load('datasets\hetdata\dataset#4.mat')
    opt.type_t1 = 'sar';
    opt.type_t2 = 'optical';  
elseif strcmp(dataset,'dataset#5') == 1 
    load('datasets\hetdata\dataset#5.mat')
    opt.type_t1 = 'sar';
    opt.type_t2 = 'optical';
elseif strcmp(dataset,'dataset#6') == 1 
    load('datasets\hetdata\dataset#6.mat')
    opt.type_t1 = 'optical';
    opt.type_t2 = 'sar';
elseif strcmp(dataset,'beijing_A') == 1 
    load('datasets\homodata\beijing_A.mat')
    opt.type_t1 = 'optical';
    opt.type_t2 = 'optical';  
elseif strcmp(dataset,'beijing_B') == 1 
    load('datasets\homodata\beijing_B.mat')
    opt.type_t1 = 'optical';
    opt.type_t2 = 'optical';  
elseif strcmp(dataset,'yellow_A') == 1 
    load('datasets\homodata\yellow_A.mat')
    opt.type_t1 = 'sar';
    opt.type_t2 = 'sar'; 
elseif strcmp(dataset,'yellow_B') == 1 
    load('datasets\homodata\yellow_B.mat')
    opt.type_t1 = 'sar';
    opt.type_t2 = 'sar';
elseif strcmp(dataset,'yellow_C') == 1 
    load('datasets\homodata\yellow_C.mat')
    opt.type_t1 = 'sar';
    opt.type_t2 = 'sar'; 
elseif strcmp(dataset,'yellow_D') == 1 
    load('datasets\homodata\yellow_D.mat')
    opt.type_t1 = 'sar';
    opt.type_t2 = 'sar'; 
elseif strcmp(dataset,'California') == 1 
    load('datasets\hetdata\California.mat')
    opt.type_t1 = 'optical';
    opt.type_t2 = 'optical';     
end
%% ensure Ref_gt is binary
unique_values = unique(Ref_gt);
if numel(unique_values) == 2
    disp('Ref_gt is already binary.');
    if ~all(ismember(unique_values, [0,1]))
        Ref_gt = (Ref_gt == max(unique_values));
        disp('Converted Ref_gt to 0 and 1.');
    end
else
    disp('Ref_gt is not binary, converting...');
    Ref_gt = double(Ref_gt > 125);
end

%% plot images
figure;
subplot(131);imshow(image_t1);title('imaget1')
subplot(132);imshow(image_t2);title('imaget2')
subplot(133);imshow(Ref_gt,[]);title('Refgt')
