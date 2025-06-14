%Create TPM

%function TPM=FiCreateTPM(AnnotationFile,Regions)


%%%%%If you need to run/test this use these:
clear all; close all; clc
[AnnotationFile,AnnotationFileD]=uigetfile('*.nii', 'Select Nifti'); 
AnnotationFile=fullfile(AnnotationFileD,AnnotationFile);

[Regions, Regionsd]=uigetfile('*.xlsx','Select regions');
Regions=fullfile(Regionsd,Regions);
%%%%%

Annotation=niftiread(AnnotationFile);
info=niftiinfo(AnnotationFile);

AnnotationList=table2cell(readtable(Regions));

TPM1=zeros(size(Annotation));
TPM2=zeros(size(Annotation));
TPM3=zeros(size(Annotation));
% 1 gray: region /997/8/
% 2 white: region /997/1009/
% 3 cerebral spinal fluid: region /997/73/

count=0;
for i=1:length(AnnotationList)
    if contains(AnnotationList{i,5},'/997/8/')
        voxels= Annotation==(AnnotationList{i,1});
        TPM1(voxels)=1;
        count=count+1;
    end
end

count=0;
for i=1:length(AnnotationList)
    if contains(AnnotationList{i,5},'/997/1009/')
        voxels= Annotation==(AnnotationList{i,1});
        TPM2(voxels)=1;
        count=count+1;
    end
end

count=0;
for i=1:length(AnnotationList)
    if contains(AnnotationList{i,5},'/997/73/')
        voxels= Annotation==(AnnotationList{i,1});
        TPM3(voxels)=1;
        count=count+1;
    end
end

TPM4i=TPM1+TPM2+TPM3;
TPM4=ones(size(TPM1));
TPM4=TPM4-TPM4i;
% figure()
% imshow(TPM1(:,:,(30)));
% 
% figure()
% imshow(Annotation(:,:,(30)),[0 400]);

TPM=zeros([size(TPM1) 4]);
TPM(:,:,:,1)=TPM1;
TPM(:,:,:,2)=TPM2;
TPM(:,:,:,3)=TPM3;
TPM(:,:,:,4)=TPM4;


niftiwrite(uint16(TPM),'TPMfinal');
info0=niftiinfo("TPMfinal");
infoNew=info;

%%
infoNew.Filename=info0.Filename;
infoNew.Filemoddate=info0.Filemoddate;
infoNew.Filesize=info0.Filesize;

infoNew.ImageSize=info0.ImageSize;
infoNew.PixelDimensions(4)=info0.PixelDimensions(4);
infoNew.raw.dim(1)=info0.raw.dim(1);
infoNew.raw.dim(5)=info0.raw.dim(5);
infoNew.raw.pixdim(5)=info0.raw.pixdim(5);

% TPMtest=squeeze(uint16(TPM(:,:,:,1)));
% niftiwrite(TPMtest,'Test',info);



% % % 
% % % info0.SpaceUnits=info.SpaceUnits;
% % % info0.MultiplicativeScaling=info.MultiplicativeScaling;
% % % info0.TransformName=info.TransformName;
% % % 
% % % info0.PixelDimensions(1:3)=info.PixelDimensions(1:3);
% % % info0.Transform=info.Transform;
% % % 
% % % info0.raw.pixdim(1:4)=info.raw.pixdim(1:4);
% % % info0.raw.scl_slope=info.raw.scl_slope;
% % % info0.raw.xyzt_units=info.raw.xyzt_units;
% % % info0.raw.qform_code=info.raw.qform_code;
% % % info0.raw.quatern_d=info.raw.quatern_d;
% % % % % % info0.raw.qoffset_x=info.raw.qoffset_x;
% % % info0.raw.qoffset_y=info.raw.qoffset_y;
% % % info0.raw.qoffset_z=info.raw.qoffset_z;
% % % 
% % % info0.raw.srow_x=info.raw.srow_x;
% % % info0.raw.srow_y=info.raw.srow_y;
% % % info0.raw.srow_z=info.raw.srow_z;

niftiwrite(uint16(TPM),'TPMfinal',infoNew);




