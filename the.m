clc
clear all
close all

Attenuation = [];
i=0;
d=4;
f=28*(10^9);
c=3*(10^8);
FSPL = 10*log10((4*pi*d*f)/c);
Gtx = 15.0;
Grx = 15.0;
Ptx_dBm = -11.20;
Ptx_dB = -11.20-30;

for n=1:8 
    Attenuation(n)=i;
    [filename, pathname]=uigetfile('*.txt', 'pick a file'); %% takes the input filename and path from user
    Power = csvread(fullfile(pathname,filename)); %% reads data from the file specified in path and creates matrix
    Power_dBm = Power(:,2); %% Rx power in dBm
    Power_mW = 10.^(Power_dBm/10); %% Converts Rx power from dBm to mW
    [Max_power, Index] = max(Power_mW); %% Maximum power value in mW
%     Index = find(Power_mW == Max_power); %% Gives the index of maximum power value
    Y = Power_mW(Index-39:Index+40); %% Takes values of 80 samples centered at index
    Energy = sum(Y); %% adds all 80 sample values (area under the curve)
    Rxpower_dBm(n) = 10*log10(Energy); %% converts mW to dBm
%     Rxpower_dB(n) = Rxpower_dBm(n)-30;
    Sys_Gain(n) = Rxpower_dBm(n) - Ptx_dB - Gtx - Grx + FSPL + Attenuation(n);
    i=i+10;
end

%% find slope nearest to -1.00
for n=2:8
    slope(n) = (Rxpower_dBm(n)-Rxpower_dBm(n-1))/(Attenuation(n)-Attenuation(n-1)); %% calculates slope using (y2-y1)/(x2-x1) 
    desired_slope=-1.0000;
    i=(desired_slope-slope(n)); %% differece between actual slope and desired slope
    R1(n) = Attenuation(n-1);
    R2(n) = Attenuation(n);
    if 0<i && i<0.01 %% find out the points at which the difference is minimum
        n2=Attenuation(n); %% x2 = upper bound of attenuation value
        n1=Attenuation(n-1); %% x1 = lower bound of attenuation value
        y2=Rxpower_dBm(n); %% y2 = upper value of recorded power
        y1=Rxpower_dBm(n-1); %% y1 = lower value of recorded power
        display(slope);
    end
end

%% plot the results
plot(Attenuation,Rxpower_dBm,'b','LineWidth',5);
grid on
xlabel('Attenuation (dB)');
ylabel('Area Under PDP - Rec. Power (dBm)');
title('Free Space Calibration');
annotation('textbox',[.2 .1 .3 .3],'String','Slope = -1.0057','FitBoxToText','on');
hold on
plot(n1,y1,'r*','MarkerSize',30,'LineWidth',4);
hold on
plot(n2,y2,'r*','MarkerSize',30,'LineWidth',4);
legend('Rec. Power (dBm) vs Attenuation(dB)','Linear Range Limits');
hold off

%% Table
R1 = R1';
R2 = R2';
Slope = slope';
Sys_Gain = Sys_Gain';
T = table(R1,R2,Sys_Gain,Slope);


