%% EE5812 Automotive Control Systems
%  Auto Grading: Project 4
%  2/8/2023

%% ----------------------------------------------------------------------------------- %%
%  ------ NOTE:  This script is for Project3: Intelligent Cruise Control Design ------  %
%  ----------------------------------------------------------------------------------- %%

%% Step size
Step_size = 0.1;
Fixed_step_size = 0.1;
Time = HeadwaySpeed.time;
VC_d = HeadwaySpeed.signals(2).values(:,2);  %Command Speed
VC_a = HeadwaySpeed.signals(2).values(:,1);  %Actual Speed
TF_a = TractionForce(:,2);  %Traction Force
%% Velocity Controller
if choice == 1
    % Parameters
    % Desired Performance
    OS_d = 3;               % Desired persentage overshoot  [%]
    Time_settling_d = 15;   % Desired Settling time [sec]
    E_ss_d = 1e-5;          % Desired steady-state error [RPM]
    Diff_G_d = 0.5;         % Desired tolerance of the Gradient
    TF_d = 5000;            % Desired torlerance of Traction Force
     
    % Performance Calculation 
    % 1. Overshoot 
    V_UP = VC_a(400/Fixed_step_size:450/Fixed_step_size);
    V_UP_d = max(VC_d);
    V_Low_d = min(VC_d);
    V_UP_max = max(V_UP);
    OS_m = (V_UP_max-V_UP_d)/(V_UP_d-V_Low_d )*100;   % Measured overshoot of Speed
   
    % 2. Settling Time  
    T_S_R = 0.02*(VC_a(450/Fixed_step_size)-VC_a(400/Fixed_step_size));
    Settlingtime_thres = [V_UP_d-T_S_R, V_UP_d+T_S_R]; % Settling Time Thresholds
    
    Settling_Data_Set1=zeros(1,501);
    Cntr1 = 1;
    for aa = 400/Fixed_step_size:450/Fixed_step_size
         if (VC_a(aa) <= Settlingtime_thres(1)) || (VC_a(aa) >= Settlingtime_thres(2))
             Settling_Data_Set1(Cntr1) =  Time(aa);
             Cntr1 = Cntr1 + 1;
         end
    end
    
    Settling_Data_Set2=zeros(1,501);
    Cntr2 = 1;
    for aa = 500/Fixed_step_size:550/Fixed_step_size
         if (VC_a(aa) <= Settlingtime_thres(1)) || (VC_a(aa) >= Settlingtime_thres(2))
             Settling_Data_Set2(Cntr2) =  Time(aa);
             Cntr2 = Cntr2 + 1;
         end
    end

    Time_Settling_m1 = max( Settling_Data_Set1)-410;   %Settling Time for Speed up
    Time_Settling_m2 = max( Settling_Data_Set2)-500;   %Settling Time for Gradient
    Time_Settling_m = max(Time_Settling_m1,Time_Settling_m2);
    
    % 3. Steady-state Error 
    SS_Error = VC_a(490/Fixed_step_size)-V_UP_d;
    
    % 4. Gradient Speed Difference 
    V_G = VC_a(500/Fixed_step_size:550/Fixed_step_size);
    V_G_min = min(V_G);
    Diff_V_m = V_UP_d-V_G_min;   % Measured Differnce of Gradient Speed
    
    % 5. Traction Force Tolerance 
    TF_UP = TF_a(400/Fixed_step_size:450/Fixed_step_size);
    TF_max = max(TF_UP);
    
   % Performances Checking
        %  1. Overshoot Checking
        if OS_m <= OS_d
            Grade_choice = 3;      % Full credits
            Comment_choice = 'FullCredits: Overshoot Percentage is less than 3%';
        elseif OS_m <= 5
            Grade_choice = 1.5;      % Half credits
            Comment_choice = 'HalfCredits: Overshoot Percentage is more than 5% but less than 5%';
        else
            Grade_choice = 0;      % No credits
            Comment_choice = 'NoCredits: Overshoot Percentage is more than 5%';
        end
 
        %  2. Settling Time Checking
        if Time_Settling_m <= Time_settling_d
            Grade_st = 3;      % Full credits
            Comment_st = 'FullCredits: Settling Time is less than 15 Sec';
        elseif Time_Settling_m <= Time_settling_d+5
            Grade_st = 1.5;      % Half credits
            Comment_st = 'HalfCredits: Settling Time is more than 15 Sec but less than 20 Sec';
        else
            Grade_st = 0;    % No credits
            Comment_st = 'NoCredits: Settling Time is too much! (More than 20 Sec)';
        end
        
        %  3. Steady-state Error Checking
        if abs(SS_Error) <= E_ss_d
            Grade_ss = 3;      % Full credits
            Comment_ss = 'FullCredits: The steady-state value is 0';
        else
            Grade_ss = 0;    % No credits
            Comment_ss = 'NoCredits: The steady-state value is not 0';
        end
        
        %  4. Speed with Gradient Checking
        if abs(Diff_V_m) <= Diff_G_d
            Grade_G = 3;      % Full credits
            Comment_G = 'FullCredits: The Gradient Speed Difference is less than 0.5 m/s';
        elseif abs(Diff_V_m) <= 1.4*Diff_G_d
            Grade_G = 1.5;      % Half credits
           Comment_G = 'HalfCredits: The Gradient Speed Difference is less than 0.7 m/s';
        else
            Grade_G = 0;    % No credits
            Comment_G = 'NoCredits: The Gradient Speed Difference is more than 0.5 m/s';
        end
        
        %  5. Traction Force Checking
        if TF_max <= TF_d
            Grade_TF = 3;      % Full credits
            Comment_spt = 'FullCredits: The Traction Force is less than 700 N';
        elseif TF_max<= 300+TF_d
            Grade_TF = 1.5;      % Half credits
            Comment_spt = 'HalfCredits: The Traction Force is less than 1000 N';
        else
            Grade_TF = 0;    % No credits
            Comment_spt = 'NoCredits: The Traction Force is greater than 1000 N';
        end
        Grade = Grade_choice+Grade_st+Grade_ss+Grade_G+Grade_TF;
    
    % Display Comments
    MSGBOX = msgbox({Comment_choice,Comment_st,Comment_ss,Comment_G,Comment_spt},'Comments');
    set(MSGBOX, 'position', [100 220 550 150]);
    ah = get( MSGBOX, 'CurrentAxes');
    ch = get( ah, 'Children');
    set( ch, 'FontSize', 15); 
        
    %Plotting
    lbl = 'for Velocity Controller';
    figure(1);
    plot(Time,VC_a,Time,VC_d); grid minor;
    xlabel('Time [Sec]');
    ylabel('Speed [m/s]');ylim([23.5 27.5]);
    title(['Speed vs. Time ',lbl]);
    tx1 = text(100,24.5,['Overshoot Percentage: ',num2str(OS_m),' % | Grade: ', num2str(Grade_choice)]); tx1.Color = [0 0 0];
    tx2 = text(100,24.2,['2% Settling Time: ',num2str(Time_Settling_m),' [s] | Grade: ', num2str(Grade_st)]); tx2.Color = [0 0 0];
    tx3 = text(100,23.9,['Steady-State Error: ',num2str(SS_Error),' [m/s] | Grade: ', num2str(Grade_ss)]); tx3.Color = [0 0 0];
    tx4 = text(100,23.6,['Road Gradient speed Difference: ',num2str(Diff_V_m),' [m/s] | Grade: ', num2str(Grade_G)]); tx4.Color = [0 0 0];
    
    figure(2);
    plot(Time,TF_a); grid minor;
    xlabel('Time [Sec]');
    ylabel('Traction Force [N]'); ylim([0 5000]);
    title(['Traction Force vs. Time ',lbl]);
    tx5 = text(100,900,['Max Traction Force: ',num2str(TF_max),'  | Grade: ', num2str(Grade_TF)]); tx5.Color = [0 0 0];
    tx6 = text(100,600,['Total Grade: ', num2str(Grade)]); tx6.Color = [1 0 0];
    
