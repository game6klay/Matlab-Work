clc 
clear all
close all

Gtx = 15.0;
Grx = 15.0;
Ptx_dBm = -11.20;
Sys_Gain = 56.3;
sample_width = (1/16)*10e-9;
Samples = (1500*10e-9)/sample_width;

filename = '/Users/jay/Desktop/Calibration Area/Calibration 2/Attenuation 0 dB/IQsquared.txt';
Power = csvread(filename);
Power_dBm = Power(:,2);
time = Power(:,1);
Min_power = min(Power_dBm);
[Max_power, Index]= max(Power_dBm);
start_index = Index + Samples;
end_index = start_index + 299;
n=1;
signal_width = (16*10e-9)/sample_width;
for i=start_index:1:end_index
        Noisefloor(n)=Power_dBm(i);
        n = n+1;
end
mean_Noise = mean(Noisefloor);
threshold = mean_Noise + 5;
plot(time,Power_dBm);
hold on
plot(time,threshold,'r','LineWidth',5);
hold off
Prx = 0;
h=0;
k=0;
while(n <= length(Power_dBm))
    if Power_dBm > threshold
        Prx = Prx + Power_dBm(n);
        k = k+1;
    end
    if k < signal_width
        Prx = 0;
    else
        Signal_power(h)=Prx;
        h = h+1;
    end
    n = n+1;
    k=0;
end
Power_rec = sum(Signal_power(1:end));
Prx_true = Power_rec - Sys_Gain;
PL = Ptx_dBm - Prx_true + Gtx + Grx;
display(PL);
RF_power = Ptx_dBm-PL;
display(RF_power);


