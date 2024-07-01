% 绘制相关性的箱线图
data = load('F:\simulation-paper\simulation-OPM\results\spatial_resolution\crosstalk_error\data_result\40run_30mm space_10dB_8mm');
Res = data.Res;
% 坐标区域每组变量之间的标签
%   results(1,SNRindex,simarrayind,run,errindex,methind) = DLE;         % DLE
%   results(2,SNRindex,simarrayind,run,errindex,methind) = SD;        % SD

%X ={' ','0','2°','4°','6°','8°','10°'};
X ={' ','0','0.02','0.04','0.06','0.08','0.10'};
% 设置画图背景为白色
figure('color',[1 1 1]);
% 设置配色
mycolor1 = [220 211 30;180 68 108;242 166 31;244 146 121;59 125 183]./255;
mycolor2 = [255 255 0;254 0 0;85 160 251;126 126 126;255 255 255]./255;
mycolor3 = [250 221 214;130 130 130;85 160 251;100 195 191;232 245 176;59 125 183]./255;
mycolor4 = [255 255 255;131 131 131;0 0 254;131 131 131;255 255 255]./255;
mycolor5 = [214 181 239;156 222 189;255 156 156;255 222 107;140 189 247;173 173 173]./255;
hold on 
% 开始绘图
%参数依次为数据矩阵、颜色设置、标记符
%positions = [0.7 1.7 2.7 3.7 4.7 5.7];
positions = [1 2 3 4 5 6];
box_figure = boxplot(squeeze(Res(1,:,:,:,:,:)),'color',[0 0 0],'Symbol','o','positions', positions,'Widths',0.5);
%box_figure = boxplot(squeeze(dist_EBB),'color',[0 0 0],'Symbol','o');
%计算平均值
% mean_value = mean(squeeze(Res(1,1,:,:)),1);
% hold on 
% line ([0.5],[],'Color','r','LineWidth',2)
% plot([1 2 3 4 5 6],mean_value,'*'); % 数字范围为[0 1]
%设置线宽
set(box_figure,'Linewidth',1.2);
boxobj = findobj(gca,'Tag','Box');
for i = 1:size(squeeze(Res(1,1,:,:)),2)
    patch(get(boxobj(i),'XData'),get(boxobj(i),'YData'),mycolor5(i,:),'FaceAlpha',0.5,...
        'LineWidth',0.4);
end
hold on;
% 设置坐标区域的参数
% xlabel('gain error','Fontsize',10,'FontWeight','bold','FontName','times new roman');
% ylabel('correlation','Fontsize',10,'FontWeight','bold','FontName','times new roman');
% title('correlation under different angular error','Fontsize',10,'FontWeight','bold','FontName','times new roman');
set(gca,'Linewidth',1.5); %设置坐标区的线宽
set(gca,'Fontsize',16,'FontWeight','bold'); % 设置坐标区字体大小
% 对X轴刻度与显示范围调整
set(gca,'Xlim',[0.4 6.5], 'Xtick', [0:1:6.5],'Xticklabel',X);
% 对Y轴刻度与显示范围调整
set(gca,'YTick', 0:0.2:1,'Ylim',[-0.05 1.05]);
% 对刻度长度与刻度显示位置调整
set(gca, 'TickDir', 'in', 'TickLength', [.008 .008]);

%开始绘制0.707阈值
hold on;
x1 = 0.5;
x2 = 6.5;
y1 = 0.707;
plot([x1,x2],[y1,y1],'k--','Linewidth',1.5,'Color',[180/255 68/255 108/255]);
hold on;
%% 绘制多个SNR下的箱线图

data1 = load('F:\simulation-paper\simulation-OPM\results\spatial_resolution\crosstalk_error\data_result\40run_30mm_space_0_10_20dB_8mm(0-0.04error).mat');
data2 = load('F:\simulation-paper\simulation-OPM\results\spatial_resolution\crosstalk_error\data_result\40run_30mm_space_0_10_20dB_8mm(0.01-0.03-0.05error).mat');
Res1 = data1.Res;
Res2 = data2.Res;

