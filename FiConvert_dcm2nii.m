function Xnew=FiConvert_dcm2nii(U)
%Example, U is a dicom file
% [U,Ud]=uigetfile('*.dcm', 'Select dicom');
% U=fullfile(Ud,U);

X = dicomread(U);

%USU Collaboration
%Xnew=X(:,:,1,:)+X(:,:,2,:)+X(:,:,3,:);

Xnew=X(:,:,1,:);
Xnew=im2double(squeeze(Xnew));

%USU Collaboration     
% Xnew=imrotate3(Xnew,90,[0 1 0]) ;
% Xnew=imrotate3(Xnew,90,[1 0 0]) ;
% Xnew=imrotate3(Xnew,180,[0 0 1]) ;

%Rotate and flip image to correct orientation
Xnew=imrotate3(Xnew,90,[0 0 1]) ;
Xnew = flip(Xnew,1);

newStr = erase(U,".dcm");
niftiwrite(Xnew,newStr);
Info=niftiinfo(newStr);

Info.MultiplicativeScaling=1;
Info.SpatialDimension=0;
Info.TransformName='Qform';
% Info.Transform.T(1,1)=-Info.Transform.T(1,1);
% Info.Transform.T(2,2)=-Info.Transform.T(2,2);
Info.raw.scl_slope=1;
Info.raw.xyzt_units=2;
Info.raw.qform_code=1;
Info.raw.quatern_d=1;
%Temporary changes for USU colaboration!
% xDim=.0189367;
% yDim=.089;
% zDim=.0203784;

%Temporary for old NP data
xDim=0.019592;
yDim=0.019531;
zDim=.1;

Info.PixelDimensions(1)=xDim;
Info.PixelDimensions(2)=yDim;
Info.PixelDimensions(3)=zDim;
Info.Transform.T(1,1)=-Info.Transform.T(1,1)*xDim;
Info.Transform.T(2,2)=-Info.Transform.T(2,2)*yDim;
Info.Transform.T(3,3)=Info.Transform.T(3,3)*zDim;
% Info.Transform.T(4,1)=23;
Info.Transform.T(4,2)=.4;
% Info.Transform.T(4,3)=-2;
Info.raw.pixdim(2)=xDim;
Info.raw.pixdim(3)=yDim;
Info.raw.pixdim(4)=zDim;



niftiwrite(Xnew,newStr,Info);

