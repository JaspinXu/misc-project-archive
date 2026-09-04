% 已知best_res best(a) best_x()
% 先生成crd,crd_cnt,crd_md
best_x=[-30,12,8];
dev_cu=best_x(1);
best_m=[2,2.0446,5.4778];
dr=best_x(2);
beta=best_x(3);
  % 生成镜场
  crd=zeros(10000,2);
  crd_md=zeros(10000,1); % 用来存储修改后的角度，利于函数计算
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
  for j=1:crd_cnt
     temp=crd(j,2); 
     if (temp>=0)&&(temp<=pi/2)
         temp=pi/2-temp;
     elseif (temp>=pi/2)&&(temp<=pi*3/2)
         temp=temp-pi/2;
     else
         temp=5*pi/2-temp;
     end
     crd_md(j)=temp;   
  end
  % 得到crd,crd_cnt,crd_md
      ind_n=ceil(beta/4);
    ind_s=ceil(beta*0.75);
    load DNI.mat
    load vector_light.mat
    mr_hgt=best_m(1);mr_wdt=best_m(2);ins_hgt=best_m(3);
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
               axs=[crd(i,1)*cos(crd(i,2)),crd(i,1)*sin(crd(i,2)),ins_hgt];
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
            point1=[crd(ind_n,1)*cos(crd(ind_n,2)),crd(ind_n,1)*sin(crd(ind_n,2)),ins_hgt];
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
            point(2,:)=point1+x_v*mr_wdt; % 宽度与长度的一半为3
            point(3,:)=point1+y_v*mr_hgt;
            point(4,:)=point1-x_v*mr_wdt;
            point(5,:)=point1-y_v*mr_hgt;
            point(6,:)=point(2,:)-y_v*mr_hgt;
            point(7,:)=point(3,:)+x_v*mr_wdt;
            point(8,:)=point(4,:)+y_v*mr_hgt;
            point(9,:)=point(5,:)-x_v*mr_wdt;
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
            point1=[crd(ind_s,1)*cos(crd(ind_s,2)),crd(ind_s,1)*sin(crd(ind_s,2)),ins_hgt];
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
            point(2,:)=point1+x_v*mr_wdt; % 宽度与长度的一半为3
            point(3,:)=point1+y_v*mr_hgt;
            point(4,:)=point1-x_v*mr_wdt;
            point(5,:)=point1-y_v*mr_hgt;
            point(6,:)=point(2,:)-y_v*mr_hgt;
            point(7,:)=point(3,:)+x_v*mr_wdt;
            point(8,:)=point(4,:)+y_v*mr_hgt;
            point(9,:)=point(5,:)-x_v*mr_wdt;
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
    dhr=sqrt(crd(:,1).^2+(84-ins_hgt).^2);
    nat=0.99321-0.0001176*dhr+1.97*10^(-8)*dhr.^2;
    nat=repmat(nat,[1,12,5]);
    %% 接下来计算出结果矩阵
    res=zeros(crd_cnt,12,5);
    for i=1:crd_cnt
       for j=1:12
          for k=1:5
              res(i,j,k)=DNI(j,k)*nat(i,j,k)*0.92*nsb(i,j,k)*ncos(i,j,k)*mr_hgt*mr_wdt;
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
    res=sum(mr_hgt*mr_wdt*res)/1000;
    disp(res);
    total=res; % 全年平均功率
    ncos_a=zeros(12,1);
ntr_a=zeros(12,1);
nat_a=zeros(12,1);
nsb_a=zeros(12,1);
ntr=(ntrunck_n+ntrunck_s)/2;
for i=1:12
   ncos_a(i)=mean(mean(ncos(:,i,:))); 
   ntr_a(i)=mean(ntr(i,:));
   nat_a(i)=mean(mean(nat(:,i,:)));
   nsb_a(i)=mean(mean(nsb(:,i,:)));
end
n=ncos_a.*ntr_a.*nat_a.*nsb_a*0.92;
% ncosa，ntra，nsba分别为四个效率根据12月求得，n也同样为12个月的,total为年平均热功率
    res=zeros(crd_cnt,12,5);
    for i=1:crd_cnt
       for j=1:12
          for k=1:5
              res(i,j,k)=DNI(j,k)*nat(i,j,k)*0.92*nsb(i,j,k)*ncos(i,j,k)*mr_hgt*mr_wdt;
              if sin(crd(i,2))>0
                  res(i,j,k)=res(i,j,k)*ntrunck_n(j,k);
              else
                  res(i,j,k)=res(i,j,k)*ntrunck_s(j,k);
              end
          end
       end
    end
    res=mean(res,3);
    hot=zeros(12,1);
    for i=1:12
    hot(i)=sum(res(:,i).*mr_hgt.*mr_wdt)/sum(mr_hgt.*mr_wdt);
    end
    % hot(i)为i个月的单位面积功率
    tower_axis=dev_cu;% 塔的坐标
    crd_cnt; % 定日镜总面数
    best_res; % 定日镜总面积
    mr_hgt;mr_wdt; % 定日镜长度和宽度
    xy=zeros(crd_cnt,2);
for i=1:crd_cnt
   xy(i,1)=crd(i,1)*cos(crd(i,2));
   xy(i,2)=crd(i,1)*sin(crd(i,2))+dev_cu;
end% 定日镜xy坐标
ins_hgt;% 定日镜z坐标