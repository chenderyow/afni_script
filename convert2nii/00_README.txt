README.txt for convert MRI DICOM to NII
---------------------------------------------------
1. convert only one subject:
  for ntu:
  ./pb00_convert_MRI_1a2.sh settings_ntu_s01n.txt

  for ncku:
  ./pb00_convert_MRI_1a2.sh settings_ncku_s01k.txt


2. convert more than one subject (batch convert):
  for ntu:
  ./batch_convert_MRI.sh settings_ntu.txt subjlist_ntu_7-9.txt 


  for ncku:
  ./batch_convert_MRI.sh settings_ncku.txt subjlist_ncku_7-9.txt 
