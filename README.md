Ultrasound ex vivo Traumatic Brain Injury Lesion Quantification – MATLAB Pipeline
This project outlines a MATLAB-based workflow for segmenting, mapping, and quantifying traumatic brain injury (TBI) lesions using imaging data. The steps below walk through DICOM conversion, segmentation, registration to an atlas, and volume quantification per brain region.

⚠️ Note: The SPM12 settings and parameters listed here reflect what worked for my specific imaging data. You may need to adjust voxel size, bounding box, and coregistration parameters to fit your dataset.

Workflow Overview
1. Download and Prepare Files
  Acquire raw DICOM scan
2. Convert DICOM to NIfTI
  Run: FiConvert_dcm2nii(file)
3. Ensure Alignment with Atlases
  Confirm that all atlases and segmentation volumes are in the same orientation and have a similar number of voxels. Adjust as necessary.
4. Create a Tissue Probability Map (TPM)
  If you don't already have a TPM:
  Run: FiCreateTPM(file, Regions)
5. Generate Segmentations in 3D Slicer
  Use 3D Slicer to manually or semi-automatically create brain and TBI lesion segmentations from your NIfTI scan.
  Save these as .nrrd.seg files.
6. Apply Segmentations
  Use: a2_Apply3dSlicerSegmentation
  (Requires nrrdread function)
7. Map to Atlas Using SPM12
  Coregistration (Estimate & Reslice)
    Reference Image: Atlas
    Source Image: LesionANDScan
    Other Images: Lesion segmentation
    Separation: 0.1
    Run batch in SPM12.
  Normalization (Estimate & Write)
    Subject to Align: Resliced LesionANDScan
    Subject to Write: Resliced LesionANDScan and Lesion Segmentation
    Tissue Probability Map: Your_TPM
    Separation: 0.1
    Voxel Size: 0.05 x 0.05 x 0.05
    Bounding Box:
    -27.95  -18.95   0  
    -16.6   -11.00  13.15
8. Quantify Lesion Volume Per Region
  Run: FiVolumeLostPerRegion
9. Export and Process Output
  Analyze resulting Excel files as needed.
