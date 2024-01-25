clear all; close all; clc
%Applying 3d slicer Segmentation

%Select Segmentation
SegmentFile= uigetfile('*.nii', 'Select Segmentation');
%seleft as many files as you want to segment
UltrasoundFile=uigetfile('*.nii', 'Select 3D Volume(s)','MultiSelect','on');
 [~, ~, fExt] = fileparts(UltrasoundFile);
 
%Multiplying that segment to the Ultrasound elementwise
if iscell(UltrasoundFile)
    for i=1:length(UltrasoundFile)
        %create matrices
        Ultrasound=niftiread(char(UltrasoundFile(i)));
        segment=niftiread(SegmentFile);
        segment=double(segment);
        segment4d=zeros(size(Ultrasound));
        %If the ultrasound is 4d, this makes the segment 4d.
        if length(size(segment4d))==4
            for j=1:length(segment4d(1,1,1,:))
                segment4d(:,:,:,j)=segment;
            end
        else
            segment4d=segment;
        end
        %Multiplying that segment element wise to the Ultrasound
        Ultrasound=Ultrasound.*segment4d;
        %Creating the new segmented nifti file
        ufile2=erase(char(UltrasoundFile(i)),'.nii');
        Newfilename = sprintf('%s',ufile2,'_Segmented');
        niftiwrite(Ultrasound,Newfilename,niftiinfo(char(UltrasoundFile(i))));
    end
elseif ischar(UltrasoundFile)
        Ultrasound=niftiread(UltrasoundFile);
        segment=niftiread(SegmentFile);
        segment=double(segment);
        segment4d=zeros(size(Ultrasound));
        %If the ultrasound is 4d, this makes the segment 4d.
        if length(size(segment4d))==4
            for j=1:length(segment4d(1,1,1,:))
                segment4d(:,:,:,j)=segment;
            end
        else
            segment4d=segment;
        end
        %Multiplying that segment element wise to the Ultrasound
        Ultrasound=Ultrasound.*segment4d;
        %Creating the new segmented nifti file
        ufile2=erase(UltrasoundFile,'.nii');
        Newfilename = sprintf('%s',ufile2,'_Segmented');
        niftiwrite(Ultrasound,Newfilename,niftiinfo(UltrasoundFile));
else
    disp('Invalid Ultrasound Input')
end