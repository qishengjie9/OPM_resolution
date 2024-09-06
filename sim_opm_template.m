%% Script for analysis the effect of the calibration error on the OPM array performance
%% Results presented in Qishengjie ....
%% Created by Qi shengjie 3/2023
clc
clear all
%a = load_nii('lhpial.nii');
addpath('E:\mydata\qsj\code1\matlab\spm12')
spm('defaults', 'eeg')
%rawfile=fullfile('F:\simulation-paper\simulation-OPM\sim_opm.mat');

%% Setup simulation - number of sources, list of vertices to simulate on
out_path=fullfile('F:\simulation-paper\simulation-OPM\results',...
    'spatial_resolution\original_code_dual_axis');
surf_path = fullfile('F:\simulation-paper\simulation-OPM',...
    'surf');
pial_mesh = fullfile(surf_path,'cortex_20484.surf.gii');
if exist(out_path,'dir')~=7
    mkdir(out_path);
end
% if exist(surf_path,'dir')~=7
%     mkdir(surf_path);
% end
g = gifti(pial_mesh);
Ndipoles = size(g.vertices,1);
rng('default');
simvertind=randperm(Ndipoles); %% random list of vertex indices to simulate sources on
simpos=g.vertices(simvertind(1),:);
%% Simulation opm array - Template MRI file, custom  sensor spacing

space = [30];
Narray = size(space,2);
for i = 1:Narray
    S =[];
    S.space = space(i);
    S.meshres = 3;
    %S.data = 'bemgfbinfspmeeg_fingertest_LUCIA_20120223_06.mat';
    S.offset = 6.5;
    %S.data = zeros(1,1000,2);
    S.wholehead = 0;
    S.axis = 2;
    S.fname = sprintf('sim_opm_%dmm',S.space);
    D = spm_opm_sim(S);
    newfile=fullfile(out_path, sprintf('sim_opm_%dmm.mat',S.space));
    save(newfile,'D');
    %save('newfile','D')
end
%filename=fullfile(out_path, sprintf('sim_opm_%dmm.mat',space(simarrayind)));
matlabbatch = [];
matlabbatch{1}.spm.meeg.source.simulate.D = {newfile};
matlabbatch{1}.spm.meeg.source.simulate.val = 1;
matlabbatch{1}.spm.meeg.source.simulate.prefix = 'Temp_';
matlabbatch{1}.spm.meeg.source.simulate.whatconditions.all = 1;
matlabbatch{1}.spm.meeg.source.simulate.isinversion.setsources.woi = [0 1000];
matlabbatch{1}.spm.meeg.source.simulate.isinversion.setsources.isSin.foi = [10];
matlabbatch{1}.spm.meeg.source.simulate.isinversion.setsources.dipmom = [10];
matlabbatch{1}.spm.meeg.source.simulate.isinversion.setsources.locs = [simpos];
matlabbatch{1}.spm.meeg.source.simulate.isSNR.setSNR = 0;
[a,~]=spm_jobman('run',matlabbatch)
simfile=cell2mat(a{1}.D);
a=2;