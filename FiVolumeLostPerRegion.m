function PixelsPerRegion=FiVolumeLostPerRegion(SegmentFile,AnnotationFile,AnnotationLabelsFile, Dimensions)
% applying mapped TBI lesion segmentation to annotation matrix and
% quantifying volume lost per region....


% clear all; close all; clc;
% [segmentFile, segmentFileD]= uigetfile('*.nii', 'Select segmentation');
% SegmentFile=fullfile(segmentFileD,segmentFile);
% [AnnotationFile, AnnotationFileD]= uigetfile('*.nii', 'Select Annotation');
% AnnotationFile=fullfile(AnnotationFileD,AnnotationFile);
% [AnnotationLabelsFile, AnnotationLabelsFileD]=uigetfile('*.xlsx', 'Select Labels');
% AnnotationLabelsFile=fullfile(AnnotationLabelsFileD, AnnotationLabelsFile);
% Dimensions=zeros(1,3);
% Dimensions(1)=0.05;
% Dimensions(2)=0.05;
% Dimensions(3)=0.05;

%Prepping and Formatting data
xDimension=Dimensions(1); 
yDimension=Dimensions(2); 
zDimension=Dimensions(3); 

Annotation=double(niftiread(AnnotationFile));
AnnotationLabels=table2cell(readtable(AnnotationLabelsFile));
TBI=double(niftiread(SegmentFile));
AnnotationInfo=niftiinfo(AnnotationFile);

%Prep the TBI Segment
TBI(TBI<.01)=0;
TBI(isnan(TBI))=0;
TBI(TBI>0)=1;
%Extra Prep because my latest files were too big!!! 
TBI=TBI(1:228,1:160,:);


%multiply TBI to annotation
LesionRegionMatrix=Annotation(TBI~=0);
%Nifti file showing annotations of TBI
Annotation2=Annotation;
Annotation2(~TBI)=0;
%If you want to visualize the Overlay of the Lesion on the annotation
%uncomment this:
%niftiwrite(uint16(Annotation2),'Overlay',AnnotationInfo);

%identify unique values in multiplied matrix
LesionRegionList=unique(LesionRegionMatrix);

%%Initialize the cell array to save all data ORIGINAL
% PixelsPerRegion=cell(length(LesionRegionList),6);
% PixelsPerRegion(:,1)=num2cell(LesionRegionList);

%NEW
PixelsPerRegion=cell(height(AnnotationLabels),5);
PixelsPerRegion(:,2:3)=(AnnotationLabels(:,2:3));
PixelsPerRegion(:,1)=AnnotationLabels(:,1);

% For loop to go through all regions that showed lost volume
for i=1:length(LesionRegionList)
    if LesionRegionList(i)~=0
        %find where in excel sheet we should paste data
        excel_spot=find(cell2mat(PixelsPerRegion(:,1)) == LesionRegionList(i));
        %find number of pixels for selected region
        Pixels = find(LesionRegionMatrix == LesionRegionList(i));
        numPixels=length(Pixels);
        %find volume by multiplying dimensions and pixels
        Volume=numPixels*xDimension*yDimension*zDimension;
        PixelsPerRegion(excel_spot,4)=num2cell(Volume);
        % %Find acronyms and names corresponding to selected region Might
        % not be needed anymore......
        % logicalIndices = cellfun(@(x) isequal(x, LesionRegionList(i)), AnnotationLabels(:,1));
        % [rowIndices, colIndices] = find(logicalIndices == 1);
        % PixelsPerRegion(excel_spot,3)=AnnotationLabels(rowIndices, 2);
        % PixelsPerRegion(excel_spot,4)=AnnotationLabels(rowIndices, 3);

        %Total volume of the effected region? (disregarding volume lost)
        PixelsPerRegion(excel_spot,5)={length(find(Annotation==LesionRegionList(i)))*.05*.05*.05};
    end
end

%Fix file Name
NewName=erase(SegmentFile,'.nii');
NewName=sprintf('%s',NewName,'_RegionLoss');

%Name Columns
PixelsPerRegion(1,1)={'Annotation ID#'};
PixelsPerRegion(1,2)={'Region Acronym'};
PixelsPerRegion(1,3)={'Region Name'};

PixelsPerRegion(1,4)={'Volume Lost (mm^3)'};
PixelsPerRegion(1,5)={'Region Total Volume'};
% PixelsPerRegion(1,6)={'Percent Volume Lost'};
% %Calculate % lost
% PixelsPerRegion(2:end,6)=num2cell([PixelsPerRegion{2:end,4}]./[PixelsPerRegion{2:end,5}]);
ppr_size=size(PixelsPerRegion);
ppr_size(1)=ppr_size(1)+1;

PixelsPerRegion2=cell(ppr_size);
PixelsPerRegion2(1,4)={NewName};
PixelsPerRegion2(2:end,:)=PixelsPerRegion;
PixelsPerRegion=PixelsPerRegion2;

%Saves table of values as spreadsheet.
writecell(PixelsPerRegion,NewName,'FileType','spreadsheet')
