function [p,p2]=shade(lth,wth,gaodu,in,rfl,x,y)
% lth:镜面长度
% wth:镜面宽度
% gaodu:对应时刻的太阳高度角
% in:入射光线的向量
% rfl:反射光线的向量
% x:镜子于镜面坐标系下的x坐标
% y:镜子于镜面坐标系下的y坐标
% sq_1:阴影判断矩形
% sq_2:遮挡判断矩形
    L1=2*lth;
    L2=wth/sin(gaodu); % 计算判断矩形的长和宽
    in_=-[in(1),in(2)]/norm([in(1),in(2)]); % 加负号是为了调整为正确的方向，由于入射光线朝向镜子
    rfl_=[rfl(1),rfl(2)]/norm([rfl(1),rfl(2)]);
    in_1=[in_(2),-in_(1)];
    rfl_1=[rfl_(2),-rfl_(1)]; % 建立矩形的长方向向量
    p=zeros(4,2);
    p(1,:)=[x,y]+L1/2*in_1;
    p(2,:)=p(1,:)+L2*in_;
    p(3,:)=p(2,:)-L1*in_1;
    p(4,:)=p(3,:)-L2*in_;
    p2=zeros(4,2);
    p2(1,:)=[x,y]+L1/2*rfl_1;
    p2(2,:)=p2(1,:)+L2*rfl_;
    p2(3,:)=p2(2,:)-L1*rfl_1;
    p2(4,:)=p2(3,:)-L2*rfl_;
end