#!/bin/bash

# Usage: current_sem_ver version_folder version_fileName
function current_sem_ver() {
   cat $1/$2
}
# Usage: git_ref source_folder branchName
function git_ref() {
  cat $1/.git/refs/heads/$2
}

# Usage: build_version version_folder version_file source_folder branch_Name
function build_version() {
  echo $(current_sem_ver $1 $2)+$(git_ref $3 $4)
}
