function script_for_article_2()
clc; clear all;

global gt gu gi;

% temp_cx();
% return;

% ��������� ������� �������� � ���������� ��
rx      = 0;
ry      = 100;
rz      = 0;
Vx      = 10;
Vy      = 0;
Vz      = 0;

psi     = deg2rad(0);
theta   = deg2rad(0);
gamma   = deg2rad(0);
omega_x = deg2rad(0);
omega_y = deg2rad(0);
omega_z = deg2rad(0);
% u       = 0;


% ������� � ��������������� �����
dual_omega = [0; omega_x; omega_y; omega_z;  0; Vx; Vy; Vz];                  % ��������� ������� � �������� ��������
dual_q     = dq_from_euler_translation([gamma; psi; theta], [rx; ry; rz]); % ��������� ���������� � ��������� ��

% �������������� �������
options = odeset('RelTol', 1e-2);
[t, x] = ode45(@dx_dt, [0:0.5:15], [dual_omega, dual_q], options);

d_omega = x(:, 1:8);
d_q     = x(:, 9:16);

figure(1)
% clf
x_max = 550;
y_max = 130;
% axis([0 x_max -30 y_max])
hold on
grid on
% figure('Color', [1 1 1]);
xlabel('\it r_x ,  �');
ylabel('\it r_z ,  �');
zlabel('\it r_y ,  �');
for i = 1:1:length(d_q)
    r                 = dq_get_translation_vector(d_q(i,:)'); % ��������� ������ ����
    rr(i, :) = r;
    [psi, theta, gamma] = dq_get_rotation_euler(d_q(i,:)');     % ���������� ��
    phi(i,:) = [gamma psi theta];
    
    % plot(r(1), r(2), 'o');
    plot3(r(1), r(3), r(2), 'k.'); % , LineStyle, '--', LineWidth, 1.0);
    line([r(1), r(1)], [r(3), r(3)], [r(2), 0]);
end

% plot_gost(t,  rad2deg(x(:,2:4)), '\it t,  �', '\rm \omega ,\it  ����/�',         'fig_omega_t');
% legend('\omega_{\it x}', '\omega_{\it y}', '\omega_{\it z}', 'Location', 'northeast', 'Orientation', 'horizontal');

% plot_gost(t,  x(:,6:8), '\it t,  �', '\bf V ,\rm \it  �/�',         'fig_v_t');
% legend('\it V_x', '\it V_y', '\it V_z', 'Location', 'northeast', 'Orientation', 'horizontal');

% plot_gost(t,  x(:,9:12), '\it t,  �', '\bf q_1',         'fig_q1_t');
% legend('\it q_0', '\it q_1', '\it q_2', '\it q_3', 'Location', 'northeast', 'Orientation', 'horizontal');

% plot_gost(t,  x(:,13:16), '\it t,  �', '\bf q_2',         'fig_q2_t');
% legend('\it q_0', '\it q_1', '\it q_2', '\it q_3', 'Location', 'northeast', 'Orientation', 'horizontal');

% plot_gost(t,  rr(:,1:3), '\it t,  �', '\bf r ,\rm \it  �/� ',         'fig_r_t');
% legend('\it r_x', '\it r_y', '\it r_z', 'Location', 'northeast', 'Orientation', 'horizontal');

% plot_gost(t,  rad2deg(phi(:,1:3)), '\it t,  �', '\gamma, \psi, \vartheta,  \it  ����/� ',         'fig_phi_t');
% legend('\gamma', '\psi', '\vartheta', 'Location', 'northeast', 'Orientation', 'horizontal');

end

function dx_dt = dx_dt(t, x)
dual_omega = x(1:8);  % ������������ ������� � �������� ���������
dual_q     = x(9:16); % ������������ ��������� �� ������ ������ ���� � ������ ����

omega = dual_omega(2:4); % ������� ��������, [���/�]
V     = dual_omega(6:8); % �������� ��������, [�/�]

% ppsi = rad2deg(atan(2*(dual_q(1)*dual_q(3) - dual_q(2)*dual_q(4)/quatnorm(dual_q(1:4)))))
[psi theta gamma] = dq_get_rotation_euler(dual_q);     % ���� ����������, [���]
r                 = dq_get_translation_vector(dual_q); % ������-������ ��������� ��, [�]

% ��������� � �������������� ��
g      = 9.807; % ��������� ���������� �������, [�*�^2]
rho    = 1.225; % �������� ��������� �� ������ ���� ��� t=+15, [��/�^3]
mass   = 1;     % ����� ��, [��]
l_wing = 2;     % ������ (�����) �����, [�]
S      = 2;     % ������� �����, [�^2]
ba     = 1;     % ���
Jzz    = 0.37;  % ��� ����� �� 1 ��, 2 ����� ��� ������    % ������ ������� ������ ��� OZ
ly     = -0.1;  % ����� ��������� ��������� ���� ������������ ������ ���� �� �� ��� OY, [�]

% -------------------------------------------------------------------------
% ����� � ��������������
% -------------------------------------------------------------------------
W_0_nsk = [0.0; 0.0; 0.0]; % �����������: [��->�����; �����->�����; �����->������]
W_0     = nsk2ssk(gamma, psi, theta)*W_0_nsk;
s = rng;
W_tur   = [0.0; 0.0; 0*3*sin(t)];

% W_tur_delta_x = 1.06;
% W_tur_Lx      = 200;
% Hx_sys = tf([W_tur_delta_x*sqrt(2*(V(1)-W_0(1))/W_tur_Lx)], [1, (V(1)-W_0(1))/W_tur_Lx])

W = W_0 + W_tur;

% �������������� ���������
Va      = V - W;                             % ������ ���������� ��������, [�/�]
Va_norm = sqrt(Va(1)^2 + Va(2)^2 + Va(3)^2); % ��������� ��������, [�/�]
q       = (rho*Va_norm^2)/2;                 % ���������� �����, [��/(�*�^2)]
alpha   = atan(-Va(2)/Va(1));                % ���� �����, [���]
betta   = asin(Va(3)/Va_norm);               % ���� ����������, [���]

% if (abs(alpha) > deg2rad(20))
%     disp('ERROR: alpha > +-20')
%     return
% end

% -------------------------------------------------------------------------
% ���������������� ����
% -------------------------------------------------------------------------
% % NACA 2412
% alpha_interp = deg2rad([   -20;    -15;    -10;     -5;      0;      5;      10;      15;      20]);
% Cx_interp    =         [ 0.100;  0.058;  0.027;  0.010;  0.008;  0.022;   0.051;   0.093;   0.145];
% Cy_interp    =         [-0.747; -0.550; -0.341; -0.120;  0.103;  0.325;   0.537;   0.740;   0.922];
% Cmz_interp   =         [-0.204; -0.165; -0.122; -0.076; -0.029;  0.017;   0.063;   0.105;   0.143];
% Cd_interp    =         [ 0.186;  0.154;  0.087; -0.203;   0.751; 0.422;   0.319;   0.288;   0.269];
% 
% betta_interp    = deg2rad([    -5;      0;      5]);
% Cz_interp_betta =         [-0.001;    0.0;  0.001];
% Cd_interp_betta =         [-0.010;    0.0;  0.010];
% 
% Cx  = interp1(alpha_interp, Cx_interp,   alpha, 'linear', 'extrap'); % ����������� ���� �������������, ������� �� ���� �����
% Cy  = interp1(alpha_interp, Cy_interp,   alpha, 'linear', 'extrap'); % ����������� ��������� ����, ������� �� ���� �����
% Cmz = interp1(alpha_interp, Cmz_interp,  alpha, 'linear', 'extrap')*alpha; 
% Cd  = interp1(alpha_interp, Cd_interp,   alpha, 'linear', 'extrap'); % ����� �������� �� �������� ������ �����
% 
% Cy_betta  = -0.0*betta;
% Cz_betta  = -0.0*betta; %interp1(betta_interp, Cz_interp_betta, betta, 'linear', 'extrap'); % ����������� ������� ����, ������� �� ���� ����������
% Cd_betta  = -0.0*betta; %interp1(betta_interp, Cd_interp_betta, betta, 'linear', 'extrap'); % ����� �������� �� �������� ������ �����, �� ���� ����������
% 
% 
% Ra_wing     = [0.202-Cd 2 Cd_betta]; % ����� ���������� ���� � ���, ������� �� ���� �����
% 
% Fa_pssk = [-Cx Cy+Cy_betta Cz_betta]*q*S;          % ������ ���������������� ���� � ����
% Fa      = Fa_pssk*pssk2ssk(alpha, betta);  % ������� � ���
% 
% % ������
% Ma = cross(Ra_wing, Fa)

% ���������� ��������, ���� ����������� ������ ���� � ������������ ����������� �� 0 �� 20 ��������.
delta_left  = deg2rad(0.0); % ���� ���������� ������ ����, [���]
delta_right = deg2rad(0.0); % ���� ���������� ������� ����, [���]

% ����������� ����������� ������ �� ������ �� ����, [���]
delta_x = 0.5*(delta_left  - delta_right);
delta_y = 0.5*(delta_right - delta_left);
delta_z = 0.5*(delta_left  + delta_right);

% ���������������� �����������
cx_alpha_0 = 0.008;
cx_alpha   = 0.05;
cx_alpha_2 = 1.1;

cy_alpha_0 = 0.1 + 0.02;
cy_alpha   = 2.3;
cy_delta   = 0.2;

cz_betta_0 =  0.0;
cz_betta   = -0.11;
cz_delta   =  0.0;

mx_betta_0 = 0.0;
mx_betta   = 0.0;
mx_delta   = 0.0;

my_betta_0 =  0.0;
my_betta   = -0.001;
my_delta   =  0.003;

mz_alpha_0 = -0.035;
mz_alpha   = -1.0;
mz_alpha_2 = -10.0;
mz_delta   =  0.01;

cx = cx_alpha_0 + cx_alpha*alpha + cx_alpha_2*alpha^2;
cy = cy_alpha_0 + cy_alpha*alpha + cy_delta*delta_z;
cz = cz_betta_0 + cz_betta*betta + cz_delta*delta_y;

mx = mx_betta_0 + mx_betta*betta + mx_delta*delta_x;
my = my_betta_0 + my_betta*betta + my_delta*delta_y;
mz = mz_alpha_0 + mz_alpha*alpha + mz_delta*delta_z; % + mz_alpha_2*alpha^2 ;

Fa_pssk = [-cx; cy; cz]*q*S;          % ������ ���������������� ���� � ����

Fa = pssk2ssk(alpha, betta)*Fa_pssk;  % ������� � ���
Ma =  [mx; my; mz]*q*ba*S;            % ������ � ����

% [t Fa rad2deg(alpha) rad2deg(betta) mz];

% -------------------------------------------------------------------------
% ���� �������
% -------------------------------------------------------------------------
Fg_nsk = [0; -mass*g; 0];
Fg     = nsk2ssk(gamma, psi, theta)*Fg_nsk;

% -------------------------------------------------------------------------
% ���� � ������ ���� ���������
% -------------------------------------------------------------------------
Rp      = [-0.1; -0.2; 0.0];       % ����� ���������� ���� � ���
% Rp_matr = [0 -Rp(3) Rp(2); Rp(3) 0 -Rp(1); -Rp(2) Rp(1) 0]; % ����� ���������� ���� � ��������� ���� ��� ���������� ���������

engine_thrust =  2.0; % 1000*(0 - theta) % + 0.5*(100 - r(2));

Fp = [engine_thrust; 0; 0]; % ���� ���
Mp = cross(Rp, Fp);       % ������ � ���

Mp = Mp + [0; -engine_thrust*0.01; 0]; % ������ �� �����
% -------------------------------------------------------------------------
% ������ �������
% -------------------------------------------------------------------------
Jq = [1  0       0        0;
      0  3.670   0        0;
      0  0       3.710    0;
      0  0       0        0.104];
mq = [1   0    0    0;
      0  mass  0    0;
      0   0   mass  0;
      0   0    0   mass]; 
  
dual_J = [  Jq       zeros(4); 
          zeros(4)     mq];

% -------------------------------------------------------------------------
% ����� ��� � �������� � ��������������� �����
% -------------------------------------------------------------------------
F = [0; 0; 0];
F = F + Fg;
F = F + Fa;
F = F + Fp;

M = [0; 0; 0];
M = M + Ma;
M = M + Mp;

% ������� � ���� � ��������������� �����
dual_F = [0; M; 0; F];

disp([num2str(t, '%10.2f:'), char(9), ...
      'alpha:', char(9), num2str(rad2deg(alpha), '%10.2f'), char(9), ...
      'betta:', char(9), num2str(rad2deg(betta), '%10.2f'), char(9), ...
      'psi, theta, gamma:', char(9), num2str(rad2deg(psi), '%10.2f'), ' ', ... 
                                     num2str(rad2deg(theta), '%10.2f'), ' ', ...
                                     num2str(rad2deg(gamma), '%10.2f'), char(9), ...
      'F:',     char(9), num2str(F', '%10.2f'), char(9), ...
      'M:',     char(9), num2str(M', '%10.2f'), char(9), char(9), ...
      'V:',     char(9), num2str(V', '%10.2f'), char(9), ...
      'r:',     char(9), num2str(r', '%10.2f'), char(9), char(9), ...
      'engine:',char(9), num2str(Fp(1:2)', '%10.2f'), char(9), char(9)] ...
  );

% -------------------------------------------------------------------------
% ��������� ��������
% -------------------------------------------------------------------------
d_dual_omega_dt = dual_J \ (dual_F - dq_cross([dual_omega(1:4); 0; 0; 0; 0], (dual_J*dual_omega))); 
d_dual_q_dt     = 0.5*dq_multiply(dual_q, dual_omega);


dx_dt = [d_dual_omega_dt; d_dual_q_dt];

end

function temp_cx()
alpha = deg2rad(-10:0.1:10);
cx = -0.035 - 1.0*alpha - 10.0.*alpha.^2;
hold on
grid on
plot(rad2deg(alpha), cx);

end