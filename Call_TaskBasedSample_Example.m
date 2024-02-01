%% Task-based sampling auxillary script
% Author: Natalie Baughan, MIDRC TDP 3d, March 2023
% Updates: Heather Whitney, January 2024
% Contact: hwhitney@uchicago.edu

%Task based sampling begins with the identification of cases relevant for a 
% specific task and target population demographic characteristics (such as 
% age range, COVID status, and imaging modality). Then, optimized quota sampling 
% is conducted by randomly sampling cases until the maximum category margin 
% (Baughan et al. 2022) is less than a pre-specified value. N. Baughan et al., 
% "Task-Based Sampling of the MIDRC Sequestered Data Commons for Algorithm 
% Performance Evaluation,” presented at Annual Meeting of the American Association 
% of Physicists in Medicine, 2022, E257–E258)

clear all, close all
%% Specify margin
threshold = 0.10; % fraction (not percentage)
%% Specify making figures (1) or not (0);
mkFigures = 1;
%% Identify source folders
folder_target = '';
folder_input = '';
folder_outputTemplate = '.../Task-based-sampling-main/Output_templates/';
folder_output = '.../Task-based-sampling-main/Output/';
folder_figures = '.../Task-based-sampling-main/figures/';
%% Specify location of target distributions
% change this file according to any changes you wish to make to target
% distributions (i.e., your local population)
inputTarget = readtable(folder_target + "MIDRC_TaskBasedSample_TargetSpecification_DemoExample.xlsx");
inputTarget = table2array(inputTarget(:,3));

%% Identify name of output template
template = 'MIDRC_TaskBasedSample_OutputDistributions.xlsx';

%% Read in input data
% example provided from MIDRC GitHub is from https://doi.org/10.60701/P67C-YW55
[filename,filepath] = uigetfile('.csv','Select the input data file');
% Verify fields read in with correct data type
inputfile = filepath + string(filename);
opts = detectImportOptions(inputfile);
opts = setvartype(opts, 'submitter_id', 'char');  
opts = setvartype(opts, 'age_at_index', 'double'); 
data = readtable(inputfile, opts);

% Check for duplicates 
ptcount = unique(data.submitter_id);

if length(ptcount) ~= height(data)
    fprintf("WARNING: %d duplicate patients in batch \n",(height(data)-length(ptcount)))
end

%% Clean Data 1: Label 'Not Reported'
% sex race ethnicity age_at_index covid19_positive site_id modality

for i = 1:size(data,1)
    if data.sex(i) == ""
        data.sex{i} = 'Not Reported';
    end
    if data.ethnicity(i) == ""
        data.ethnicity{i} = 'Not Reported';
    end
    if data.race(i) == ""
        data.race{i} = 'Not Reported';
    end
    if data.covid19_positive(i) == ""
        data.covid19_positive{i} = 'Not Reported';
    end
    if isnan(data.age_at_index(i)) || isempty(data.age_at_index(i))
        data.age_at_index(i) = 999;
    end
end

%% Clean Data 2: Data types (cell --> string)

data.sex = string(data.sex);
data.race = string(data.race);
data.ethnicity = string(data.ethnicity);
data.covid19_positive = string(data.covid19_positive);


%% Clean Data 3: Label modality separately

M = groupcounts(data,'modality');
data.CR = contains(data.modality,"CR");
data.CT = contains(data.modality,"CT");
data.DX = contains(data.modality,"DX");
data.MR = contains(data.modality,"MR");

modalityNames = ["CR";"CT";"DX";"MR"];
ModalityCount = [sum(data.CR);sum(data.CT);sum(data.DX);sum(data.MR)];
M1 = table(modalityNames,ModalityCount);
M1 = sortrows(M1,2,'descend');
modalityNames = M1.modalityNames;

%% Clean Data 4: Make age categorical
% Note agec = 0 is NotReported

