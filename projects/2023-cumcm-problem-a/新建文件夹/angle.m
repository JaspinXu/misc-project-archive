clc;clear;
ST=repmat([9,10.5,12,13.5,15],12,1);
D=repmat([306,337,0,31,61,92,122,153,184,214,245,275]',1,5);
chiwei=asin(sin(2.*pi.*D./365).*sin(2.*pi.*23.45./360));
weidu=39.4*pi/180;
shi=(pi/12).*(ST-12);
gaodu=asin(cos(chiwei).*cos(weidu).*cos(shi)+sin(chiwei).*sin(weidu));
fangweicos=(sin(chiwei)-sin(gaodu).*sin(weidu))./(cos(gaodu).*cos(weidu));
fangweisin=-sin(shi).*cos(chiwei)./cos(gaodu);
fangwei=real(acos(fangweicos));
fangwei(:,3)=pi;
fangwei(:,4)=2*pi-fangwei(:,4);
fangwei(:,5)=2*pi-fangwei(:,5);
fangwei=2.5.*pi-fangwei;
vector_light=cell(12,5);
for i=1:1:60
   vector_light{i}=-[cos(gaodu(i))*cos(fangwei(i)),cos(gaodu(i))*sin(fangwei(i)),sin(gaodu(i))]; 
end





