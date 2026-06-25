#!/bin/bash
logger=true

newlogger() {
  if [[ ${logfile} ]]; then
    logdirpath="$(dirname ${logfile})"
    [[ ! -d ${logdirpath} ]] && mkdir -p ${logdirpath}
    touch ${logfile}
  fi
  [[ ${1} ]] && logprefix="${1}"
}

now() {
  echo "$(date "+%Y/%m/%d %H:%M:%S.%3N")"
}

info() {
  local msg="$(now) INFO ${logprefix}${1}"
  [[ ${logfile} ]] && echo "${msg}" >>${logfile} || echo "${msg}"
}

warn() {
  local msg="$(now) WARN ${logprefix}${1}"
  [[ ${logfile} ]] && echo "${msg}" >>${logfile} || echo "${msg}"
}

err() {
  [[ ! ${2} ]] && codestr="" || codestr="code=${2}: "
  local msg="$(now) ERROR ${logprefix}line ${BASH_LINENO[0]}: ${codestr}${1}"
  [[ ${logfile} ]] && echo "${msg}" >>${logfile} || echo "${msg}"
}

errexit() {
  err "${2}" ${1}
  info "failure finished (exitcode=${1})"
  exit ${1}
}