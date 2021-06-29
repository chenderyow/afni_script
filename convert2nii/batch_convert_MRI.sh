#!/bin/bash
# batch_convert_MRI.sh
#   ver. 1a0 update: 2021/6/24
#   Der-Yow Chen, 2021/6/24 Created.
#####################################################
convert_script_prefix=pb00_convert_MRI
convert_script=`ls ${convert_script_prefix}* | tail -n 1`

# Load Variable Definition from setting file.
if [ $# -ne 0  ]; then
    echo "setting file: $1"
    . $1     # source $1    
    echo "subject list: $2"
else
    echo "Usage: \"$0 <setting file> <subject_list> \"";
    exit
fi

#########################################
# Batch Convert
echo "##### Batch Convert DICOM to nii #####"
previous_dir=`pwd`

cat $2 | while IFS=, read -r subj_ID dicom_path; do
  input_dir=${input_root_dir}/${dicom_path}
  export subj_ID 
  export input_dir
  echo "#########################################"
  echo "subject ID: $subj_ID"
  echo "input_dir : $input_dir"
  bash $convert_script $1 
done

#########################################
# Finish
cd $previous_dir
echo "Finished..."
