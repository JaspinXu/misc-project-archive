clc;clear;
load cosn.mat
load nat.mat
load nsb.mat
load ntr.mat
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
n_total=cosn.*nat.*nsb.*ntr.*nref;