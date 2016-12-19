clc
clear all
close all

Attenuation = [0, 10, 20, 30, 40, 50, 60, 70];
d=4;
f=28e9;
c=3e8;
FSPL = 20*log10((4*pi*d*f)/c);
Gtx = 15.0;
Grx = 15.0;
Ptx_dBm = -11.20;
Ptx_dB = -11.20-30;
n=0;

for i=1:1:length(Attenuation) 
    textfilename = ['/Users/jay/Desktop/Calibration Area/Calibration 2/Attenuation ' num2str(n) ' dB/IQsquared.txt']; %% takes the input filename and path from user
    Power = csvread(textfilename); %% Reads data from the file specified in path and creates matrix
    Power_dBm = Power(:,2); %% Rx power in dBm
    Power_mW = 10.^(Power_dBm/10); %% Converts Rx power from dBm to mW
    [Max_power, Index] = max(Power_mW); %% Maximum power value in mW
    Y = Power_mW(Index-40:Index+39); %% Takes values of 80 samples centered at index
    Energy = sum(Y); %% Adds all 80 sample values (area under the curve)
    Rxpower_dBm(i) = 10*log10(Energy); %% Converts mW to dBm
    n=n+10;
end

%% Find the parameters
h=1;
for i=1:length(Attenuation) 
    for j=i+1:length(Attenuation)             
        Desired_slope = -1.0000;    
        X_avg=mean(Attenuation(i:j)); %% Average value of range
        Y_avg=mean(Rxpower_dBm(i:j)); %% Average value of power over selected range
        X_value=Attenuation-X_avg; %% According to the formula of slope
        Y_value=Rxpower_dBm-Y_avg;
        Slope(h)=(sum(X_value(i:j).*Y_value(i:j))/sum(X_value(i:j).^2));
        Difference(h)= Desired_slope - Slope(h); %% To select the best value of slope for a particular range
        Intercept(h)= Y_avg-(Slope(h)*X_avg); %% Formula of Intercept
        Rec_power(h)= Intercept(h)+(Slope(h)*X_avg); %% By formula combining slope and intercept
        Sys_Gain(h) = Intercept(h)- Ptx_dBm - Gtx - Grx + FSPL; %% Calculate the system gain
        R1(h)=Attenuation(i);
        R2(h)=Attenuation(j);
        h=h+1;
    end
end
T = [R1', R2', Slope', Intercept', Sys_Gain'];
Min_diff = min(abs(Difference)); %% Taking minimum of absolute values of difference to generalize all cases 
Index = find(Difference==Min_diff); %% To derive points of range where desired slope is derived
n1 = R1(Index);
n2 = R2(Index);
Y1 = Rxpower_dBm(find(Attenuation==n1));
Y2 = Rxpower_dBm(find(Attenuation==n2));

%% MMSE line estimation

yEst=Intercept(Index)+(Slope(Index)*Attenuation);

%% plot the results
plot(Attenuation,Rxpower_dBm,'b','LineWidth',6);
grid on
hold on
plot(Attenuation,yEst,'r','LineWidth',6);
xlabel('Attenuation (dB)','FontSize',15,'FontWeight','Bold');
ylabel('Area Under PDP - Rec. Power (dBm)','FontSize',15,'FontWeight','Bold');
title('Free Space Calibration:10.15.2015 - Calibration 2','FontSize',20);
annotation('textbox',[.2 .1 .4 .4],'String',{sprintf('Slope: %s', num2str(Slope(Index))), sprintf('Intercept: %s', num2str(Intercept(Index))), sprintf('RX Gain: %s', num2str(Sys_Gain(Index))), '20 dB to 30 dB'},'FitBoxToText','on','FontSize',15);
hold on
plot(n1,Y1,'go','MarkerSize',15,'LineWidth',5);
hold on
plot(n2,Y2,'go','MarkerSize',15,'LineWidth',5);
legend({'Rec. Power (dBm) vs Attenuation(dB)','MMSE Fit line','Linear Range Limits'},'FontSize',12,'FontWeight','Bold');
hold off