% Res2 = load('F:\simulation-paper\simulation-OPM\results\spatial_resolution\angular_error\data_result\angular_40runs_10dB_6errror_30mm_8mm');
% Res2 = Res2.Res;
% 坐标区域每组变量之间的标签
%X ={' ','0','0.02','0.04','0.06','0.08','0.1'};
X ={' ','0','0.01','0.02','0.03','0.04','0.05'};
%X ={' ','0','0.02','0.04'};
%X ={' ','0','2','4','6','8','10'};
% 设置画图背景为白色
figure('color',[1 1 1]);
% 设置配色
for i = 1:3
    %mycolor3 = [250 221 214;130 130 130;85 160 251;100 195 191;232 245 176;59 125 183]./255*(1+0.3*(i-3));
    %mycolor2 = [173 173 173;140 189 247;255 222 107;255 156 156;156 222 189;214 181 239]./255*(1+0.3*(i-3));
    mycolor2 = [214 181 239;156 222 189;255 156 156;255 222 107;140 189 247;173 173 173]./255*(0.55+0.15*i);
%     if i == 2
%         data_plot = squeeze(Res2(1,1,:,:));
%     elseif i == 3
%         data_plot = squeeze(Res1(2,1,:,:));
%     else
%         data_plot = squeeze(Res1(1,1,:,:));
%     end
   data_plot = [squeeze(Res1(i,1,:,:)) squeeze(Res2(i,1,:,:))];
   
   data_plot = [data_plot(:,1),data_plot(:,4),data_plot(:,2),data_plot(:,5),data_plot(:,3),data_plot(:,6)];
% 开始绘图
%参数依次为数据矩阵、颜色设置、标记符
%positions = [0.7 1.7 2.7 3.7 4.7 5.7];
    positions = [1 2 3 4 5 6]+0.3*(i-2);
    box_figure = boxplot(data_plot,'color',[0 0 0],'Symbol','o','positions', positions,'Widths',0.2);
%box_figure = boxplot(squeeze(dist_EBB),'color',[0 0 0],'Symbol','o');
%计算平均值
% mean_value = mean(squeeze(Res(1,1,:,:)),1);
% hold on 
% line ([0.5],[],'Color','r','LineWidth',2)
% plot([1 2 3 4 5 6],mean_value,'*'); % 数字范围为[0 1]
%设置线宽
    set(box_figure,'Linewidth',1.2);
    boxobj = findobj(gca,'Tag','Box');
    for j = 1:6
        patch(get(boxobj(j),'XData'),get(boxobj(j),'YData'),mycolor2(j,:),'FaceAlpha',0.5,...
            'LineWidth',0.4);
    end
    hold on;
end
% 设置坐标区域的参数
%xlabel('gain error[degree]','Fontsize',10,'FontWeight','bold','FontName','times new roman');
%ylabel('correlation','Fontsize',10,'FontWeight','bold','FontName','times new roman');
%title('correlation under different gain error','Fontsize',10,'FontWeight','bold','FontName','times new roman');
set(gca,'Linewidth',1.5); %设置坐标区的线宽
set(gca,'Fontsize',16,'FontWeight','bold'); % 设置坐标区字体大小
% 对X轴刻度与显示范围调整
set(gca,'Xlim',[0.4 6.5], 'Xtick', [0:1:6.5],'Xticklabel',X);
% 对Y轴刻度与显示范围调整
set(gca,'YTick', 0:0.2:1,'Ylim',[-0.05 1.05]);
% 对刻度长度与刻度显示位置调整
set(gca, 'TickDir', 'in', 'TickLength', [.008 .008]);
%开始绘制0.707阈值
hold on;
x1 = 0.5;
x2 = 6.5;
y1 = 0.707;
plot([x1,x2],[y1,y1],'k--','Linewidth',1.5,'Color',[180/255 68/255 108/255]);
%hold on;