function res=yearpower3(crd,crd_cnt,crd_md,x1,x2,x3,DNI,vector_light,beta)
     % load DNI.mat 于粒子群算法中要用的
     % load vector_light
    mr_hgt=8-x2.*log(crd(:,1))-x3.*exp(-crd_md(:));
    mr_wdt=mr_hgt;
    ins_hgt=5+x1.*(1-exp(-crd(:,1)./100));
    ind_n=ceil(beta/4);
    ind_s=ceil(beta*0.75);
    %% nsb
    nsb=[0.9753,0.9862,0.9945,0.9949,0.9949,0.9949,0.9949,0.9949,0.9946,0.9870,0.9744,0.9573];
    nsb=repmat(nsb,[crd_cnt,1,5]);
    %% ncos
    ncos=zeros(crd_cnt,12,5);
    vec_mir=cell(crd_cnt,12,5);
    vec_rfl=cell(crd_cnt,12,5);
    for i=1:crd_cnt
        for j=1:12
           for k=1:5
               vec_sun=-vector_light{j,k};
               axs=[crd(i,1)*cos(crd(i,2)),crd(i,1)*sin(crd(i,2)),ins_hgt(i)];
               vec_r=[0,0,84]-axs;
               vec_sun=vec_sun/norm(vec_sun);
               vec_r=vec_r/norm(vec_r);
               vec_mr=vec_sun+vec_r;
               vec_mr=vec_mr/norm(vec_mr);
               vec_mir{i,j,k}=vec_mr;
               ncos(i,j,k)=dot(vec_mr,vec_sun)/norm(vec_mr)/norm(vec_sun);
               vec_rfl{i,j,k}=vec_r;
           end
        end
    end
    %% ntrunck
    ntrunck_n=zeros(12,5);
    ntrunck_s=zeros(12,5);
    for j=1:12
        for k=1:5
        % 分别提取出9个点进行
         % 得到变换矩阵
            mir_n=vec_mir{ind_n,j,k};
            rfl_n=vec_rfl{ind_n,j,k};
            point1=[crd(ind_n,1)*cos(crd(ind_n,2)),crd(ind_n,1)*sin(crd(ind_n,2)),ins_hgt(ind_n)];
            mainDirection=rfl_n;
            single1 = mainDirection/norm(mainDirection);
            single22(1)= single1(2);single22(2)= -single1(1);single22(3)=0;
            single2=single22/norm(single22);
            single33=cross(single1,single2);
            single3=single33/norm(single33);
            T=[ single3(1) single2(1) single1(1)
            single3(2) single2(2) single1(2)
            single3(3) single2(3) single1(3)];
            point=zeros(9,3);
            x_v=[mir_n(2),-mir_n(1),0];
            x_v=x_v/norm(x_v);
            y_v=cross(x_v,mir_n);
            y_v=y_v/norm(y_v);
            point(1,:)=point1; % 导入九个坐标
            point(2,:)=point1+x_v*mr_wdt(ind_n); % 宽度与长度的一半为3
            point(3,:)=point1+y_v*mr_hgt(ind_n);
            point(4,:)=point1-x_v*mr_wdt(ind_n);
            point(5,:)=point1-y_v*mr_hgt(ind_n);
            point(6,:)=point(2,:)-y_v*mr_hgt(ind_n);
            point(7,:)=point(3,:)+x_v*mr_wdt(ind_n);
            point(8,:)=point(4,:)+y_v*mr_hgt(ind_n);
            point(9,:)=point(5,:)-x_v*mr_wdt(ind_n);
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
           ntrunck_n(j,k)=mean_block/9;
         %% 分别提取出9个点进行
         % 得到变换矩阵
            mir_s=vec_mir{ind_s,j,k};
            rfl_s=vec_rfl{ind_s,j,k};
            point1=[crd(ind_s,1)*cos(crd(ind_s,2)),crd(ind_s,1)*sin(crd(ind_s,2)),ins_hgt(ind_s)];
            mainDirection=rfl_s;
            single1 = mainDirection/norm(mainDirection);
            single22(1)= single1(2);single22(2)= -single1(1);single22(3)=0;
            single2=single22/norm(single22);
            single33=cross(single1,single2);
            single3=single33/norm(single33);
            T=[ single3(1) single2(1) single1(1)
            single3(2) single2(2) single1(2)
            single3(3) single2(3) single1(3)];
            point=zeros(9,3);
            x_v=[mir_s(2),-mir_s(1),0];
            x_v=x_v/norm(x_v);
            y_v=cross(x_v,mir_s);
            y_v=y_v/norm(y_v);
            point(1,:)=point1; % 导入九个坐标
            point(2,:)=point1+x_v*mr_wdt(ind_s); % 宽度与长度的一半为3
            point(3,:)=point1+y_v*mr_hgt(ind_s);
            point(4,:)=point1-x_v*mr_wdt(ind_s);
            point(5,:)=point1-y_v*mr_hgt(ind_s);
            point(6,:)=point(2,:)-y_v*mr_hgt(ind_s);
            point(7,:)=point(3,:)+x_v*mr_wdt(ind_s);
            point(8,:)=point(4,:)+y_v*mr_hgt(ind_s);
            point(9,:)=point(5,:)-x_v*mr_wdt(ind_s);
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
           ntrunck_s(j,k)=mean_block/9;
        end
    end
    %% nat
    dhr=sqrt(crd(:,1).^2+(84-ins_hgt(:)).^2);
    nat=0.99321-0.0001176.*dhr+1.97*10^(-8).*dhr.^2;
    nat=repmat(nat,[1,12,5]);
    %% 接下来计算出结果矩阵
    res=zeros(crd_cnt,12,5);
    for i=1:crd_cnt
       for j=1:12
          for k=1:5
              res(i,j,k)=DNI(j,k)*nat(i,j,k)*0.92*nsb(i,j,k)*ncos(i,j,k)*mr_hgt(i)*mr_wdt(i);
              if sin(crd(i,2))>0
                  res(i,j,k)=res(i,j,k)*ntrunck_n(j,k);
              else
                  res(i,j,k)=res(i,j,k)*ntrunck_s(j,k);
              end
          end
       end
    end
    res=mean(res,3);
    res=mean(res,2);
    res=sum(res.*mr_hgt(1:crd_cnt).^2)/1000;
end