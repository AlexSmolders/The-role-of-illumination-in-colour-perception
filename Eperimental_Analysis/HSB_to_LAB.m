% This file does require the redxyz.dat, greenxyz.dat and bluexyz.dat files
% It also needs a new d65_norm.dat file that I sent as well


% Enter your HSB code into the square brackets below, seperated by a ;
HSB=[60;80;100];
Hnorm = HSB(1);
Snorm = HSB(2)/100;
Bnorm = HSB(3)/100;

C = Snorm * Bnorm;
X = C * (1- abs(mod((Hnorm/60),2)-1));
m = Bnorm - C;

for i=1: length(Hnorm)
    if (0 <= Hnorm(i)) && (Hnorm(i) < 60)
        rgb=[C;X;0];
        elseif (60 <= Hnorm(i)) && (Hnorm(i) < 120)
            rgb=[X;C;0];
        elseif (120 <= Hnorm(i)) && (Hnorm(i) < 180)
            rgb=[0;C;X];
        elseif (180 <= Hnorm(i)) && (Hnorm(i) < 240)
            rgb=[0;X;C];
        elseif (240 <= Hnorm(i)) && (Hnorm(i) < 300)
            rgb=[X;0;C];
        else
            rgb=[C;0;X];
    end
end

RGB= [(rgb(1)+m)*255; (rgb(2)+m)*255; (rgb(3)+m)*255];

disp(strcat('R = ',num2str(RGB(1))));
disp(strcat('G = ',num2str(RGB(2))));
disp(strcat('B = ',num2str(RGB(3))));
disp(' ');



rgb=RGB/255;

r=load('redxyz.dat');
g=load('greenxyz.dat');
b=load('bluxyz.dat');
Illfile="d65_norm.dat";
Ill=load(Illfile);
% interpolating data
lambda=390:0.01:700;
ri=interp1(r(:,1),r(:,2),lambda,'spline');
gi=interp1(g(:,1),g(:,2),lambda,'spline');
bi=interp1(b(:,1),b(:,2),lambda,'spline');
Illi=interp1(Ill(:,1),Ill(:,2),lambda,'spline');
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




for i=1:length(rgb)
    if rgb(i)<=0.04045 
        rgb(i)= rgb(i)/12.92;
        else
        rgb(i)= ((rgb(i)+0.055)/1.055)^(2.4); 
    end
end
Mrgb=[ 3.240479 -1.53715  -0.498535   ; -0.969256  1.875991  0.041556 ; 0.055648 -0.204043  1.057311 ];
Irgb=inv(Mrgb);

xyz=Irgb*rgb*100;

disp(strcat('X value= ',num2str(xyz(1))));
disp(strcat('Y value= ',num2str(xyz(2))));
disp(strcat('Z value= ',num2str(xyz(3))));
disp(' ');

% RGB to XYZ
X=xyz(1);
Y=xyz(2);
Z=xyz(3);
xnorm=irillnorm;
ynorm=igillnorm;
znorm=ibillnorm;
% evaluation of Lab coordinates
ax=X/xnorm;
ay=Y/ynorm;
az=Z/znorm;
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
