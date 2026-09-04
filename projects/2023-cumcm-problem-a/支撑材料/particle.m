%% 粒子群算法函数
function [gbest,res]=particle(x_lb,x_ub,crd,crd_cnt,beta,dr,max_layers,DNI,vector_light)

% 粒子群算法中的预设参数
n = 4; % 粒子数量
narvs = 3; % 变量个数
c1 = 2;  % 每个粒子的个体学习因子
c2 = 2;  % 每个粒子的社会学习因子
w = 0.9;  % 惯性权重
K = 7;  % 迭代的次数
vmax = [0.3,0.3,0.2]; % 粒子的最大速度
dist=min(2*pi*(100+dr*(1:max_layers))./(beta*sqrt(1:max_layers)));
% 初始化粒子的位置和速度
x = zeros(n,narvs);
for i=1:n
   x(i,1)=x_lb(1)+(x_ub(1)-x_lb(1))*rand(1);
   x(i,2)=x_lb(2)+(x_ub(2)-x_lb(2))*rand(1);
   x(i,3)=x_lb(3)+(x_ub(3)-x_lb(3))*rand(1);
   while ~((x(i,2)>x(i,1))&&(x(i,3)>0.5*x(i,2))&&((5+x(i,2))<(dist))&&((5+x(i,2))<(dr)))
       x(i,1)=x_lb(1)+(x_ub(1)-x_lb(1))*rand(1);
       x(i,2)=x_lb(2)+(x_ub(2)-x_lb(2))*rand(1);
       x(i,3)=x_lb(3)+(x_ub(3)-x_lb(3))*rand(1);
   end
end
v = -vmax + 2*vmax .* rand(n,narvs);  % 随机初始化粒子的速度
penalty=100000;
objfun=@(x)target_fun(x)+penalty*(yearpower(crd,crd_cnt,x(1),x(2),x(3),DNI,vector_light,beta)-60);
% 计算适应度
fit = zeros(n,1);  % 初始化适应度全为0
for i = 1:n  % 计算每一个粒子的适应度
    fit(i) = objfun(x(i,:));   
end
pbest = x;   % 初始化这n个粒子迄今为止找到的最佳位置
ind = find(fit == min(fit), 1);  % 找到适应度最大的那个粒子的下标
gbest = x(ind,:);  % 定义所有粒子迄今为止找到的最佳位置

% 迭代K次来更新速度与位置
fitnessbest = ones(K,1);  
for d = 1:K  % 开始迭代，一共迭代K次
    w=0.9-0.5*(d/K)^2; % 递减惯性权重
    for i = 1:n   % 依次更新第i个粒子的速度与位置
        v(i,:) = w*v(i,:) + c1*rand(1)*(pbest(i,:) - x(i,:)) + c2*rand(1)*(gbest - x(i,:));  % 更新第i个粒子的速度
        % 如果粒子的速度超过了最大速度限制，就对其进行调整
        for j = 1: narvs
            if v(i,j) < -vmax(j)
                v(i,j) = -vmax(j);
            elseif v(i,j) > vmax(j)
                v(i,j) = vmax(j);
            end
        end
        x(i,:) = x(i,:) + v(i,:); % 更新第i个粒子的位置
        % 如果粒子的位置超出了定义域，就对其进行调整
        for j = 1: narvs
            if x(i,j) < x_lb(j)
                x(i,j) = x_lb(j);
            elseif x(i,j) > x_ub(j)
                x(i,j) = x_ub(j);
            end
        end
        while ~((x(i,2)>x(i,1))&&(x(i,3)>0.5*x(i,2))&&((5+x(i,2))<(dist))&&((5+x(i,2))<(dr)))
           x(i,1)=x_lb(1)+(x_ub(1)-x_lb(1))*rand(1);
           x(i,2)=x_lb(2)+(x_ub(2)-x_lb(2))*rand(1);
           x(i,3)=x_lb(3)+(x_ub(3)-x_lb(3))*rand(1);
        end
        fit(i) = objfun(x(i,:));  % 重新计算第i个粒子的适应度
        if fit(i) < objfun(pbest(i,:))   % 如果第i个粒子的适应度小于这个粒子迄今为止找到的最佳位置对应的适应度
            pbest(i,:) = x(i,:);   % 更新第i个粒子迄今为止找到的最佳位置
        end
        if  fit(i) < objfun(gbest)  % 如果第i个粒子的适应度小于所有的粒子迄今为止找到的最佳位置对应的适应度
            gbest = pbest(i,:);   % 更新所有粒子迄今为止找到的最佳位置
        end
    end
    fitnessbest(d) = objfun(gbest);  % 更新第d次迭代得到的最佳的适应度
end
res=target_fun(gbest);


end