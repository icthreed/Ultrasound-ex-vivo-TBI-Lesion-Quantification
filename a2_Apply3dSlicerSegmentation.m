clear all; close all; clc
%Applying 3d slicer segmentation

%Select segmentation
[segmentFile, segmentFileD]= uigetfile('*.nii; *.nrrd', 'Select segmentation');
segmentFile=fullfile(segmentFileD,segmentFile);
%seleft as many files as you want to segment
[UltrasoundFileO, UltrasoundFileD]=uigetfile('*.nii', 'Select 3D Volume','MultiSelect', 'on');


%----------------------------------------------------------------------------------------------



if ~iscell(UltrasoundFileO)
    UltrasoundFileO={UltrasoundFileO};
end
for iii=1:length(UltrasoundFileO)
        UltrasoundFile=fullfile(UltrasoundFileD,UltrasoundFileO{iii});
        Ultrasound=niftiread(UltrasoundFile);
        UltrasoundInfo=niftiinfo(UltrasoundFile);
        %Prepping the segment, check if .nii or .nrrd and act accordingly
        %combine the 4th dimension as that is not relevant in this version.
        if contains(segmentFile, '.nii')
            segment=niftiread(segmentFile);
            if length(size(segment))==4
                segment=squeeze(segment(:,:,:,1));
            end
        elseif contains(segmentFile, '.nrrd')
            segment=nrrdread(segmentFile);
        
            if length(size(segment))==4
                segment=double(squeeze(segment(:,:,:,1)));
            elseif max(segment,[],'all')>1
                segment(segment~=1)=0;
                segment=double(segment);
            end
            %often the nrrdread makes y dimemsion shorter, this code padded it so it 
            %is now the proper size
            Us=size(Ultrasound);
            SegSize=size(segment);
            Diff=Us(2)-SegSize(2);
            SegPH=zeros(Us(1:3));
  
            if Diff~=0
                SegRange=((Diff-3):(Us(2)-4));
            else
                SegRange=1:Us(2);
            end
            SegPH(:,SegRange,:)=segment;
            segment=SegPH;
        end
        
        %Prep the segment and make sure it is binary. 
        segment=double(segment);
        segment(segment<.1)=0;
        segment(segment>0)=1;
        segmentsize=size(segment);
        Ultrasoundsize=size(Ultrasound);

        %Check the size again and fix if necessary. 
        if segmentsize(1)>Ultrasoundsize(1)
            segment=segment(1:(end-1),:,:);
            % zeros_sheet = zeros(1, Ultrasoundsize(2), Ultrasoundsize(3), Ultrasoundsize(4));
            % Ultrasound = cat(1, Ultrasound, zeros_sheet);
        end
        if segmentsize(2)>Ultrasoundsize(2)
            segment=segment(:,1:(end-1),:);
            % zeros_sheet = zeros(Ultrasoundsize(1),1, Ultrasoundsize(3), Ultrasoundsize(4));
            % Ultrasound = cat(2, Ultrasound, zeros_sheet);
        end
        if segmentsize(3)>Ultrasoundsize(3)
            segment=segment(:,:,1:(end-1));
            % zeros_sheet = zeros(Ultrasoundsize(1), Ultrasoundsize(2),1,Ultrasoundsize(4));
            % Ultrasound = cat(3, Ultrasound, zeros_sheet);
        end

        %If the ultrasound is 4d, this makes the segment 4d.
        segment4d=zeros(size(Ultrasound));
        if length(size(segment4d))==4
            for j=1:length(segment4d(1,1,1,:))
                segment4d(:,:,:,j)=segment;
            end
        else
            segment4d=segment;
        end
        
        %This may be redundant...
        segment4d(segment4d<.1)=0;
        segment4d(segment4d>0)=1;
        
        %Set everywhere within the scan that is
        %Changing the intensity to be consistent and semi normalized
        Ultrasound(segment4d<=0)=0;
        if iii==1
            Ultrasound(segment4d>0)=Ultrasound(segment4d>0)+.1;
            Ultrasound=Ultrasound./max(Ultrasound,[],"all");
        end
        

        if contains(segmentFile, '.nii')
            segment=niftiread(segmentFile);
            if length(size(segment))==4
                Lesion=squeeze(segment(:,:,:,2));
            end

        elseif contains(segmentFile, '.nrrd')
            segment=nrrdread(segmentFile);

        
            if length(size(segment))==4
                Lesion=double(squeeze(segment(:,:,:,2)));
            elseif max(segment,[],'all')>1
                segment(segment~=2)=0;
                segment(segment==2)=1;
                Lesion=double(segment);
            end
            %often the nrrdread makes y dimemsion shorter.... 
            Us=size(Ultrasound);
            SegSize=size(Lesion);
            Diff=Us(2)-SegSize(2);
            SegPH=zeros(Us(1:3));
            %For some reason, it is not symetrical padding, this is what
            %worked
            if Diff~=0
                SegRange=((Diff-3):(Us(2)-4));
            else
                SegRange=1:Us(2);
            end
            SegPH(:,SegRange,:)=Lesion;
            Lesion=SegPH;
        end
        
        UltrasoundInfo=niftiinfo(UltrasoundFile);
        
        %find max of ultrasound scan
        Um=max(Ultrasound,[],"all");
        
        %If there was extra data in the segmentation describing the Lesion
        %Make a new model with that lesion filled in!
        if exist('Lesion','var')
        %convert lesion matrix to have same intensity/value of grey matter
        %filter
        Lesion(Lesion<.1*max(Lesion,[],'all'))=0;
        %convert to 1s
        Lesion(Lesion>0)=1;
        %convert 1s to grey matter intensity
        Lesion=(Lesion.*(Um*3/4));
        %double check value
        Lm=max(Lesion,[],"all");
        
        %replace missing volume in Ultrasound with lesion.
        UltrasoundLesion=Ultrasound;
        nonZeroIndices = (Lesion ~= 0);
        UltrasoundLesion(nonZeroIndices) = Lesion(nonZeroIndices);
        NewName=erase(UltrasoundFile,'.nii');
        NewName=sprintf('%s',NewName,'LesionANDScan');
        niftiwrite(UltrasoundLesion,NewName,UltrasoundInfo);
        end

        UltrasoundFile=erase(UltrasoundFile,'.nii');
        NewName=sprintf('%s',UltrasoundFile,'Segmented');
        
        niftiwrite(Ultrasound,NewName,UltrasoundInfo);
        if contains(segmentFile, '.nrrd')
            segmentFile=erase(segmentFile,'.seg.nrrd');
            NewName=sprintf('%s',segmentFile,'Lesion');
            niftiwrite(Lesion,NewName,UltrasoundInfo);
        end
end
