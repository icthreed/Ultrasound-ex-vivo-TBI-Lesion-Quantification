%Adding lesion mask to Ultrasound scan and treating as gray matter

clear all;
close all;
clc

%load files
UltFile= uigetfile('*.nii', 'Select Ultrasound');
Ult=niftiread(UltFile);
%UltClass=class(Ult);

LesionFile= uigetfile('*.nii', 'Select Lesion');
Lesion=double(niftiread(LesionFile));
UltInfo=niftiinfo(UltFile);
LesionInfo=niftiinfo(LesionFile);

%find max of ultrasound scan
Um=max(Ult,[],"all");

%convert lesion matrix to have same intensity/value of grey matter
%filter
Lesion(Lesion<.1*max(Lesion,[],'all'))=0;
%convert to 1s
Lesion(Lesion>0)=1;
%convert 1s to grey matter intensity
Lesion=(Lesion.*(Um*3/4));
%double check value
Lm=max(Lesion,[],"all");


%replace missing volume in Ult with lesion segmentation.
UltLesion=Ult;
nonZeroIndices = (Lesion ~= 0);
UltLesion(nonZeroIndices) = Lesion(nonZeroIndices);

NewName=sprintf('%s','Lesion_AND_Ultrasound',UltFile);
niftiwrite(UltLesion,NewName,UltInfo);






