% 指定两个坐标点
pointA = [0, 0, 0];  % 第一个坐标点，作为光锥的顶点
pointB = [1, 1, 2];  % 第二个坐标点

% 设置分割光锥的线数
num_lines = 20;

% 计算光锥的半角展宽（弧度）
cone_half_angle = deg2rad(4.65e-3);  % 4.65 mrad 转换为弧度

% 角均分法，生成分割的直线方向向量
theta = linspace(0, 2 * pi, num_lines);
phi = linspace(0, cone_half_angle, num_lines);

% 初始化存储直线的起点和终点坐标
line_coordinates = zeros(num_lines, 6);

% 计算和绘制每条直线
figure;
hold on;
grid on;
axis equal;

for i = 1:num_lines
    % 计算新的方向向量
    x = sin(phi(i)) * cos(theta(i));
    y = sin(phi(i)) * sin(theta(i));
    z = cos(phi(i));
    
    % 计算直线的起点和终点坐标
    start_point = pointA;
    end_point = pointA + [x, y, z];
    
    % 存储直线的起点和终点坐标
    line_coordinates(i, :) = [start_point, end_point];
    
    % 输出直线方程
    fprintf('Line %d: (%.2f, %.2f, %.2f) -> (%.2f, %.2f, %.2f)\n', i, start_point, end_point);
    
    % 绘制直线
    plot3([start_point(1), end_point(1)], [start_point(2), end_point(2)], [start_point(3), end_point(3)], 'b');
end

% 绘制主光线
plot3([pointA(1), pointB(1)], [pointA(2), pointB(2)], [pointA(3), pointB(3)], 'r', 'LineWidth', 2);

xlabel('X轴');
ylabel('Y轴');
zlabel('Z轴');
title('圆锥光束');
hold off;
