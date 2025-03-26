colordef black;
clear;
clc;
close all;
% loading CIE color functions: red=X,green=Y,blue=Z
r=load('redxyz.dat');
g=load('greenxyz.dat');
b=load('bluxyz.dat');
h=load('horseshoe.dat');
% insert filenames for reflectance and illuminant (without termination)
% remember to SAVE before running again the software !!! 
Illname="80";
Samplename="Shirt - Blue";
% check that the proper terminations are inserted for the files
Illfile="CRI_100_norm.dat";
reffile="CRI_8960_norm.dat";
Samplefile="sb_norm.txt";
Ill=load(Illfile);
ref=load(reffile);
Refl=load(Samplefile);
%if you want to select the files from a directory use the following lines
%Refl=uigetfile('*.txt','Open reflectance file')
%Ill=uigetfile('*.dat','Open illuminant file')
% interpolating data
lambda=350:0.01:700;
ri=interp1(r(:,1),r(:,2),lambda,'spline');
gi=interp1(g(:,1),g(:,2),lambda,'spline');
bi=interp1(b(:,1),b(:,2),lambda,'spline');
Refli=interp1(Refl(:,1),Refl(:,2),lambda,'spline');
Illi=interp1(Ill(:,1),Ill(:,2),lambda,'spline');
Refilli=interp1(ref(:,1),ref(:,2),lambda,'spline');
Refbeami=Refli.*Refilli;
beami=Refli.*Illi;
% integration
irill=trapz(lambda,ri.*Illi);
igill=trapz(lambda,gi.*Illi);
ibill=trapz(lambda,bi.*Illi);
% normalizing to achieve Y illuminant = 100
cap=100/igill;

% evaluation of normalized X,Y,Z values for the illuminant  
irillnorm=cap*irill;
igillnorm=cap*igill;
ibillnorm=cap*ibill;

% evaluation of normalized X,Y,Z values for the sample 
ir=cap*trapz(lambda,ri.*Refli.*Illi);
ig=cap*trapz(lambda,gi.*Refli.*Illi);
ib=cap*trapz(lambda,bi.*Refli.*Illi);
irref=cap*trapz(lambda,ri.*Refli.*Refilli);
igref=cap*trapz(lambda,gi.*Refli.*Refilli);
ibref=cap*trapz(lambda,bi.*Refli.*Refilli);
% plotting the object spectral reflectance
figure;
plot(lambda,Refli,'r');
ylim([0 1]);
xlabel('Wavelength [nm]');
ylabel('R');
title('Object Reflectance');
grid
% plotting the incident and reflectedspectral irradiance
figure;
plot(lambda,beami,'r',lambda,Illi,'w');
xlabel('Wavelength [nm]');
ylabel('Intensity [Arb. Unit]');
title('Incident (WHITE) and reflected (RED) beams irradiances');
grid
% evaluation of xyY coordinates
format long;
irxill=irill./(irill+igill+ibill);
igxill=igill./(irill+igill+ibill);
ibxill=ibill./(irill+igill+ibill);
irx=ir./(ir+ig+ib);
igx=ig./(ir+ig+ib);
ibx=ib./(ir+ig+ib);

irxref=irref./(irref+igref+ibref);
igxref=igref./(irref+igref+ibref);
ibxref=ibref./(irref+igref+ibref);

averR=ig/igillnorm;
disp(strcat('X value= ',num2str(ir)));
disp(strcat('Y value= ',num2str(ig)));
disp(strcat('Z value= ',num2str(ib)));
disp(' ');
disp(strcat('X value light=',num2str(irill)));
disp(strcat('Y value light=',num2str(igill)));
disp(strcat('Z value light=',num2str(ibill)));
disp(' ');
disp(strcat('R average=',num2str(averR)));
disp(' ');
Mrgb=[ 3.240479 -1.53715  -0.498535   ; -0.969256  1.875991  0.041556 ; 0.055648 -0.204043  1.057311 ];
Irgb=inv(Mrgb);
Xc=[ir;ig;ib];
sRgbl=Mrgb*Xc;
%disp(strcat('linear R value= ',num2str(sRgbl(1))));
%disp(strcat('linear G value= ',num2str(sRgbl(2))));
%disp(strcat('linear B value= ',num2str(sRgbl(3))));
disp(' ');
flag=0;
sRgb=sRgbl/100;
%disp((Mrgb))
for i=1:length(sRgb)
    if sRgb(i)<0.0031308 
        sRgb(i)=12.92*sRgb(i)*255;
        else
        sRgb(i)=(1.055*sRgb(i)^(1/2.4)-0.055)*255; 
    end
end
% display the RGB coordinates of the color
disp(strcat('R value= ',num2str(sRgb(1))));
disp(strcat('G value= ',num2str(sRgb(2))));
disp(strcat('B value= ',num2str(sRgb(3))));
disp(' ');
% check if the point is nside the RGB gamut
for i=1:length(sRgb)
    if sRgb(i)<0
        disp('POINT OUTSIDE THE RGB GAMUT !!!');
    elseif sRgb(i)>255
        disp('POINT OUTSIDE THE RGB GAMUT !!!');
    end
end
disp(strcat('ir value= ',num2str(irillnorm)));
disp(strcat('ig value= ',num2str(igillnorm)));
disp(strcat('ib value= ',num2str(ibillnorm)));
% evaluation of Lab coordinates
ax=ir/irillnorm;
ay=ig/igillnorm;
az=ib/ibillnorm;
fx=(ax)^(1/3);
fy=(ay)^(1/3);
fz=(az)^(1/3);
L=116*fy-16;
a=500*(fx-fy);
b=200*(fy-fz);
disp(strcat('L value= ',num2str(L)));
disp(strcat('a value= ',num2str(a)));
disp(strcat('b value= ',num2str(b)));
disp('    ');
% horseshoe plot and data
figure;

plot(h(:,1),h(:,2),'black');
hold
plotChromaticity();

plot(irx,igx,'w*',irxill,igxill,'r*', irxref, igxref, 'black*')
xlabel('x value');
ylabel('y value');
%title('Illuminant (RED) and object (White) colors,', 'Black - Object under Refrence Illuminant')
xlim([0 0.95]);
ylim([0 0.9]);
txt1="Illuminant: "+Illname;
text(0.2,0.85,txt1);
txt1b="Yill: "+igill;
text(0.2,0.8,txt1b);
txt2="Sample: "+Samplename;
text(0.5,0.85,txt2);
txt3="x= "+irx;
text(0.5,0.79,txt3);
txt4="y= "+igx;
text(0.5,0.73,txt4);
txt5="Y= "+ig;
text(0.5,0.67,txt5);
Raverage=ig/igill/cap;
txt6="Rav= "+Raverage;
text(0.5,0.6,txt6);
grid;
%saveas(gcf, 'CRI' +Illname +Samplename, 'epsc')

disp(' ');
disp(strcat('x value= ',num2str(irx)));
disp(strcat('y value= ',num2str(igx)));
disp(strcat('Y value= ',num2str(ig)));
%title('Localizzazione colori nel piano xy (o = colore approssimato per saturazione bianco, * blu= colore originale, * bianco = punto bianco')