%% Headway Controller
elseif choice == 2
    % Parameters
    Data_hw = HeadwaySpeed.signals(1).values;
    Data_F = TractionForce(:,2);
    Diff_hw_max_d = [1 1.25];
    Hw_ss_d = 75;
    E_rt_hw_d = [4 6];
    F_max_d = [5000 7000];
    lbl = 'for Headway Controller';
    
    % Calculation
    % 1. Maximum Headway Error from 150s to 350s
    Diff_hw_max = max(Data_hw(150/Step_size:350/Step_size))-DesiredHeadway(150/Step_size:350/Step_size,2);
    % 2. Steady-state Error of headway
    E_rt_hw = (Data_hw(105/Step_size)-DesiredHeadway(105/Step_size,2))*21/10; 
    % 3. Maximum Tractive Force from 100s to 400s
    F_max = max(Data_F(150/Step_size:301/Step_size));
    
    % Performances Checking
    % 1. Maximum difference of measured and desired headway from 150s to 350s
    if Diff_hw_max <= Diff_hw_max_d(1)
        Grade_diff_hw = 5;      % Full credits
        Comment_diff_hw = ['FullCredits: Maximum difference of measured and desired headway is less than ', num2str(Diff_hw_max_d(1)),' [m]'];
    elseif Diff_hw_max <= Diff_hw_max_d(2)
        Grade_diff_hw = 2.5;      % Half credits
        Comment_diff_hw = ['HalfCredits: Maximum difference of measured and desired headway is more than ', num2str(Diff_hw_max_d(1)),' [m] but less than ', num2str(Diff_hw_max_d(2)),' [m]'];
    else
        Grade_diff_hw = 0;      % No credits
        Comment_diff_hw = ['NoCredits: Maximum difference of measured and desired headway is more than ',num2str(Diff_hw_max_d(2)), ' [m]'];
    end
    % 2. Reaction Time Check
    if abs(E_rt_hw) <= E_rt_hw_d(1)
        Grade_E_rt_hw = 5;      % Full credits
        Comment_E_rt_hw = ['FullCredits: Reaction time of headway is less than ', num2str(E_rt_hw_d(1)),' [m]'];
    elseif abs(E_rt_hw) <= E_rt_hw_d(2)
        Grade_E_rt_hw = 2.5;      % Half credits
        Comment_E_rt_hw = ['HalfCredits: Reaction time of headway is more than ', num2str(E_rt_hw_d(1)),' [m] but less than ', num2str(E_rt_hw_d(2)),' [m]'];
    else
        Grade_E_rt_hw = 0;      % No credits
        Comment_E_rt_hw = ['NoCredits: Reaction time of headway is more than ',num2str(E_rt_hw_d(2)), ' [m]'];
    end
    % 3. Maximum Tractive Force from 100s to 400s
    if F_max <= F_max_d(1)
        Grade_F = 5;      % Full credits
        Comment_F = ['FullCredits: Maximum tractive force is less than ', num2str(F_max_d(1)),' [N]'];
    elseif F_max <= F_max_d(2)
        Grade_F = 2.5;      % Half credits
        Comment_F = ['HalfCredits: Maximum tractive force is more than ', num2str(F_max_d(1)),' [N] but less than ', num2str(F_max_d(2)),' [N]'];
    else
        Grade_F = 0;      % No credits
        Comment_F = ['NoCredits: Maximum tractive force is more than ',num2str(F_max_d(2)), ' [N]'];
    end
    Grade_ttl = Grade_diff_hw+Grade_E_rt_hw+Grade_F;
    
    % Msg box of comments
    MSGBOX = msgbox({Comment_diff_hw,Comment_E_rt_hw,Comment_F},'Comments');
    set(MSGBOX, 'position', [100 220 550 150]);
    ah = get( MSGBOX, 'CurrentAxes');
    ch = get( ah, 'Children');
    set( ch, 'FontSize', 15); 
    
    % Plotting
    figure(1);
    plot(HeadwaySpeed.time,HeadwaySpeed.signals(1).values); grid minor;
    xlabel('Time [Sec]');
    ylabel('Headway Distance [m]'); ylim([60 90]);
    title(['Headway Distance vs. Time ',lbl]);
    tx1 = text(50,62,['Max Diff. of Headway within T = [150 400]: ',num2str(Diff_hw_max(1)),' [m] | Grade: ', num2str(Grade_diff_hw)]); tx1.Color = [0 0 0];
    tx2 = text(50,65,['Reaction Time: ',num2str(E_rt_hw),' [s] | Grade: ', num2str(Grade_E_rt_hw)]); tx2.Color = [0 0 0];
    
    figure(2);
    plot(Time,TF_a); grid minor;
    xlabel('Time [Sec]');
    ylabel('Traction Force [N]'); ylim([0 5000]);
    title(['Traction Force vs. Time ',lbl]);
    tx3 = text(100,700,['Max Traction Force: ',num2str(F_max),' | Grade: ', num2str(Grade_F)]); tx3.Color = [0 0 0];
    tx4 = text(100,620,['Total Grade: ', num2str(Grade_ttl)]); tx4.Color = [1 0 0];

