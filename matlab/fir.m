clear all
clc

%broj bita odbirka (format je 1.23)
word_length = 24;
fraction_length = 23;

%specifikacija NF filtra
fir_ord = 20;
Wn=[0.1];
%odbirci prozorske funkcije koja se koristi
pravougaoni = rectwin(fir_ord+1);
%projektovanje FIR filtara koriscenjem funkcije fir1
b = fir1 (fir_ord, Wn, pravougaoni);
a = 1;
[u,Fs] = audioread('speech_dft.wav');
%filtriranje zvuka pomocu formiranog filtra
y = filter(b,a,u);

struct.mode = 'fixed';
strct.roundmode = 'floor';
struct.overflowmode = 'saturate';
struct.format = [word_length fraction_length];
q = quantizer(struct);

%koeficijenti filtra
fileIDb = fopen('coef.txt','w');
for i=1:fir_ord+1
    fprintf(fileIDb,num2bin(q,b(i)));
    fprintf(fileIDb,'\n');
end
fclose(fileIDb);

fileIDb = fopen('input.txt','w');
for i=1:length(y)
    fprintf(fileIDb,num2bin(q,u(i)));
    fprintf(fileIDb,'\n');
end
fclose(fileIDb);

fileIDb = fopen('expected.txt','w');
for i=1:length(y)
    fprintf(fileIDb,num2bin(q,y(i)));
    fprintf(fileIDb,'\n');
end
fclose(fileIDb);