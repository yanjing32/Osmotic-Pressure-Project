function arr2=conv1and1(arr,vect,correct)

%arr2=conv1and1(arr,vect,correct)
%
%CONV1AND1.m is designed to allow rapid, symmetric convolution with a
%vector, as symmetric convolution is much faster than 2D convolution when
%possible. It can be set to apply edge correction.
%
%INCLUDE:
%
%INPUTS:    ARR:        The matrix to be convoluted.
%           VECT:       The vector to convolute with, in both directions.
%           CORRECT:    Optional, defaults to no correction. If true, the
%                       image is normalized to account for zero padding at
%                       the edges.
%
%OUTPUTS:   ARR2:       The convoluted matrix.
%
%Written by Stephen Anthony 4/2008 U. Illinois Urbana-Champaign
%Last modified by Stephen Anthony on 10/02/2009

%Ensure that the kernel is in column form.
vect=vect(:);

%Convoluting with a column vector is much faster, enough to offset the cost
%of two transposes. 
if nargin==3 && correct
    %The input specified that we wished to automatically compensate for
    %edge distortions, by using the proper normalization to account for the
    %zero padding. 
    tmp=convn(arr,vect,'same')./convn(ones(size(arr)),vect,'same');
    arr2=(convn(tmp',vect,'same')./convn(ones(size(arr')),vect,'same'))';
else
    tmp=convn(arr,vect,'same');
    arr2=convn(tmp',vect,'same')';
end