%% Intelligent Cruise Controller
else
% Parameters
    Data_hw = HeadwaySpeed.signals(1).values; 
    Data_v = HeadwaySpeed.signals(2).values(:,1); 
    Data_F = TractionForce(:,2);
    Diff_hw_max_d = [2 3];
    Hw_ss_d = 75;   % Desired steady-state Headway from 180 s to 300 s
    V_ss_d = 27;    % Desired steady-state Velocity from 161 s to 250 s
    E_ss_hw_d = 1e-2;
    E_ss_v_d = 1e-3;
    Hw_peak_d = [68 66];
    F_peak_d = -5000;
    lbl = 'for Intelligent Cruise Controller';
    
    % Calculation
    % 1. Maximum Headway Error from 150s to 350s
    Diff_hw_max = max(abs(Data_hw(160/Step_size:260/Step_size,1)-DesiredHeadway(160/Step_size:260/Step_size,2)));    % 1. Steady-state error of Headway from 210 s to 240 s
    % 2. Steady-state error of Velocity from 210 s to 240 s
    E_ss_v = abs(max(Data_v(450/Step_size:490/Step_size))-V_ss_d); 
    % 3. Peak value of Hheadway from 160 s to 240 s
    Hw_peak = min(Data_hw(100/Step_size:600/Step_size));
    % 4. Peak value of Traction Force from 160 s to 240 s
    F_peak = min(Data_F(100/Step_size:600/Step_size));
    
    % Performances Checking
    % Performances Checking
    % 1. Maximum headway error from 160s to 260s
    if Diff_hw_max <= Diff_hw_max_d(1)
        Grade_diff_hw = 5;      % Full credits
        Comment_diff_hw = ['FullCredits: Maximum headway error during headway control is less than ', num2str(Diff_hw_max_d(1)),' [m]'];
    elseif Diff_hw_max <= Diff_hw_max_d(2)
        Grade_diff_hw = 2.5;      % Half credits
        Comment_diff_hw = ['HalfCredits: Maximum headway error during headway control is more than ', num2str(Diff_hw_max_d(1)),' [m] but less than ', num2str(Diff_hw_max_d(2)),' [m]'];
    else
        Grade_diff_hw = 0;      % No credits
        Comment_diff_hw = ['NoCredits: Maximum headway error during headway control is more than ',num2str(Diff_hw_max_d(2)), ' [m]'];
    end
    % 2. Steady-state Error of Velocity
    if E_ss_v <= E_ss_v_d
        Grade_E_ss_v = 2.5;      % Full credits
        Comment_E_ss_v = ['FullCredits: Steady-state error of velocity is less than ', num2str(E_ss_v_d),' [m/s]'];
    else
        Grade_E_ss_v = 0;      % No credits
        Comment_E_ss_v = ['NoCredits: Steady-state error of velocity is more than ',num2str(E_ss_v_d), ' [m/s]'];
    end
    % 3. Minimum value of Headway
    if Hw_peak >= Hw_peak_d(1)
        Grade_hw_peak = 2.5;      % Full credits
        Comment_hw_peak = ['FullCredits: Minimum headway within [100 600] is more than ', num2str(Hw_peak_d(1)),' [m]'];
    elseif Hw_peak >= Hw_peak_d(2)
        Grade_hw_peak = 1;      % Half credits
        Comment_hw_peak = ['HalfCredits: Minimum headway within [100 600] is more than ', num2str(Hw_peak_d(2)),' [m] but less than ', num2str(E_ss_hw_d(1)),' [m]'];
    else
        Grade_hw_peak = 0;      % No credits
        Comment_hw_peak = ['NoCredits: Minimum headway within [100 600] is less than ',num2str(Hw_peak_d(2)), ' [m]'];
    end
    % 4. Minimum value of Traction Force
    if F_peak >= F_peak_d
        Grade_F_peak = 2.5;      % Full credits
        Comment_F_peak = ['FullCredits: Minimum value of Traction Force within [100 600] is more than ', num2str(F_peak_d),' [N]'];
    else
        Grade_F_peak = 0;      % No credits
        Comment_F_peak = ['NoCredits: Peak value of Traction Force within [100 600] is less than ',num2str(F_peak_d), ' [N]'];
    end
    Grade_ttl = Grade_diff_hw+Grade_E_ss_v+Grade_hw_peak+Grade_F_peak;
    
    % Msg box of comments
    MSGBOX = msgbox({Comment_diff_hw,Comment_E_ss_v,Comment_hw_peak,Comment_F_peak},'Comments');
    set(MSGBOX, 'position', [100 220 550 150]);
    ah = get( MSGBOX, 'CurrentAxes');
    ch = get( ah, 'Children');
    set( ch, 'FontSize', 15); 
    
    % Plotting
    figure(1);
    plot(HeadwaySpeed.time,HeadwaySpeed.signals(1).values); grid minor;
    xlabel('Time [Sec]');   
    ylabel('Headway Distance [m]'); ylim([0 300]);
    title(['Headway Distance vs. Time ',lbl]);
    tx1 = text(20,40,['Maximum Headway Error within T = [160 260]: ',num2str(Diff_hw_max),' [m] | Grade: ', num2str(Grade_diff_hw)]); tx1.Color = [0 0 0];
    tx2 = text(20,20,['Peak Value of headway error within T = [160 300]: ',num2str(Hw_peak),' [m] | Grade: ', num2str(Grade_hw_peak)]); tx2.Color = [0 0 0];  
    
    figure(2);
    plot(TractionForce(:,1),TractionForce(:,2)); grid minor;
    xlabel('Time [Sec]');
    ylabel('Traction Force [N]'); ylim([-5000 5000]);
    title(['Traction Force vs. Time ',lbl]);
    tx3 = text(20,-205,['Max Traction Force: ',num2str(F_peak),' | Grade: ', num2str(Grade_F_peak)]); tx3.Color = [0 0 0];
    
    figure(3);
    plot(HeadwaySpeed.time,HeadwaySpeed.signals(2).values(:,1),HeadwaySpeed.time,HeadwaySpeed.signals(2).values(:,2)); grid minor;
    xlabel('Time [Sec]');
    ylabel('Velocity [m/sec]'); ylim([20.5 28.5]);
    legend('Measured Velocity','Desired Velocity');
    title(['Velocity vs. Time ',lbl]);
    tx4 = text(20,21,['Steady-state Error of headway within T = [160 250]: ',num2str(E_ss_v),' | Grade: ', num2str(Grade_E_ss_v)]); tx4.Color = [0 0 0];
    tx5 = text(20,28,['Total Grade: ', num2str(Grade_ttl)]); tx5.Color = [1 0 0];
end
