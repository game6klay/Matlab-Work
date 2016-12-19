clc
clear all
close all

Attenuation = [0, 10, 20, 30, 40, 50, 60, 70];
d=4;
f=28*(10^9);
c=3*(10^8);
FSPL = 10*log10((4*pi*d*f)/c);
Gtx = 15.0;
Grx = 15.0;
Ptx_dBm = -11.20;
Ptx_dB = -11.20-30;
n=0;

for i=1:1:length(Attenuation) 
    textfilename = ['/Users/jay/Desktop/Calibration Area/Calibration 2/Attenuation ' num2str(n) ' dB/IQsquared.txt']; %% takes the input filename and path from user
    Power = csvread(textfilename); %% reads data from the file specified in path and creates matrix
    Power_dBm = Power(:,2); %% Rx power in dBm
    Power_mW = 10.^(Power_dBm/10); %% Converts Rx power from dBm to mW
    [Max_power, Index] = max(Power_mW); %% Maximum power value in mW
%     Index = find(Power_mW == Max_power); %% Gives the index of maximum power value
    Y = Power_mW(Index-39:Index+40); %% Takes values of 80 samples centered at index
    Energy = sum(Y); %% adds all 80 sample values (area under the curve)
    Rxpower_dBm(i) = 10*log10(Energy); %% converts mW to dBm
%     Rxpower_dB(n) = Rxpower_dBm(n)-30;
    n=n+10;
end
beta=cov(Attenuation,Rxpower_dBm)/var(Attenuation);
yEst=(beta(2)*Attenuation)+beta(3);
%% find slope nearest to -1.00
h=1;
for i=1:8
    for j=i+1:8
        slope(h) = (Rxpower_dBm(j)-Rxpower_dBm(i))/(Attenuation(j)-Attenuation(i)); %% calculates slope using (y2-y1)/(x2-x1) 
        Intercept(h) = yEst(i)-(slope(h)*(Attenuation(1)));
        desired_slope=-1.0000;
        k(h) = desired_slope-slope(h); %% differece between actual slope and desired slope
        R1(h) = Attenuation(i);
        R2(h) = Attenuation(j);
        if 0<k(h) && k(h)<0.01 %% find out the points at which the difference is minimum
            n2=Attenuation(j); %% x2 = upper bound of attenuation value
            n1=Attenuation(i); %% x1 = lower bound of attenuation value
            y2=Rxpower_dBm(j); %% y2 = upper value of recorded power
            y1=Rxpower_dBm(i); %% y1 = lower value of recorded power
        end
        Sys_Gain(h) = yEst(j)- Ptx_dB - Gtx - Grx + FSPL + Attenuation(j);
        h=h+1;
    end
end
T = [R1', R2', Sys_Gain', slope', Intercept'];

%% plot the results
plot(Attenuation,Rxpower_dBm,'b','LineWidth',5);
grid on
hold on
plot(Attenuation,yEst,'M','LineWidth',5);
xlabel('Attenuation (dB)');
ylabel('Area Under PDP - Rec. Power (dBm)');
title('Free Space Calibration');
annotation('textbox',[.2 .1 .3 .3],'String','Slope = -1.0057','FitBoxToText','on');
hold on
plot(n1,y1,'r*','MarkerSize',30,'LineWidth',4);
hold on
plot(n2,y2,'r*','MarkerSize',30,'LineWidth',4);
legend('Rec. Power (dBm) vs Attenuation(dB)','MMSE Fit line','Linear Range Limits');
hold off