data.agec = zeros(length(data.age_at_index),1);
for i = 1:length(data.age_at_index)
    if data.age_at_index(i) <= 17
        data.agec(i) = 1;
    elseif (data.age_at_index(i) > 17 && data.age_at_index(i) <=29)
        data.agec(i) = 2;
    elseif (data.age_at_index(i) > 29 && data.age_at_index(i) <=39)
        data.agec(i) = 3;
    elseif (data.age_at_index(i) > 39 && data.age_at_index(i) <=49)
        data.agec(i) = 4;
    elseif (data.age_at_index(i) > 49 && data.age_at_index(i) <=64)
        data.agec(i) = 5;
    elseif (data.age_at_index(i) > 64 && data.age_at_index(i) <=74)
        data.agec(i) = 6;
    elseif (data.age_at_index(i) > 74 && data.age_at_index(i) <=84)
        data.agec(i) = 7;
    elseif (data.age_at_index(i) > 84 && data.age_at_index(i) <=140)
        data.agec(i) = 8;
    elseif data.age_at_index(i) == 890
        data.agec(i) = 8;
        data.age_at_index(i) = 139;
    end
end


%% Filter major items

% Age
% Example: exclude < 18, not reported
data =  data(data.agec ~= 1,:);
data =  data(data.agec ~= 0,:);

% Modality
idx = zeros(height(data),1);
for i = 1:height(data)
    % Specify modality to keep
    % Two option exmaple: if data.CR(i) == 1 || data.DX(i) == 1
    if data.CT(i) == 1
        idx(i) = 0;
    else
        idx(i) = 1;
    end
end
data(idx == 1,:) = [];

% Body part
% idx = zeros(height(data),1);
% for i = 1:height(data)
%     % Specify body part labels to remove
%     if data.body_part_examined(i) == "ABDOMEN"
%         idx(i) = 1;
%     elseif data.body_part_examined(i) == "PELVIS"
%         idx(i) = 1;
%     else
%         idx(i) = 0;
%     end
% end
% data(idx == 1,:) = [];

% Study description
% studyDescExclude = ["CT CHEST W CONTRAST";"CT CHEST WO";"CT CHEST WO CONTRAST";...
%     "XR CHEST PA/LATERAL"];
% idx = zeros(height(data),1);
% for i = 1:height(data)
%     if ismember(data.study_description(i),studyDescExclude)
%         idx(i) = 1;
%     else
%         idx(i) = 0;
%     end
% end
% data(idx == 1,:) = [];

%% Take only unique patients
% If all other categories are specified in agreement (namely Study
% description and body part, since they are image-level labels) remove
% duplicate patients for optimization
ptcount = unique(data.submitter_id);
[~,ia] = unique(data.submitter_id);
data = data(ia,:);


%% Specify initial distributions

[Ai,Ri,Si,Ei,Ci] = CountTBSCategories(data);
%% Call Task Based Sample

inputTable = data;

[outputTable] = TaskBasedSample(inputTable, inputTarget, threshold, mkFigures);
figure(1)
exportgraphics(gcf, strcat(folder_figures,'deviationMetrics.png'));
figure(2) 
exportgraphics(gcf, strcat(folder_figures, 'maxDeviationMetrics.png'));
figure(3)
exportgraphics(gcf,strcat(folder_figures,'sampleSizeDuringOptimization.png'))

%% Specify final distributions

[A,R,S,E,C] = CountTBSCategories(outputTable);

initialMetrics = [Ai.GroupCount;Ri.GroupCount;Si.GroupCount;Ei.GroupCount;Ci.GroupCount];
finalMetrics = [A.GroupCount;R.GroupCount;S.GroupCount;E.GroupCount;C.GroupCount];

%% Write output in terms of distributions 
copyfile(strcat(folder_outputTemplate,template),folder_output);
temp = strsplit(template,'.');
templateNameOnly = char(temp(1));
evalsheet = strcat(folder_output,templateNameOnly,'_',num2str(threshold*100),'_percent.xlsx');
movefile(strcat(folder_output,template),evalsheet)
writematrix(inputTarget,evalsheet,'Sheet',1,'Range','C3:C28')
writematrix(inputTarget,evalsheet,'Sheet',1,'Range','I3:I28')
writematrix(initialMetrics,evalsheet,'Sheet',1,'Range','D3:D28')
writematrix(finalMetrics,evalsheet,'Sheet',1,'Range','J3:J28')

%% Write output in terms of cohort
% sort 
outputTable = sortrows(outputTable,'submitter_id');
% export
writetable(outputTable,strcat(folder_output,'MIDRC_TaskBasedSample_Cohort','_',num2str(threshold*100),'_percent.xlsx'));

