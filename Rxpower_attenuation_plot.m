clc
clear all
close all

Attenuation = [0, 10, 20, 30, 40, 50, 60, 70];
for n=1:1:length(Attenuation)
    textfilename = ['IQsquared' num2str(n) '.txt'];
    Power = csvread(textfilename); %% creates matrix of data
    Power_dBm = Power(:,end); %% Rx power in dBm
    Power_mW = 10.^(Power_dBm/10); %% Converts Rx power from dBm to mW
    Max_power = max(Power_mW); %% Maximum power value in mW
    Index = find(Power_mW == Max_power); %% Gives th index of maximum power value
    Y = Power_mW(Index-39:Index+40); %% Takes values of 80 samples centered at index
    Energy = sum(Y); %% adds all 80 sample values (area under the curve)
    Rxpower_dBm(n) = 10*log10(Energy); %% converts mW to dBm
end
for n=2:8
    slope(n) = (Rxpower_dBm(n)-Rxpower_dBm(n-1))/(Attenuation(n)-Attenuation(n-1));
    threshold=-1.0000;
    i=(threshold-slope(n));
    R1(n) = Attenuation(n-1);
    R2(n) = Attenuation(n);
    if 0<i && i<0.01
        n2=Attenuation(n);
        n1=Attenuation(n-1);
        y2=Rxpower_dBm(n);
        y1=Rxpower_dBm(n-1);
    end
end
%% least square estimation
Y=Rxpower_dBm.';
X=[Attenuation.' ones(1,length(Attenuation)).'];
alpha=inv(X'*X)*X'*Y;
yEst=(alpha(1)*Attenuation)+alpha(2);

%% plotting the results
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
legend('Rec. Power (dBm) vs Attenuation(dB)','Linear Range Limits');
hold off
R1 = R1';
R2 = R2';
Slope = slope';
T = table(R1,R2,Slope);
