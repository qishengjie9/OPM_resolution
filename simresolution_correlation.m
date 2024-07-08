function simresolution_correlation(error_type, error_range, OPM_space, source_distance,SNR, nsims,varargin)
%% Created by Qi shengjie 4/2024
% Use as
%   simlresolution_correlation('gain_error', [0 0.02 0.04 0.06 0.08 0.1], 30,6, 5, 60,varargin)
% where the first argument is the subject info structure (from create_subjects),
% the second is the session number, the third is the frequency range, and
% the fourth is the SNR (db).
% 
%   simlayer_free_energy(...,'param','value','param','value'...) allows
%    additional param/value pairs to be used. Allowed parameters:
%    * surf_dir - directory containing subject surfaces
%    * mri_dir - directory containing subject MRIs
%    * out_file - output file name (automatically generated if not
%    specified)
%    * dipole_moment - 10 (default) or interger - moment of simulated
%    dipole
%    * sim_patch_size - 5 (default) or interger - simulated patch size
%    * nsims - 60 (default) or integer - number of simulations per loop

% Parse inputs
defaults = struct('surf_dir', 'd:\pred_coding\surf', 'mri_dir', 'd:\pred_coding\mri',...
    'dipole_moment', 10, 'sim_patch_size', 3,... 'reconstruct_patch_size', 3, 'nsims', 60);  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end
addpath('E:\mydata\qsj\matlab\spm12')
addpath F:\simulation-OPM
spm('defaults', 'EEG');

%% Set parameters
%SNR             =  [10 20];   % signal-to-noise raio, X log10 (RMSsource/RMSnoise) sensor level
%error_type = 'gain_error';
out_path=fullfile('F:\simulation-paper\simulation-OPM\results',...
    'spatial_resolution',error_type);
