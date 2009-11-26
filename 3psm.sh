#!/bin/bash
# 本程式依GPLv3授權，原作者(ronmi <ronmi@rmi.twbbs.org>)不作任何擔保
# 詳細規定及權利義務，請參考 http://www.gnu.org/licenses/gpl.html

export x_3psm="第三方軟體來源管理程式"

function 3psm_add()
{
	x_input_source="請輸入套件庫位置"
	x_input_id="請為這個套件庫取個簡單易記的代號"
	x_updating="正在更新套件資訊"
	x_recv_keys="嘗試取得公鑰"

	A=`zenity --entry --title="${x_3psm}" --text="${x_input_source}" --width=400`
	if [ "x$A" == "x" ]; then
		exit 0
	fi

	B=`zenity --entry --title="${x_3psm}" --text="${x_input_id}" --width=400`
	if [ "x$B" == "x" ]; then
		B=`echo "$A"|cut -d " " -f 2|cut -d "/" -f 3`
	fi
	C=`echo $B|sed 's/ /_/g'`

	TMPFILE=`mktemp`

	echo "putting $A into $C.list"
	echo "$A" > ${TMPFILE}
	gksudo -D "${x_3psm}" -m "${x_updating}" \
		"cp ${TMPFILE} /etc/apt/sources.list.d/${C}.list"
	gksudo -D "${x_3psm}" -m "${x_updating}" \
		"chmod a+r /etc/apt/sources.list.d/${C}.list"

	echo "apt-get update"
	gksudo -D "${x_3psm}" -m "${x_updating}" \
		"apt-get update" 2>&1 | tee ${TMPFILE} | zenity --progress --width=400\
		--title="${x_3psm}" --pulsate --text="${x_updating}" --auto-close
	grep NO_PUBKEY "${TMPFILE}" > /dev/null
	if [ $? -eq 1 ]; then
		exit
	fi

	echo "test key"
	T=`grep NO_PUBKEY "${TMPFILE}"`
	for i in $T; do K=`echo $i|cut -b 9-`; done
	echo "i got key $K"

	echo "gksudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $K"
	gksudo -D "${x_3psm}" -m "${x_updating}" \
		"apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $K" \
		| zenity --progress --title="${x_3psm}" --pulsate \
		--text="${x_recv_keys}" --auto-close --width=400
	echo "apt-get update"
	gksudo -D "${x_3psm}" -m "${x_updating}" \
		"apt-get update" 2>&1 | tee ${TMPFILE} | zenity --progress --width=400\
		--title="${x_3psm}" --pulsate --text="${x_updating}" --auto-close

	rm -f ${TMPFILE}
}
