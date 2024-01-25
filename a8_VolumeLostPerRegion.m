clear all; close all; clc
% applying mapped TBI lesion segmentation to annotation matrix and
% quantifying volume lost per region....

SegmentFile= uigetfile('*.nii', 'Select Segmentation');
TBI=double(niftiread(SegmentFile));
%if using files from Github, use this to skip manual selection
Annotation=double(niftiread('Reset_P56_Annotation_downsample2.nii'));
AnnotationLabels=table2cell(readtable('downsample_ScalableBrainAtlasStructures.xlsx'));
AnnotationInfo=niftiinfo('Reset_P56_Annotation_downsample2.nii');

% %select the Annotation nifti matrix
% AnnotationFile= uigetfile('*.nii', 'Select Annotation');
% Annotation=double(niftiread(AnnotationFile));
% AnnotationInfo=niftiinfo(AnnotationFile);
% 
% %Select the Annotation Spreadsheet
% AnnotationLabelsFile= uigetfile('*.xlsx', 'Select Annotation Spreadsheet');
% AnnotationLabels=table2cell(readtable(AnnotationLabelsFile));

%%
%
xDimension=input('xDimension'); %0.05;
yDimension=input('yDimension'); %0.05;
zDimension=input('zDimension'); %0.05;

%multiply TBI to annotation
LesionRegionMatrix=Annotation(TBI~=0);
%Nifti file showing annotations of TBI
Annotation2=Annotation;
Annotation2(~TBI)=0;
niftiwrite(uint16(Annotation2),'testy',AnnotationInfo);

%identify unique values in multiplied matrix
LesionRegionList=unique(LesionRegionMatrix);

%Go through unique values and find number of pixels in mul matrix with each
%value
%this gives us volume lost per region....
PixelsPerRegion=cell(length(LesionRegionList),4);
PixelsPerRegion(:,1)=num2cell(LesionRegionList);

for i=1:length(LesionRegionList)
    if LesionRegionList(i)~=0
        Pixels = find(LesionRegionMatrix == LesionRegionList(i));
        numPixels=length(Pixels);
        Volume=numPixels*xDimension*yDimension*zDimension;
        PixelsPerRegion(i,2)=num2cell(Volume);
        logicalIndices = cellfun(@(x) isequal(x, LesionRegionList(i)), AnnotationLabels(:,1));
        [rowIndices, colIndices] = find(logicalIndices == 1);
        PixelsPerRegion(i,3)=AnnotationLabels(rowIndices, 2);
        PixelsPerRegion(i,4)=AnnotationLabels(rowIndices, 3);

    end
end

PixelsPerRegion(1,1)={'Annotation ID#'};
PixelsPerRegion(1,2)={'Volume Lost (mm^3)'};
PixelsPerRegion(1,3)={'Region Acronym'};
PixelsPerRegion(1,4)={'Region Name'};

%Saves table of values as spreadsheet.
NewName=sprintf('%s','RegionLoss_',SegmentFile);
NewName=erase(NewName,'.nii');
writecell(PixelsPerRegion,NewName,'FileType','spreadsheet')
