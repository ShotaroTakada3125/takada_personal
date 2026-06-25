#!/bin/bash

currdir=$(pwd)
exdir=$(cd $(dirname ${0}); pwd)
cd ${exdir}
usage() {
  cat <<EOF
${0##*/} is dmm data import sql generate script

Usage:
    ./${0##*/} [Options]

Options:
    --help | -h                      : show this.
    -i | --infile <Input File Path>  : path of input file
    -o | --outdir <Output Dir Path>  : path of output directory
    -l | --log-out <Log-Path>        : outputs log files to the specified path
                                       if not specified, default is stdout only.
    -ud | --utils-dir <Dir-Path>     : directory path where utility script files are stored
                                       if not specified, default is current directory.
    --tmp-table                      : for temp table

EOF
}

store_args() {
  if [[ $# -ne 0 ]]; then
    case "${1}" in
      "--help" | "-h" )
        usage
        exit 1
        ;;
      "--infile" | "-i" )
        infile="${2}"
        shift 1 && shift 1
        ;;
      "--outdir" | "-o" )
        outdir="${2}"
        shift 1 && shift 1
        ;;
      "-l" | "--log-out" )
        logfile=${2}
        shift 2
        ;;
      "-ud" | "--utils-dir" )
        utildir="${2}"
        shift 1 && shift 1
        ;;
      "--tmp-table" )
        tmptbl=true
        shift 1
        ;;
      *)
        echo "Did you mistake to specified argument?: ${1}"
        read -p "Press [Enter] to continue, if no mistake or ignore."
        shift 1
    esac
    store_args "${@}"
    return
  fi
}
store_args "${@}"

normalize_tsv() {
  printf "${1} normalizing... "
  sed "1d" ${1} >${2} || return 1              #1行目はヘッダなので削除
  sed -i.tmp0 -e "s/\r$//g" ${2} || return 1   #改行コードがCRLFだった場合はLFに変換
  sed -i.tmp1 -e "/^\s*$/d" ${2} || return 1   #空行を削除
  sed -i.tmp2 -e "s/\"//g" ${2} || return 1    #ダブルクォートを削除
  sed -i.tmp3 -e "s/'/’/g" ${2} || return 1    #シングルクォートは全角に変換
  sed -i.tmp4 -e "s/,/、/g" ${2} || return 1   #カンマは全角に変換
  sed -i.tmp5 -e "s/&/＆/g" ${2} || return 1   #アンパサンドは全角に変換
  sed -i.tmp6 -e "s/　/ /g" ${2} || return 1   #全角スペースは半角スペースに変換
  sed -i.tmp7 -e "s/  / /g" ${2} || return 1   #半角スペース2つ連続は1つに変換
  rm ${2}.tmp*
  echo "done!"
}

# カラム名を明記することで、列順序の問題を完全に解決する最終版
gen_sql() {
  printf "${1} SQL generating... "
  local tmpsql="${1}.tmp"
  local finalsql="${1}"

  if [[ ! -f "${tmpsql}" ]]; then
    echo "error! Input file not found: ${tmpsql}"
    return 1
  fi

  echo '\set ON_ERROR_STOP on' > "${finalsql}"
  echo "BEGIN;" >> "${finalsql}"
  echo "SELECT NOW();" >> "${finalsql}"

  if [[ ${tmptbl} ]]; then
    # DMM_TMP_ACCOUNT テーブル用の処理
    awk -F'\t' '
      function quote(s) { gsub(/\047/, "\047\047", s); return "\047" s "\047"; }
      {
        printf "INSERT INTO DMM_TMP_ACCOUNT (dmm_id,family_name,given_name,family_name_phonetic,given_name_phonetic,birthday) VALUES (%s,%s,%s,%s,%s,%s);\n",
          quote($1), quote($2), quote($3), quote($4), quote($5), ($6 == "") ? "NULL" : quote($6) "::date";
      }
    ' "${tmpsql}" >> "${finalsql}" || return 1
  else
    # DMM_INDIVIDUAL_ACCOUNT テーブル用の処理 (★INSERT文にカラム名を追加★)
    awk -F'\t' '
      function quote(s) { gsub(/\047/, "\047\047", s); return "\047" s "\047"; }
      function num(n)   { return (n == "") ? "NULL" : n; }
      {
        # 元ファイルのヘッダー順と完全に一致させています
        printf "INSERT INTO DMM_INDIVIDUAL_ACCOUNT (dmm_id, family_name, given_name, family_name_phonetic, given_name_phonetic, birthday, gender, zip_code, prefecture, city, street, building, phone, email, occupation, income, financial_assets, experience, experience_spot, experience_fx, experience_crypto, experience_other, intention, media, media_detail, bank_account_type, bank_code, bank_name, branch_code, branch_name, bank_account_number, conversion_date) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s);\n",
          quote($1),  # accountId
          quote($2),  # family_name
          quote($3),  # given_name
          quote($4),  # family_name_phonetic
          quote($5),  # given_name_phonetic
          ($6 == "") ? "NULL" : "to_date(" quote($6) ", \047YYYY-MM-DD\047)",  # birthday
          num($7),    # gender
          quote($8),  # zip_code
          quote($9),  # prefecture
          quote($10), # city
          quote($11), # street
          quote($12), # building
          quote($13), # phone
          quote($14), # email
          num($15),   # occupation
          num($16),   # income
          num($17),   # financial_assets
          num($18),   # experience
          num($19),   # experience_spot
          num($20),   # experience_fx
          num($21),   # experience_crypto
          num($22),   # experience_other
          num($23),   # intention
          num($24),   # media
          quote($25), # ★修正: mediaDetail (VARCHAR) -> quote() を使用
          num($26),   # ★修正: account_type (INTEGER) -> num() を使用
          quote($27), # ★修正: bank_code (VARCHAR)
          quote($28), # ★修正: bank_name (VARCHAR)
          quote($29), # ★修正: branch_code (VARCHAR)
          quote($30), # ★修正: branch_name (VARCHAR)
          quote($31), # ★修正: bank_account_number (VARCHAR)
          ($32 == "") ? "NULL" : "to_timestamp(" quote($32) ", \047YYYY-MM-DD HH24:MI:SS\047)"; # ★修正: conversionDate (TIMESTAMP) -> $32 を参照
      }
    ' "${tmpsql}" >> "${finalsql}" || return 1
  fi

  echo "SELECT NOW();" >> "${finalsql}"
  echo "COMMIT;" >> "${finalsql}"

  echo "done!"
  rm "${tmpsql}"*
}

# initialize
[[ ! ${outdir} ]] && outdir="out"
[[ ! ${utildir} ]] && utildir=${exdir}
source "${utildir}/logger.sh" || exit 1
newlogger "[dmm-gensql] "

# validation
[[ ! -f ${infile} ]] && errexit 1 "no such input file: ${infile}"

mkdir -p ${outdir}
sqlfile="$(basename ${infile})"
sqlfile="${outdir%/}/${sqlfile%.*}.sql"

# main process
info "script started. table = DMM_$([[ ${tmptbl} ]] && echo "TMP" || echo "INDIVIDUAL")_ACCOUNT"

# normalize
normalize_tsv ${infile} ${sqlfile}.tmp || errexit $? "failed to normalize tsv: ${infile} -> ${sqlfile}.tmp"

# generate insert sql
gen_sql "${sqlfile}" || errexit $? "failed to generate sql: sqlfile=${sqlfile}"

info "script completely finished."
cd ${currdir}
exit 0