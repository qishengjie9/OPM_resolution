function coregfile = crosstalk_err(error_simfile,crosstalkError)

% add crosstalk error for the MEG data

if crosstalkError == 0
    coregfile = error_simfile;
else

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
    remainingData = setdiff(distance, 0);
    distance_min = min(remainingData,[],'all');
    scale = (distance_min./distance).^3;%set the crosstalk is inversely proportional to the cube of distance
    scale = scale.*crosstalkError;
    scale(logical(eye(size(scale)))) = 1;      % set the diagonal velue of scale to be 1
    % 
    scale(1:n_channels/2, n_channels/2+1:end) = 0;  % set the upper right elements to zero 
    scale(n_channels/2+1:end, 1:n_channels/2) = 0;   % set lower left elements to zero 
    tmp = zeros(size(D.data));
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




