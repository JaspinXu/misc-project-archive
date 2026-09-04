clc;clear;
%% 数据处理

load vector_light.mat
load gaodu.mat
load coord.mat % 存储各个反光镜的坐标
tower=[0,0,84]; % 分别表示集热器中心的xyz坐标
H=3; % 海拔高度
G0=1.366;
a=0.4237-0.00821*(6-H)^2;
b=0.5055+0.00595*(6.5-H)^2;
c=0.2711+0.01858*(2.5-H)^2;
DNI=G0.*(a+b.*exp(-c./sin(gaodu)));
nref=0.92;
vector_mirror=cell(1745,12,5); % 存储各个镜面的法向量
crd=[coord,4*ones(1745,1)];
vector_r=repmat(tower,1745,1)-crd;
for i=1:1745
    for j=1:12
       for k=1:5
          v_sun=-vector_light{j,k};
          v_mirror=tower-[coord(i,1),coord(i,2),4];
          v_sun=v_sun/norm(v_sun);
          v_mirror=v_mirror/norm(v_mirror);
          res=v_sun+v_mirror;
          vector_mirror{i,j,k}=res/norm(res);
       end
    end
end
length=6;
width=6;
vector_x=cell(1745,12,5);
vector_y=cell(1745,12,5);
for i=1:1745
    for j=1:12
       for k=1:5
           vector=vector_mirror{i,j,k};
            vector_x{i,j,k}=[vector(2),-vector(1),0]/norm([vector(2),-vector(1),0]);
            t=cross(vector_x{i,j,k},vector);
            vector_y{i,j,k}=t/norm(t);
       end
    end
end
p=cell(1745,12,5,4); % 1745个镜子的四个点的xyz三个坐标

for i=1:1745
    for j=1:12
        for k=1:5
            crd=[coord,4*ones(1745,1)];
            p{i,j,k,1}=crd(i,:)+vector_x{i,j,k}.*length./2+vector_y{i,j,k}.*width./2;
            p{i,j,k,2}=crd(i,:)+vector_x{i,j,k}.*length./2-vector_y{i,j,k}.*width./2;
            p{i,j,k,3}=crd(i,:)-vector_x{i,j,k}.*length./2+vector_y{i,j,k}.*width./2;
            p{i,j,k,4}=crd(i,:)-vector_x{i,j,k}.*length./2-vector_y{i,j,k}.*width./2;
        end
    end
end


%% 得出阴影判断矩形和遮挡判断矩形

%分别计算各个镜面的遮挡面积
s_shade=zeros(1745,12,5);
for i=1:1:1745
    for j=1:12
        for k=1:5
            light=vector_light{j,k}; % 求是否在主塔影子下
            vector_g=[0,0,88]-light*88/light(3);
            vector_rt=[vector_g(2),-vector_g(1)];
            vector_rt=vector_rt/norm(vector_rt);
            ptg=zeros(4,2);
            ptg(1,:)=vector_rt*3.5;
            ptg(2,:)=ptg(1,:)+vector_g(1:2);
            ptg(3,:)=ptg(2,:)+vector_rt*7;
            ptg(4,:)=ptg(3,:)-vector_g(1:2);
            if inpolygon(coord(i,1),coord(i,2),ptg(:,1),ptg(:,2))~=1
                [sq_i,sq_r]=shade(length,width,gaodu(j,k),vector_light{j,k},vector_r(i,:),coord(i,1),coord(i,2));
                x_i=sq_i(:,1);
                y_i=sq_i(:,2);
                x_r=sq_r(:,1);
                y_r=sq_r(:,2);
                index_i=zeros(20,1); % 判断各个镜面中心点是否在两个矩形内
                index_r=zeros(20,1);
                pp=0;q=0;
                Transh=[vector_x{i,j,k}',vector_y{i,j,k}',vector_mirror{i,j,k}']; % 生成欧式变换矩阵
                for m=1:1745
                   if m~=i
                       [in_i,~]=inpolygon(coord(m,1),coord(m,2),x_i,y_i);
                       [in_r,~]=inpolygon(coord(m,1),coord(m,2),x_r,y_r);
                       if in_i==1
                          pp=pp+1;
                          index_i(pp)=m;
                       end
                       if in_r==1
                           q=q+1;
                           index_r(q)=m;
                       end
                   end
                end
                % 下面进行阴影遮挡判断
                xv=[length/2,length/2,-length/2,-length/2];
                yv=[width/2,-width/2,-width/2,width/2]; % 存储镜面的坐标
                poly1=polyshape(xv,yv);
                cst=1;
                cont=0;
                while index_i(cst)~=0
                    pt=zeros(4,3);
                    pt2=zeros(4,2);
                    for cnt1=1:4
                       pt(cnt1,:)=p{index_i(cst),j,k,cnt1};
                       pt(cnt1,:)=Transh'*(pt(cnt1,:)-[coord(i,1),coord(i,2),4])'; % 变换坐标系
                       vector=Transh'*vector_light{j,k}';
                       pt2(cnt1,1)=(vector(3)*pt(cnt1,1)-vector(1)*pt(cnt1,3));
                       pt2(cnt1,2)=(vector(3)*pt(cnt1,2)-vector(2)*pt(cnt1,3)); % 完成坐标转化
                    end
                    if cst==1
                       polyut=polyshape(pt2(:,1),pt2(:,2));
                    else
                        polyut=union(polyut,polyshape(pt2(:,1),pt2(:,2)));
                    end
                    cst=cst+1;
                    cont=cst-1;
                end
                cst=1;
                while index_r(cst)~=0
                    pt=zeros(4,3);
                    pt2=zeros(4,2);
                    for cnt1=1:4
                       pt(cnt1,:)=p{index_r(cst),j,k,cnt1};
                       pt(cnt1,:)=Transh'*(pt(cnt1,:)-[coord(i,1),coord(i,2),4])'; % 变换坐标系
                       vector=Transh'*vector_r(i,:)';
                       pt2(cnt1,1)=(vector(3)*pt(cnt1,1)-vector(1)*pt(cnt1,3));
                       pt2(cnt1,2)=(vector(3)*pt(cnt1,2)-vector(2)*pt(cnt1,3)); % 完成坐标转化
                    end
                    polyut=union(polyut,polyshape(pt2(:,1),pt2(:,2)));
                    cst=cst+1;
                    cont=cont+cst-1;
                end
                if cont>=1
                    polyut=intersect(poly1,polyut);
                    s=area(polyut);
                else
                    s=0;
                end
            else
                s=36; % 被灯塔挡住中心点直接当做完全挡住计算
            end
            s_shade(i,j,k)=s;
        end
    end
end
% load sadow.mat
nsb=(36-s_shade)./36;
%% 计算余弦效率
cosn=zeros(1745,12,5);
for i=1:1745
    for j=1:12
       for k=1:5
           a=vector_light{j,k};
           b=vector_mirror{i,j,k};
           cosn(i,j,k)=abs(dot(a,b)/norm(a)/norm(b));
       end
    end
end
%% 镜面反射率
nref_m=ones(1745,12,5)*nref;
%% 大气透射率
dhr=zeros(1745,1);
for i=1:1745
   dhr(i)=sqrt(80^2+coord(i,1)^2+coord(i,2)^2); 
end
dhr=repmat(dhr,[1,12,5]);

nat=0.99321-0.0001176.*dhr+1.97.*10^(-8).*dhr.^2;











