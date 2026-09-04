% 指定两个坐标点
point1 = [105.36,23.191,4]; % 用实际坐标值替代 x1, y1, z1
mainDirection=[-105.360000000000,-23.1910000000000,80];

% 计算连线方向向量作为主光线方向
single1 = mainDirection/norm(mainDirection);
single22(1)= single1(2);single22(2)= -single1(1);single22(3)=0;
single2=single22/norm(single22);
single33=cross(single1,single2);
single3=single33/norm(single33);
T=[ single3(1) single2(1) single1(1)
    single3(2) single2(2) single1(2)
    single3(3) single2(3) single1(3)];

% 定义光线参数
numRays = 20; % 光线数量

% 创建三维图形窗口
figure('Name', '锥形光线簇', 'NumberTitle', 'off');
hold on;

% 初始化有解光线计数器
solvableCount = 0;

% 生成均匀角度的光线并绘制
for coneAngle=linspace(0,0.00465,50) % 圆锥角度（弧度）
  for i = 1:numRays
    % 计算每条光线的方向向量
    theta = 2 * pi * (i - 1) / numRays; % 周向均匀分布的角度
    phi = coneAngle; % 半角展宽方向
    
    % 计算光线的方向向量
    dx = sin(phi) * cos(theta);
    dy = sin(phi) * sin(theta);
    dz = cos(phi);
    
    % 光线方程：从顶点 point1 发出，沿着方向 (dx, dy, dz) 的光线方程
    x0 = 0;
    y0 = 0;
    z0 = 0;
    vector_real=T*[dx;dy;dz];
    dx=vector_real(1);
    dy=vector_real(2);
    dz=vector_real(3);
    
    % 计算光线的终点
    t = linspace(0, 1000, 100000); % 在光线方向上均匀采样点
    xRays = point1(1) + t * dx;
    yRays = point1(2) + t * dy;
    zRays = point1(3) + t * dz;
    
    % 绘制光线
    plot3(xRays, yRays, zRays, 'b'); % 使用plot3绘制三维图形
    
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
  end
end
% 计算有解的光线占总光线的比例
solvablePercentage = solvableCount / 1000;
fprintf('有解的光线占总光线的比例：%.10f%%\n', solvablePercentage);

xlabel('X坐标');
ylabel('Y坐标');
zlabel('Z坐标');
title('锥形光线簇');
grid on;
hold off;
view(3)