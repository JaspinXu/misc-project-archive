clc;clear;
load DNI.mat
load vector_light.mat
global crd_cnt
%% 生成吸收塔的离散点
tower_axis=zeros(7,1); % 由于东西方向的对称，只考虑南北分布
dev=15; % 每格偏离距离
for i=1:7
   tower_axis(i)=dev*(i-4);
end


%% 蒙特卡洛模拟布局方案
best_m=zeros(3,1);
best_x=zeros(3,1);
best_res=inf;
for i=1:7
    dev_cu=tower_axis(i);
    for dr=8:2:12
       for beta=8:2:12
          % 生成镜场
          crd=zeros(10000,2);
          crd_cnt=1;
          max_layers=ceil((abs(dev_cu)+350)/dr); % 向上取整获得需要生成的层数
          for layer=1:max_layers
            r_curr=100+(layer-1)*dr; % 生成当前的半径
            x_curr=r_curr; % 从横轴上开始生成
            y_curr=0+dev_cu; % 从吸收塔的坐标转到地面坐标
            theta=2*pi/layer/beta; % 计算转角
            theta_cu=0;
            for mirrors_count=1:floor(layer*beta) % 根据beta的函数决定每层的镜子个数
                if x_curr^2+y_curr^2<=350^2 % 在区域之内
                    crd(crd_cnt,:)=[r_curr,theta_cu]; % 记录坐标
                    crd_cnt=crd_cnt+1;
                end
                theta_cu=theta_cu+theta;
                x_curr=r_curr*cos(theta_cu);
                y_curr=r_curr*sin(theta_cu)+dev_cu;
            end
          end
          crd_cnt=crd_cnt-1;
          % 生成完毕，crd存储每个在区域内点在以吸收塔为原点的极坐标
          % 下面进行对此镜场的优化问题求解
          x_lb=[2,2,2];
          x_ub=[8,8,6];
          [best,res]=particle(x_lb,x_ub,crd,crd_cnt,beta,dr,max_layers,DNI,vector_light);
          disp(best)
          disp(res)
          disp(dev_cu)
          disp(dr)
          disp(beta)
          if res<best_res
              best_m=best;
              best_res=res;
              best_x=[dev_cu,dr,beta];
          end
       end
    end
end



