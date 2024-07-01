function coregfile = crosstalk_err(error_simfile,crosstalkError)

% add crosstalk error for the MEG data
%crosstalkError =0.05;
if crosstalkError == 0
%     matlabbatch = [];
%     matlabbatch{1}.spm.meeg.other.copy.D = {simfile};
%     matlabbatch{1}.spm.meeg.other.copy.outfile = error_simfile;
%     spm_jobman('run', matlabbatch);
    coregfile = error_simfile;
else
%     matlabbatch = [];
%     matlabbatch{1}.spm.meeg.other.copy.D = {simfile};
%     matlabbatch{1}.spm.meeg.other.copy.outfile = error_simfile;
%     spm_jobman('run', matlabbatch);
    test = load(error_simfile);
    D = test.D;
    n_channels = size(D.data,1);
    sensor_pos = D.sensors.meg.chanpos;
    distance = zeros(n_channels);
%% creat the crosstalk matrix
% obtain the distance between the sensors
    for i = 1:n_channels
        for j = 1:n_channels
            if(i == j)
                distance(i,j) = 50;
            else
                distance(i,j) = norm(sensor_pos(i,:)-sensor_pos(j,:));
            end        
        end
    end
    distance_min = min(distance,[],'all');
    scale = (distance_min./distance).^3;%set the crosstalk is inversely proportional to the cube of distance
    scale = scale.*crosstalkError;
    scale(logical(eye(size(scale)))) = 1;      % set the diagonal velue of scale to be 1
    tmp = zeros(size(D.data));
% tmp2 = zeros(size(test.data));
% for i = 1:n_channels
%     for j = 1:n_channels
%         for t = 1:size(test.data,2)
%             tmp(i,t) = tmp(i,t)+test.data(j,t)*scale(i,j);
%         end       
%     end 
% end
    for t = 1:size(D.data,2)
        for i = 1:n_channels       
                tmp(i,t) = scale(i,1:n_channels)*D.data(1:n_channels,t);     
        end 
    end
    %ori = D.data();
    D.data(:,:) = tmp;
    save(error_simfile,'D');
    coregfile = error_simfile;
end

%cross = test.D.data();



