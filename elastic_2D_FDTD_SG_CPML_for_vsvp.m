clc,clear
% 2D Elastic wave simulation using finite difference. for vs vp.
% with staggered-grid; with Convolutional Perfectly Matched Layer;
% By zhaoqingwei
% Chengdu University of Technology (CDUT), 2021-2025
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%txx(tzz)--Vx--txx(tzz)
% |        |    |
% Vz------txz---vz
% |        |    |
%txx(tzz)--Vx--txx(tzz)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FM=20;
DT=0.001;dt=DT;
T=4;t=T;
nx=600;
nz=600;
DH=10;dx=DH;dz=DH;

s=wavelet(FM,DT,T);
vp=[ones(nz/2,nx)*2000;ones(nz/2,nx)*4000];vs=vp/2;rou=ones(600,600)*2;
lamda=rou.*(vp.*vp-vs.*vs*2);mu=rou.*vs.*vs;
c11=rou.*vp.*vp;c13=rou.*(vp.*vp-vs.*vs*2);c33=c11;c55=rou.*vs.*vs;%����ͬ��
% Epsilon=0.25*ones(600,600);Delta=0.1*ones(600,600);
% c33=vp.*vp.*rou;c55=vs.*vs.*rou;c11=2*c33.*Epsilon+c33;c13=rou.*sqrt(((1+2*Delta).*vp.*vp-vs.*vs).*(vp.*vp-vs.*vs))-rou.*vs.*vs;%VTI

vx0=zeros(nz,nx);vx1=vx0;
vz0=vx0;vz1=vx0;
taoxx0=vx0;taoxx1=vx0;
taozz0=vx0;taozz1=vx0;
taoxz0=vx0;taoxz1=vx0;
z0=round(21);x0=round(nx/2);

EXX0=vx0;EXX1=vx0;
EXZ0=vx0;EXZ1=vx0;
EZX0=vx0;EZX1=vx0;
EZZ0=vx0;EZZ1=vx0;
HXX0=vx0;HXX1=vx0;
HXZ0=vx0;HXZ1=vx0;
HZX0=vx0;HZX1=vx0;
HZZ0=vx0;HZZ1=vx0;
[aaz,bbz,aax,bbx] = cpml(1e-10,[nz nx],20,max(vp(:)),dt,dz);

nn=3;
dxd=FDcoeffDx(nn);ddz0=dxd';ddz1=[dxd 0]';ddx0=ddz0';ddx1=ddz1';
TX=dt/dx;TZ=dt/dz;
svx=zeros(round(t/DT),nx);svz=svx;
svp=zeros(round(t/DT),nx);svs=svp;
svpx=zeros(round(t/DT),nx);svpz=svpx;
svsx=zeros(round(t/DT),nx);svsz=svsx;
% snapvx=zeros(nz,nx);snapvz=zeros(nz,nx);

kx=[0:(nx-1)]/nx*2*pi;kx(find(kx>pi))=kx(find(kx>pi))-2*pi;
kz=[0:(nz-1)]'/nz*2*pi;kz(find(kz>pi))=kz(find(kz>pi))-2*pi;
Kx=repmat(kx,nz,1);
Kz=repmat(kz,1,nx);
K=Kx.*Kx+Kz.*Kz;

for	t=DT:DT:T
    disp(t);
    k=round(t/DT);
    EXX1=bbx.*EXX0+aax.*TX.*imfilter(taoxx0,ddx0)/dt;
    EXZ1=bbz.*EXZ0+aaz.*TZ.*imfilter(taoxz0,ddz1)/dt;
    EZX1=bbx.*EZX0+aax.*TX.*imfilter(taoxz0,ddx1)/dt;
    EZZ1=bbz.*EZZ0+aaz.*TZ.*imfilter(taozz0,ddz0)/dt;
    vx1=vx0+(TZ.*imfilter(taoxz0,ddz1)+TX.*imfilter(taoxx0,ddx0)+EXZ1*dt+EXX1*dt)./rou;
    vz1=vz0+(TZ.*imfilter(taozz0,ddz0)+TX.*imfilter(taoxz0,ddx1)+EZZ1*dt+EZX1*dt)./rou;
    
    vz1(z0,x0)=vz1(z0,x0)+s(k);
    
    HXX1=bbx.*HXX0+aax.*TX.*imfilter(vx1,ddx1)/dt;
    HXZ1=bbz.*HXZ0+aaz.*TZ.*imfilter(vx1,ddz0)/dt;
    HZX1=bbx.*HZX0+aax.*TX.*imfilter(vz1,ddx0)/dt;
    HZZ1=bbz.*HZZ0+aaz.*TZ.*imfilter(vz1,ddz1)/dt;
    taoxx1=taoxx0+c13.*TZ.*imfilter(vz1,ddz1)+c11.*TX.*imfilter(vx1,ddx1)+c13.*HZZ1*dt+c11.*HXX1*dt;
    taozz1=taozz0+c33.*TZ.*imfilter(vz1,ddz1)+c13.*TX.*imfilter(vx1,ddx1)+c33.*HZZ1*dt+c13.*HXX1*dt;
    taoxz1=taoxz0+c55.*TZ.*imfilter(vx1,ddz0)+c55.*TX.*imfilter(vz1,ddx0)+c55.*HXZ1*dt+c55.*HZX1*dt;
    
    taoxx1(z0,x0)=taoxx1(z0,x0)+s(k);
    taozz1(z0,x0)=taozz1(z0,x0)+s(k);
    
    EXX0=EXX1;EXZ0=EXZ1;EZX0=EZX1;EZZ0=EZZ1;
    HXX0=HXX1;HXZ0=HXZ1;HZX0=HZX1;HZZ0=HZZ1;
    taoxx0=taoxx1;taozz0=taozz1;taoxz0=taoxz1;
    vz0=vz1;vx0=vx1;
    svx(k,:)=vx1(z0,:);svz=vz1(z0,:);
    
    
    vp=imfilter(vx1,ddx1)+imfilter(vz1,ddz1);
    vs=imfilter(vx1,ddz0)-imfilter(vz1,ddx0);
    svp(k,:)=vp(z0,:);svs=vs(z0,:);
    
    vpx=imfilter(vp,ddx0);
    vpz=imfilter(vp,ddz0);
    fvpx=-fft2(vpx)./K;fvpx(1,1)=0;
    fvpz=-fft2(vpz)./K;fvpz(1,1)=0;
    vpx1=ifft2(fvpx);
    vpz1=ifft2(fvpz);
    svpx=vpx1(z0,:);svpz=vpz1(z0,:);
    svsx=vx1(z0,:)-real(vpx1(z0,:));svsz=vz1(z0,:)-real(vpz1(z0,:));
    
    if mod(t,0.5)==0
        figure();
        imagesc(vp);
        figure();
        imagesc(vs);
    end
%     if abs(t-1)<1e-8
%         snapvx=vx1;snapvz=vz1;
%     end
end
