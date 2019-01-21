% ����������� �� 2-� �������
% ��� ����� ����������� ����� ��� X ������� �������

clc; clear all;

% ������ � �����, �� ����� �����, ����� ��������� �� 0 �� 180 �������� ������ ��� Z
q0 = dq_from_euler_translation(deg2rad([0, 0, 0]), [0 0 0])

% ����� ������� ����� � �������� �� �����, ����� ��������� �� 0 �� 180 �������� ������ ��� Z
q1 = dq_from_euler_translation(deg2rad([0, 0, 0]), [1 0 0])

% ����� ������� ����� ��� ������� �� �����, �� ���������
q2 = dq_from_euler_translation(deg2rad([0, 0, 0]), [1 0 0])


% ��������� ���������: q0*q1*q2
q_start = dq_multiply(q0, q1, q2);

[angle_gamma, angle_psi, angle_theta] = dq_get_rotation_euler(q_start)
dq_get_translation_vector(q_start)


% �������� ���������
q_finish = dq_from_euler_translation(deg2rad([0, 0, 0]), [0 1.5 0])

% ����� ��������������� ������
q_h_z = dq_from_euler_translation(deg2rad([0, 0, 0.2]), [0 0 0]);   % ��� �������� ������ ��� Z
eps = 0.005;  % ��������
i = 1;    % ������ �����
i_max = 700; % ������������ ���������� �����

figure(1)
clf
x_max = 3;
y_max = 3;
axis([-x_max x_max -y_max y_max])
hold on
grid on

while i < i_max
    % ---------------------------------------------------------------------
    % ����� �� ������ ���������� � ������������� �����������: q0*q_h_z*q1*q2
    % ---------------------------------------------------------------------
    q_cur_1_plus = dq_multiply(q0, q_h_z, q1, q2);
    
    % ����� �� ������ ���������� � ������������� �����������
    q_cur_1_minus = dq_multiply(q0, dq_conj(q_h_z), q1, q2);
    
    % [angle_gamma, angle_psi, angle_theta] = dq_get_rotation_euler(q_cur_1_plus);
    % dq_get_translation_vector(q_cur_1_plus);

    % [angle_gamma, angle_psi, angle_theta] = dq_get_rotation_euler(q_cur_1_minus)
    % dq_get_translation_vector(q_cur_1_minus)

    % ���������, ����� ������������
    q_delta_plus     = dq_multiply(dq_conj(q_cur_1_plus), q_finish); % ������ ������� ����� ������� � �������� ����������
    delta_norm_plus  = norm(dq_get_translation_vector(q_delta_plus)); % ���������� �� �������� �����

    q_delta_minus    = dq_multiply(dq_conj(q_cur_1_minus), q_finish);
    delta_norm_minus = norm(dq_get_translation_vector(q_delta_minus)); % ���������� �� �������� �����
    
    if (delta_norm_plus > delta_norm_minus)
        q0 = dq_multiply(q0, dq_conj(q_h_z));
    else
        q0 = dq_multiply(q0, q_h_z);
    end
    
    % [angle_gamma, angle_psi, angle_theta] = dq_get_rotation_euler(q_delta)
    % dq_get_translation_vector(q_delta)
    

    % ---------------------------------------------------------------------
    % ����� �� ������ ���������� � ������������� �����������: q0*q1*q_h_z*q2
    % ---------------------------------------------------------------------
    q_cur_2_plus = dq_multiply(q0, q1, q_h_z, q2);
    
    % ����� �� ������ ���������� � ������������� �����������
    q_cur_2_minus = dq_multiply(q0, q1, dq_conj(q_h_z), q2);
    
    % [angle_gamma, angle_psi, angle_theta] = dq_get_rotation_euler(q_cur_1_plus);
    % dq_get_translation_vector(q_cur_1_plus);

    % [angle_gamma, angle_psi, angle_theta] = dq_get_rotation_euler(q_cur_1_minus)
    % dq_get_translation_vector(q_cur_1_minus)

    % ���������, ����� ������������
    q_delta_plus     = dq_multiply(dq_conj(q_cur_2_plus), q_finish);
    delta_norm_plus  = norm(dq_get_translation_vector(q_delta_plus)); % ���������� �� �������� �����

    q_delta_minus    = dq_multiply(dq_conj(q_cur_2_minus), q_finish);
    delta_norm_minus = norm(dq_get_translation_vector(q_delta_minus)); % ���������� �� �������� �����
    
    if (delta_norm_plus > delta_norm_minus)
        % q1 = dq_multiply(q0, q1);
        q1 = dq_multiply(q1, dq_conj(q_h_z));
    else
        % q1 = dq_multiply(q0, q1);
        q1 = dq_multiply(q1, q_h_z);
    end
    
    % [angle_gamma, angle_psi, angle_theta] = dq_get_rotation_euler(q_delta)
    % dq_get_translation_vector(q_delta)

    
    % ---------------------------------------------------------------------
    % ������ ��������
    % ---------------------------------------------------------------------
    % ����� 1
    q_plot = dq_multiply(q0, q1);
    q_plot_xyz_1 = dq_get_translation_vector(q_plot);
    plot(0, 0, 'o');
    plot(q_plot_xyz_1(1), q_plot_xyz_1(2), 'o');
    line([0 q_plot_xyz_1(1)], [0 q_plot_xyz_1(2)]);
    
    % ����� 2
    q_plot = dq_multiply(q_plot, q2);
    q_plot_xyz_2 = dq_get_translation_vector(q_plot);
    plot(q_plot_xyz_2(1), q_plot_xyz_2(2), 's');
    line([q_plot_xyz_1(1) q_plot_xyz_2(1)], [q_plot_xyz_1(2) q_plot_xyz_2(2)]);
    
    pause(0.01);
    
    % ---------------------------------------------------------------------
    % ���������� ��������� ���������� �������� �����
    % ---------------------------------------------------------------------
    q_current = dq_multiply(q0, q1, q2);
    q_delta_global = dq_multiply(dq_conj(q_current), q_finish);
    
    if (norm(dq_get_translation_vector(q_delta_global)) < eps)
        break;
    end
    
    i = i + 1;
    
    [i norm(dq_get_translation_vector(q_delta_global))];
end
