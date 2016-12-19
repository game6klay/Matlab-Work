clc 
clear all
close all

d0 = 1;
f = 28*(10^9);
c = 3*(10^8);
lambda = c/f;
FSPL = 20*log10((4*pi*d0)/lambda);
n = 3;
d = 1:0.1:10;
PL_dB = FSPL +(n*10*log10(d));
plot(10*log10(d),PL_dB);
A = (PL_dB - FSPL - (n*10*log10(d)))^2;
dAdn = (-2*10*log10(d))*(PL_dB - FSPL - (n*10*log10(d)));