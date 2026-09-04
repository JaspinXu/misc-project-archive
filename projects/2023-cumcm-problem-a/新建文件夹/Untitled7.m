clc;clear;
load vector_r_none_norm.mat
load coord.mat
load vector_x.mat
load vector_y.mat
block=zeros(1745,12,5);
for i=1:1745
      point1=[coord(i,1),coord(i,2),4];
      mainDirection=vector_r(i,:);
      single1 = mainDirection/norm(mainDirection);
      single22(1)= single1(2);single22(2)= -single1(1);single22(3)=0;
      single2=single22/norm(single22);
      single33=cross(single1,single2);
      single3=single33/norm(single33);
      T=[ single3(1) single2(1) single1(1)
        single3(2) single2(2) single1(2)
        single3(3) single2(3) single1(3)];
   for j=1:12
      for k=1:5
        % 得到变换矩阵
        point=zeros(9,3);
        x_v=vector_x{i,j,k};
        x_v=x_v/norm(x_v);
        y_v=vector_y{i,j,k};
        y_v=y_v/norm(y_v);
        point(1,:)=point1; % 导入九个坐标
        point(2,:)=point1+x_v*1.5; % 宽度与长度的一半为3
        point(3,:)=point1+y_v*1.5;
        point(4,:)=point1-x_v*1.5;
        point(5,:)=point1-y_v*1.5;
        point(6,:)=point(2,:)-y_v*1.5;
        point(7,:)=point(3,:)+x_v*1.5;
        point(8,:)=point(4,:)+y_v*1.5;
        point(9,:)=point(5,:)-x_v*1.5;
        mean_block=0; % 存储一块镜子九个点效率的平均值
        for ops=1:9
            numRays = 10;
            solvableCount = 0;
            for coneAngle=linspace(0,0.00465,10) % 圆锥角度（弧度）
              for itm = 1:numRays
                % 计算每条光线的方向向量
                theta = 2 * pi * (itm - 1) / numRays; % 周向均匀分布的角度
                phi = coneAngle; % 半角展宽方向

                % 计算光线的方向向量
                dx = sin(phi) * cos(theta);
                dy = sin(phi) * sin(theta);
                dz = cos(phi);

                % 光线方程：从顶点 point1 发出，沿着方向 (dx, dy, dz) 的光线方程
                vector_real=T*[dx;dy;dz];
                dx=vector_real(1);
                dy=vector_real(2);
                dz=vector_real(3);

                % 计算光线的终点
                pit=point(ops,:);
                t = linspace(0, 700, 100); % 在光线方向上均匀采样点
                xRays = pit(1) + t * dx;
                yRays = pit(2) + t * dy;
                zRays = pit(3) + t * dz;

                % 判定光线方程是否与另一立体图形的方程联立有解
                % 如果有解，则增加计数器

                r = 3.5;
                % 判定逻辑
                intersection1 = (((xRays).^2 + (yRays ).^2 ) <= r^2);
                intersection2 = (zRays<=88);
                intersection3 = (zRays>=80);
                if any(intersection1&intersection2&intersection3)
                    solvableCount = solvableCount + 1;
                end
                solvablePercentage = solvableCount / 100;
              end
            end
            mean_block=mean_block+solvablePercentage;
        end
        block(i,j,k)=mean_block/9;
      end
   end
end

