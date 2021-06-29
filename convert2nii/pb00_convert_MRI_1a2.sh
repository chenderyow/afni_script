#!/bin/bash
# pb00_convert_MRI.sh
#   ver. 1a2 update: 2020/12/18
#   Der-Yow Chen, 2020/08/08 Created.
#####################################################
# Load Variable Definition from setting file.
if [ $# -ne 0  ]; then
    echo "setting file: $1"
    . $1     # source $1    
else
    echo "Usage: \"./$0 <setting file>\"";
    exit
fi

#########################################
# make output dir
[ -d ${output_dir}/temp  ] || mkdir -p ${output_dir}/temp 

# convert images 
echo "#####Converting images using dcm2niix######"
dcm2niix_afni -b y -i y -z $compress \
	-f $file_format -o ${output_dir}/temp  \
	$input_dir 

# Convert to BIDS format
echo "#####Converting to BIDS format#####"
previous_dir=`pwd`
cd $output_dir/temp

# Decide Subject Name, then rename folder.
ls *.nii* > $info_file
if [ -z ${subj_ID+x} ]; then
    subject_name=`ls *.nii* | head -n 1 | cut -d_ -f1 | cut -d- -f2`
else
    subject_name=$subj_ID
fi
cd $output_dir
subj_dir=sub-${subject_name}
mv temp $subj_dir
cd $output_dir/$subj_dir
sleep 1 # need to sleep 1s, otherwise mv file may have error

if [ $compress = "y" ]; then extension="nii.gz"; else extension="nii"; fi

# remove/skip unused files, may related to localize or calibrate
for skip in $skip_keywords; do
  skip_files=`ls *.json | grep $skip`
  for fname in $skip_files; do
    base=${fname%.*}
    rm ${base}.${extension} 
    rm ${base}.json
  done
done

# anatomy image name
echo "-----anatomical images..."
anat_files=`ls *.json | grep $anat_keyword`
anat_file_no=`ls *.json | grep $anat_keyword| wc -l`
[ -d anat ] || mkdir anat

for fname in $anat_files; do
  base=${fname%.*}
  if [ $anat_file_no -eq 1 ]; then
    new_fname="anat/sub-${subject_name}_${anat_bids_string}"
  else
    # retrieve old run_id, then convert to sn (serial no)
    run_id=$base
    while [ "$(echo $run_id | cut -c 1-3)" != "run" ]; do
      run_id=`echo $run_id| cut -d_ -f2-`
    done
    run_id=`echo $run_id| cut -d_ -f1`
    sn="sn-$(echo $run_id | cut -d- -f2)"
    new_fname="anat/sub-${subject_name}_${anat_bids_string}_${sn}"
  fi
  mv -v "${base}.${extension}" "${new_fname}.${extension}"
  mv -v "${base}.json" "${new_fname}.json"
  #mv ${new_fname}.* anat  
done

# Functional images
echo "-----functional images...."
[ -d func ] || mkdir func
if [ -z ${task_ID+x} ]; then task_name_flag=0; else task_name_flag=1;  fi
for func_kw in $func_keyword; do
  func_files=`ls *.json | grep $func_kw`
  # echo $func_files
  i=1
  for fname in $func_files; do
    base=${fname%.*}
    
    # decide task_name
    if [ "$task_name_flag" = 1 ]; then 
    	task_name=$task_ID
    else 
    	task_name=$func_kw
    fi

    # retrieve old run_id, then convert to sn (serial no)
    run_id=$base
    while [ "$(echo $run_id | cut -c 1-3)" != "run" ]; do
      run_id=`echo $run_id| cut -d_ -f2-`
    done
    run_id=`echo $run_id| cut -d_ -f1`
    sn="sn-$(echo $run_id | cut -d- -f2)"

    # move files
    if [ "$include_sn" = y ]; then
        new_fname="func/sub-${subject_name}_task-${task_name}_run-${i}_${func_bids_string}_${sn}"
    else
        new_fname="func/sub-${subject_name}_task-${task_name}_run-${i}_${func_bids_string}"
    fi
    mv -v "${base}.${extension}" "${new_fname}.${extension}"
    mv -v "${base}.json" "${new_fname}.json"
    i=$((i+1))
  done
done

# Finish
cd $previous_dir
echo "Finished..."
