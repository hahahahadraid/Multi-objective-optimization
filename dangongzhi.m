% 定义环境参数
T0 = 20 + 273.15; % 环境温度 [K]
P0 = 101.325; % 环境压力 [kPa]

% 定义工质
fluid1 = 'R134a'; % 低温级的混合工质的一种
fluid3 = 'R161'; % 低温级的混合工质的另一种
x = [0.7, 0.3];
fluid2 = 'R245fa'; % 高温级的工质

% 系统参数
dt = 5; % 传热温差
tsur = 5; % 过热度
tsout = 105 + 273.15; % 出水温度
tsin = 50 + 273.15; % 进水温度
te1 = -0+ 273.15; % 低温级蒸发温度
tc2 = tsout + tsur; % 高温级冷凝温度
tc1 = 90 + 273.15; % 中间温度/低温级冷凝温度
te2 = tc1 - dt; % 高温级蒸发温度
ms = 3000; % 热水流量 [kg/h]
qc = ms * 4.2 * (tsout - tsin) /3600; % 热负荷 [kW]
n = 0.85; % 压缩机等熵效率

%% 高温级循环计算
% 节点5 (蒸发器出口)
t5 = te2;
p5 = refpropm('P', 'T', t5, 'Q', 1, fluid2);
h5 = refpropm('H', 'T', t5, 'Q', 1, fluid2);
s5 = refpropm('S', 'T', t5, 'Q', 1, fluid2);
h0_5 = refpropm('H', 'T', T0, 'P', P0, fluid2); % 环境状态焓
s0_5 = refpropm('S', 'T', T0, 'P', P0, fluid2);
Ex5 = (h5 - h0_5) - T0 * (s5 - s0_5);

% 节点5g (压缩机吸气)
t5g = te2 + tsur;
p5g = p5;
h5g = refpropm('H', 'T', t5g, 'P', p5g, fluid2);
s5g = refpropm('S', 'T', t5g, 'P', p5g, fluid2);
Ex5g = (h5g - h0_5) - T0 * (s5g - s0_5);

% 节点6 (压缩机出口)
ps1 = refpropm('P', 'T', tc2, 'Q', 1, fluid2);
s2s1 = s5g;
h2s1 = refpropm('H', 'P', ps1, 'S', s2s1, fluid2);
h6 = h5g + (h2s1 - h5g) / n;
s6 = refpropm('S', 'P', ps1, 'H', h6, fluid2);
Ex6 = (h6 - h0_5) - T0 * (s6 - s0_5);

% 节点7 (冷凝器出口)
t7 = refpropm('T', 'P', ps1, 'Q', 0, fluid2) - tsur;
h7 = refpropm('H', 'T', t7, 'P', ps1, fluid2);
s7 = refpropm('S', 'T', t7, 'P', ps1, fluid2);
Ex7 = (h7 - h0_5) - T0 * (s7 - s0_5);

% 节点8 (膨胀阀出口)
h8 = h7; % 等焓过程
s8 = refpropm('S', 'P', p5, 'H', h8, fluid2);
Ex8 = (h8 - h0_5) - T0 * (s8 - s0_5);

% 计算高温级工质质量流量
m2 = qc / (h6 - h7); % [kg/s]
W_comp_h = m2 * (h6 - h5g); % 高温级压缩机实际耗功 [kW]

%% 低温级循环计算
% 节点1 (蒸发器出口)
t1 = te1;
p1 = refpropm('P', 'T', t1, 'Q', 1, fluid1, fluid3, x);
h1 = refpropm('H', 'T', t1, 'Q', 1, fluid1, fluid3, x);
s1 = refpropm('S', 'T', t1, 'Q', 1, fluid1, fluid3, x);
h0_1 = refpropm('H', 'T', T0, 'P', P0, fluid1, fluid3, x);
s0_1 = refpropm('S', 'T', T0, 'P', P0, fluid1, fluid3, x);
Ex1 = (h1 - h0_1) - T0 * (s1 - s0_1);

% 节点1g (压缩机吸气)
t1g = te1 + tsur;
p1g = p1;
h1g = refpropm('H', 'T', t1g, 'P', p1g, fluid1, fluid3, x);
s1g = refpropm('S', 'T', t1g, 'P', p1g, fluid1, fluid3, x);
Ex1g = (h1g - h0_1) - T0 * (s1g - s0_1);

% 节点2 (压缩机出口)
ps = refpropm('P', 'T', tc1, 'Q', 1, fluid1, fluid3, x);
s2s = s1g;
h2s = refpropm('H', 'P', ps, 'S', s2s, fluid1, fluid3, x);
h2 = h1g + (h2s - h1g) / n;
s2 = refpropm('S', 'P', ps, 'H', h2, fluid1, fluid3, x);
Ex2 = (h2 - h0_1) - T0 * (s2 - s0_1);

% 节点3 (冷凝器出口)
t3 = refpropm('T', 'P', ps, 'Q', 0, fluid1, fluid3, x) - tsur;
h3 = refpropm('H', 'T', t3, 'P', ps, fluid1, fluid3, x);
s3 = refpropm('S', 'T', t3, 'P', ps, fluid1, fluid3, x);
Ex3 = (h3 - h0_1) - T0 * (s3 - s0_1);

% 节点4 (膨胀阀出口)
h4 = h3; % 等焓过程
s4 = refpropm('S', 'P', p1, 'H', h4, fluid1, fluid3, x);
Ex4 = (h4 - h0_1) - T0 * (s4 - s0_1);

% 计算低温级工质质量流量
Q_cond_l = h2 - h3; % 低温级冷凝器放热量 [kJ/kg]
m1 = m2 * (h5 - h8) / Q_cond_l; % 基于能量平衡计算低温级质量流量 [kg/s]
W_comp_l = m1 * (h2 - h1g); % 低温级压缩机实际耗功 [kW]

%% 㶲损计算
% 高温级部件
ED_comp_h = W_comp_h - m2 * (Ex6 - Ex5g); 

Q_cond_h = m2 * (h6 - h7); % 冷凝器放热量 [kW]
ED_cond_h = m2 * (Ex6 - Ex7) - Q_cond_h * (1 - T0 / tc2);

ED_exp_h = m2 * (Ex7 - Ex8); % 膨胀阀㶲损

Q_eva_h = m2 * (h5 - h8); % 蒸发器吸热量 [kW]
ED_eva_h = Q_eva_h * (1 - T0 / te2) - m2 * (Ex5 - Ex8);

% 低温级部件
ED_comp_l = W_comp_l - m1 * (Ex2 - Ex1g);

Q_cond_l = m1 * (h2 - h3); % 冷凝器放热量 [kW]
ED_cond_l = m1 * (Ex2 - Ex3) - Q_cond_l * (1 - T0 / tc1);

ED_exp_l = m1 * (Ex3 - Ex4); 

Q_eva_l = m1 * (h1 - h4); % 蒸发器吸热量 [kW]
ED_eva_l = Q_eva_l * (1 - T0 / te1) - m1 * (Ex1 - Ex4);

% 总㶲损
ED_Total = ED_comp_h + ED_cond_h + ED_exp_h + ED_eva_h + ...
           ED_comp_l + ED_cond_l + ED_exp_l + ED_eva_l;

%% 用能效率计算
W_Total = W_comp_h + W_comp_l; % 总实际耗功 [kW]
eta_ex = (W_Total-ED_Total) / W_Total * 100; % 基于热力学第二定律的效率定义

%% 结果输出
fprintf('系统总㶲损: %.2f kW\n', ED_Total);
fprintf('系统用能效率: %.2f%%\n', eta_ex);