out_file = fullfile('data_result\',sprintf('40run_%ddB_%dmm.mat',SNR,source_distance));
surf_path = fullfile('F:\simulation-paper\simulation-OPM',...
    'surf');
pial_mesh = fullfile(surf_path,'cortex_20484.surf.gii');
if exist(out_path,'dir')~=7
    mkdir(out_path);
end
g = gifti(pial_mesh);
Ndipoles = size(g.vertices,1);
%% seed source candidate setup  number of sources, list of vertices to simulate on
rng('default');
simvertind=randperm(Ndipoles); %% random list of vertex indices to simulate sources on

Nerror = length(error_range);
simarray = OPM_space;
Numarray = length(simarray);
meshsourceind = zeros(nsims,1);
for d = 1:nsims
    simpos = g.vertices(simvertind(d),:);
    test = g.vertices();
    test(simvertind(d),:) =[];
    vdist = test(:,1:3)-simpos;
    dist = sqrt(dot(vdist',vdist'));
    [~ , meshsourceind(d)] = min(abs(dist-source_distance));
    if meshsourceind(d)>=simvertind(d)
        meshsourceind(d) = meshsourceind(d)+1;
    end
end
Res = zeros(length(SNR),Numarray,nsims,Nerror);
dist_EBB = zeros(length(SNR),Numarray,nsims,Nerror);
template_file_30mm = fullfile(out_path,'Temp_sim_opm_30mm.mat');
%% simulate data 
for SNRindex = 1:length(SNR)
    for simarrayind=1:Numarray
        bar=waitbar(0,'Calculate progress');
        for run = 1:nsims
            %simpos=D.inv{1}.mesh.tess_mni.vert(simvertind,:);
            %simarrayind = 17;
            simpos=g.vertices(simvertind(run),:);
            simposnearst=g.vertices(meshsourceind(run),:);
            simpostwo = [simpos;simposnearst];
            %simpos=g.vertices(simvertind(200),:);
            %filename=fullfile(out_path, sprintf('sim_opm_%dmm.mat',space(simarray(simarrayind))));
            matlabbatch=[];
            matlabbatch{1}.spm.meeg.source.simulate.D = {template_file_30mm};
%             if simarrayind == 1
%                 matlabbatch{1}.spm.meeg.source.simulate.D = {template_file_20mm};
%             else
%                 matlabbatch{1}.spm.meeg.source.simulate.D = {template_file_40mm};
%             end
            matlabbatch{1}.spm.meeg.source.simulate.val = 1;
            matlabbatch{1}.spm.meeg.source.simulate.prefix = ['pos_' num2str(run) '_' num2str(SNR),'snr_']; % prefix for datafile
            %matlabbatch{1}.spm.meeg.source.simulate.prefix = ['Temp_']; % prefix for datafile
            matlabbatch{1}.spm.meeg.source.simulate.whatconditions.all = 1;
            matlabbatch{1}.spm.meeg.source.simulate.isinversion.setsources.woi = [100 1000];               % time window, ms
            matlabbatch{1}.spm.meeg.source.simulate.isinversion.setsources.isSin.fband = [10 40];              % simulation frequency,  Hz
            matlabbatch{1}.spm.meeg.source.simulate.isinversion.setsources.dipmom = [params.dipole_moment,params.sim_patch_size;params.dipole_moment,params.sim_patch_size];                 % dipole strength, nAm
            matlabbatch{1}.spm.meeg.source.simulate.isinversion.setsources.locs = [simpostwo];   % simulation location, mm
            %matlabbatch{1}.spm.meeg.source.simulate.isSNR.setSNR = SNR;                                 % signal-to-noise raio, X log10 (RMSsource/RMSnoise) sensor level
            matlabbatch{1}.spm.meeg.source.simulate.isSNR.setSNR = SNR(SNRindex);                                 % signal-to-noise raio, X log10 (RMSsource/RMSnoise) sensor level
            %matlabbatch{1}.spm.meeg.source.simulate.isSNR.whitenoise = 100; %set whitenoise 100fT in the frequency bandwidth                           
            [a,~]=spm_jobman('run', matlabbatch);
            simfile=cell2mat(a{1}.D);
            close all
         
            for errindex = 1:Nerror
                switch error_type
                    case 'crosstalk_error'
                        prefix = ['pos_' num2str(run) '_' num2str(SNR(SNRindex)),'snr_'];
                        error_simfile = fullfile(out_path,[prefix,sprintf('sim_opm_%dmm_crosstalk_%d.mat',simarray(simarrayind),errindex)]);
                        matlabbatch = [];
                        matlabbatch{1}.spm.meeg.other.copy.D = {simfile};
                        matlabbatch{1}.spm.meeg.other.copy.outfile = error_simfile;
                        spm_jobman('run', matlabbatch);
                        tmp_file = crosstalk_err(error_simfile,error_range(errindex));
                    case 'gain_error'
                        prefix = ['pos_' num2str(run) '_snr_' num2str(SNR(SNRindex))];
                        error_simfile = fullfile(out_path,[prefix,sprintf('sim_opm_%dmm_gain_%d.mat',simarray(simarrayind),errindex)]);
                        matlabbatch = [];
                        matlabbatch{1}.spm.meeg.other.copy.D = {simfile};
                        matlabbatch{1}.spm.meeg.other.copy.outfile = error_simfile;
                        spm_jobman('run', matlabbatch);
                        sim=load(error_simfile);
                        D = sim.D;
                        D.data(:,:) = gain_error(D.data(),error_range(errindex));
                        save(error_simfile,'D');                                            
                    case 'angular_error'
                        prefix = ['pos_' num2str(run) '_snr_' num2str(SNR(SNRindex))];
                        error_simfile = fullfile(out_path,[prefix,sprintf('sim_opm_%dmm_angular_%d.mat',simarray(simarrayind),errindex)]);
                        matlabbatch = [];
                        matlabbatch{1}.spm.meeg.other.copy.D = {simfile};
                        matlabbatch{1}.spm.meeg.other.copy.outfile = error_simfile;
                        spm_jobman('run', matlabbatch);
                        error_simfile = angular_err(error_simfile,errindex,error_range(errindex));
                end
                for methind=1:1, %4 inverse method
                     matlabbatch = [];
                    tmp_path=fullfile(out_path,[sprintf('run_%dsnr_%d_crosstalk_%d',run,SNR(SNRindex),error_range(errindex))]);
                    if exist(tmp_path,'dir')~=7
                        mkdir(tmp_path);
                    end
                    files_BF      = fullfile(tmp_path,'BF.mat');
                    % Imports data into DAiSS ecosystem
                    matlabbatch{1}.spm.tools.beamforming.data.dir = {tmp_path};
                    matlabbatch{1}.spm.tools.beamforming.data.D(1) = {error_simfile};
                    matlabbatch{1}.spm.tools.beamforming.data.val = 1;
                    matlabbatch{1}.spm.tools.beamforming.data.gradsource = 'inv';
                    matlabbatch{1}.spm.tools.beamforming.data.space = 'MNI-aligned';
                    matlabbatch{1}.spm.tools.beamforming.data.overwrite = 1;  
                    matlabbatch{2}.spm.tools.beamforming.sources.BF(1) = {files_BF};
                    matlabbatch{2}.spm.tools.beamforming.sources.reduce_rank = [2 3];
                    matlabbatch{2}.spm.tools.beamforming.sources.keep3d = 1;
                    matlabbatch{2}.spm.tools.beamforming.sources.plugin.mesh.orient = 'original';
                    matlabbatch{2}.spm.tools.beamforming.sources.plugin.mesh.fdownsample = 1;
                    matlabbatch{2}.spm.tools.beamforming.sources.plugin.mesh.symmetric = 'no';
                    matlabbatch{2}.spm.tools.beamforming.sources.plugin.mesh.flip = false;
                    matlabbatch{2}.spm.tools.beamforming.sources.visualise = 1;
%                     matlabbatch = [];
                    % Generate covariace matrix
                    matlabbatch{3}.spm.tools.beamforming.features.BF = {files_BF};
                    matlabbatch{3}.spm.tools.beamforming.features.whatconditions.all = 1;
                    matlabbatch{3}.spm.tools.beamforming.features.woi = [-Inf Inf];
                    matlabbatch{3}.spm.tools.beamforming.features.modality = {'MEG'};
                    matlabbatch{3}.spm.tools.beamforming.features.fuse = 'no';
                    matlabbatch{3}.spm.tools.beamforming.features.plugin.tdcov.foi = [1 48];
                    matlabbatch{3}.spm.tools.beamforming.features.plugin.tdcov.ntmodes = [4];
                    matlabbatch{3}.spm.tools.beamforming.features.plugin.tdcov.taper = 'none';
                    matlabbatch{3}.spm.tools.beamforming.features.regularisation.manual.lambda = 0;
                    matlabbatch{3}.spm.tools.beamforming.features.bootstrap = false;
    
                    [a b] = spm_jobman('run',matlabbatch);
                  matlabbatch = [];
                matlabbatch{1}.spm.tools.beamforming.inverse.BF = {files_BF};
                matlabbatch{1}.spm.tools.beamforming.inverse.plugin.ebb.keeplf = false;
                matlabbatch{1}.spm.tools.beamforming.inverse.plugin.ebb.corr = false;
                matlabbatch{1}.spm.tools.beamforming.inverse.plugin.ebb.iid = false;
                % Source power estimation
                matlabbatch{2}.spm.tools.beamforming.output.BF(1) = {files_BF};            
                matlabbatch{2}.spm.tools.beamforming.output.plugin.sourcedata_robust.method = 'keep';      
                [a b] = spm_jobman('run',matlabbatch);

                load(files_BF,'output');
                J = cell2mat(output.sourcedata.MEG.ftdata.trial);
                R2 = corrcoef(J(simvertind(run),:),J(meshsourceind(run),:));
                Res(SNRindex,simarrayind,run,errindex)=abs(R2(1,2));                
               end    
            end
         waitbar(run/nsims,bar);     
        end
    end
end
save(fullfile(out_path,params.out_file),'Res');
