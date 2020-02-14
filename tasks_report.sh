#!/bin/bash

FOREMAN_REPORT="/tmp/$$.log"

main()
{
  > $FOREMAN_REPORT

  sos_path=$1
  base_dir=$sos_path
  final_name=$(echo $base_dir | sed -e 's#/$##g' | grep -o sos.* | awk -F"/" '{print $NF}')

  if [ ! -f $base_dir/version.txt ]; then
    echo "This is not a sosreport dir, please inform the path to the correct one."
    exit 1
  fi

  echo "The sosreport is: $base_dir"	| tee -a $FOREMAN_REPORT

  report $base_dir $sub_dir
}

log_tee()
{
  echo $1 | tee -a $FOREMAN_REPORT
}

log()
{
  echo $1 >> $FOREMAN_REPORT
}

log_cmd()
{
  echo $@ | bash &>> $FOREMAN_REPORT
}


report()
{

  base_dir=$1
  sub_dir=$2

  base_foreman="$1/sos_commands/foreman/"

  log_tee "## Satellite Task Details"
  log
  log
  log "**Task Executors"
  log_cmd "cat  $base_dir/etc/sysconfig/dynflowd | grep 'EXECUTOR_MEMORY_LIMIT\|EXECUTORS_COUNT'"
  log "---"                                                                        
  log
  log " **Total Tasks"
  log_cmd "cat $base_foreman/foreman_tasks_tasks | wc -l"
  log "---"
  log
  log " **Total Task sort by action"
  log_cmd "cat $base_foreman/foreman_tasks_tasks | sed '1,3d' | cut -d\| -f3 | grep Actions | sort | uniq -c | sort -nr"
  log "---"
  log
  log " **Paused Tasks"
  log_cmd "cat $base_foreman/foreman_tasks_tasks| egrep 'paused' | wc -l"
  log "---"
  log
  log " **Running Tasks"
  log_cmd "cat $base_foreman/foreman_tasks_tasks| egrep 'running' | wc -l"
  log "---"
  log
  log " **Paused Tasks"
  log_cmd "cat $base_foreman/foreman_tasks_tasks | egrep 'paused' |  awk -v OFS='\t' '{print  \$1, \$5, \$7, \$8, \$11, \$13}'"
  log
  echo 
  echo
  echo "## Please check out the file /tmp/report_task_${USER}_$final_name.log"
}
# Main

if [ "$1" == "" ]; then
  echo "Please inform the path to the sosrepor dir that you would like to analyze."
  echo "$0 01234567/sosreport_do_wall"
  exit 1
fi

main $1
