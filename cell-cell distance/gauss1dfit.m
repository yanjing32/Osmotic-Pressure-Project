function [xc,Amp,width]=gauss1dfit(z,x,wght)

%[xc,Amp,width]=gauss1dfit(z,x,wght)
%
%GAUSS1DFIT.m applies an extremely rapid, weighted one dimensional least
%squares gaussian fit. There are more accurate ways, but this matrix method
%is extremely fast
%
%INCLUDE:   
%
%INPUTS:    X:          The position of each data point to be fit
%           Z:          The value of each data point to be fit
%           WGHT:       The weight of each data point to be fit
%
%OUTPUTS:   XC:         The position of the center of the Gaussian
%           Width:      The width of the Gaussian. 
%           Amp:        The amplitude of the gaussian. 
%
%Written by Stephen Anthony 1/2007 U. Illinois Urbana-Champaign
%Last Modified by Stephen Anthony on 10/09/2009

x=x(:);
z=z(:)+1e-15;

if nargin==2
    wght=ones(size(x));
end
wght=wght(:);


n=[x log(z) ones(size(x))].*(wght*ones(1,3));
d=-(x.^2).*wght;
a=n\d;
%In the least squares sense, a was selected such that 
%   n*a = d
%or the best possible match thereof. 

%Extract the desired values
xc = -.5*a(1);
width=sqrt(a(2)/2);
Amp=exp((a(3)-xc^2)/(-2*width^2));