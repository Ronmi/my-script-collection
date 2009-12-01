#!/bin/bash
# 本程式依GPLv3授權，原作者(ronmi <ronmi@rmi.twbbs.org>)不作任何擔保
# 詳細規定及權利義務，請參考 http://www.gnu.org/licenses/gpl.html

export x_title="wine環境與日文設定"

# 測試目前使用的ui是qt base還是gtk base

if [ x"$KDE_FULL_SESSION" == x"true" ]; then
	ui="kde"
else
	ui="gtk"
fi
export ui

function uisudo()
{
	if [ "${ui}" == "kde" ]; then
		kdesudo --caption "$1" --comment "$2" "$3"
	else
		gksudo -D "$1" -m "$2" "$3"
	fi
}

function uiprogress()
{
	if [ "${ui}" == "kde" ]; then
		ref=`kdialog --progressbar "$1" 2`
		qdbus $ref Set "" "value" 1
		cat /dev/stdin > /dev/null
		qdbus $ref Set "" "value" 2
		qdbus $ref close
	else
		zenity --progress --title="${x_title}" --text="$1" --auto-close \
			--pulsate --width=400
	fi
}

function get_openfont()
{
	openfont="ftp://ftp.opendesktop.org.tw/odp/ODOFonts/OpenFonts/opendesktop-fonts-1.4.2.tar.gz"
	TMPDIR=/tmp/openfont

	mkdir -p ${TMPDIR}
	wget --progress=dot -O ${TMPDIR}/openfont.tgz "${openfont}" 2>&1 | tee /dev/stderr \
		| uiprogress "正在下載文鼎PL新宋體"
	cd ${TMPDIR}
	tar zxf openfont.tgz
	cd opendesktop-fonts-1.4.2
	uisudo "${x_title}" "將字型複製到系統路徑" \
		"cp odokai.ttf odosung.ttc /usr/share/fonts/truetype/arphic/"
	uisudo "${x_title}" "將字型設定複製到系統路徑" \
		"cp 69-odofonts.conf 80-odofonts-simulate-MS-triditional-chinese.conf \
		/etc/fonts/conf.avail"
	uisudo "${x_title}" "設定字型" \
		"ln -sf /etc/fonts/conf.avail/69-odofonts.conf /etc/fonts/conf.d/69-odofonts.conf"
	uisudo "${x_title}" "設定字型" \
		"ln -sf /etc/fonts/conf.avail/80-odofonts-simulate-MS-triditional-chinese.conf\
		/etc/fonts/conf.d/80-odofonts-simulate-MS-triditional-chinese.conf"
	fc-cache 2>&1 | tee /dev/stderr | uiprogress "更新字型快取中"
	rm -frv ${TMPDIR} 2>&1 | uiprogress "清除暫存資料"
}

function get_ja_font()
{
	ja="language-support-fonts-ja ipafont ipamonafont"
	TMPFILE=`mktemp`
	chmod a+r ${TMPFILE}
	cat /etc/apt/sources.list.d/*|grep "http://archive.ubuntulinux.jp/ubuntu-ja/ karmic-non-free/"
	if [ $? -eq 1 ]; then
		echo "deb http://archive.ubuntulinux.jp/ubuntu-ja/ karmic-non-free/" > ${TMPFILE}
		uisudo "${x_title}" "新增ipa mona字型套件庫" \
			"cp ${TMPFILE} /etc/apt/sources.list.d/ubuntu-ja.list"		
	fi
	uisudo "${x_title}" "更新套件列表" \
		"apt-get update" 2>&1 | tee /dev/stderr | tee ${TMPFILE} \
		| uiprogress "更新套件列表中"
	grep NO_PUBKEY "${TMPFILE}" > /dev/null
	if [ $? -eq 0 ]; then
		T=`grep NO_PUBKEY "${TMPFILE}"`
		for i in $T; do K=`echo $i|cut -b 9-`; done
		uisudo "${x_title}" "取回公鑰" \
			"apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $K" \
			| uiprogress "正在向keyserver取回公鑰"
		uisudo "${x_title}" "再次更新套件列表" \
			"apt-get update" 2>&1 | tee /dev/stderr | uiprogress "更新套件列表中"
	fi
	uisudo "${x_title}" "安裝日文字型" "apt-get -y install ${ja}" 2>&1 | tee /dev/stderr \
		| uiprogress "安裝日文字型"
	rm -fr ${TMPFILE}
}

function setup_wine()
{
	TMPFILE=`mktemp`
	(
		echo "REGEDIT4"
		echo ""
		echo "[HKEY_CURRENT_USER\\Software\\Wine\\Fonts\\Replacement]"
		echo "\"MingLiU\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"MS Sans Serif\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"PMingLiU\"=\"文鼎ＰＬ新宋\""
		echo "\"Tahoma\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"Verdana\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"新細明體\"=\"文鼎ＰＬ新宋\""
		echo "\"標楷體\"=\"文鼎ＰＬ新中楷\""
		echo "\"細明體\"=\"文鼎ＰＬ新宋 Mono\""		echo ""
		echo "[HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes]"
		echo "\"Arial\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"Courier\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"Courier New\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"Helv\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"Helvetica\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"KaiU\"=\"文鼎ＰＬ新中楷\""
		echo "\"MingLiU\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"MS Gothic\"=\"IPAGothic\""
		echo "\"MS Mincho\"=\"IPAMincho\""
		echo "\"MS PGothic\"=\"IPAPGothic\""
		echo "\"MS PMincho\"=\"IPAPMincho\""
		echo "\"MS Sans Serif\"=\"文鼎ＰＬ新宋\""
		echo "\"MS Serif\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"MS Shell Dlg\"=\"文鼎ＰＬ新宋\""
		echo "\"MS Shell Dlg 2\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"MS UI Gothic\"=\"IPAGothic\""
		echo "\"PKaiU\"=\"文鼎ＰＬ新中楷\""
		echo "\"PMingLiU\"=\"文鼎ＰＬ新宋\""
		echo "\"Small Fonts\"=\"文鼎ＰＬ新宋\""
		echo "\"Times\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"Times New Roman\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"Tms Rmn\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"Verdana\"=\"文鼎ＰＬ新宋\""
		echo "\"新細明體\"=\"文鼎ＰＬ新宋\""
		echo "\"標楷體\"=\"文鼎ＰＬ新中楷\""
		echo "\"細明體\"=\"文鼎ＰＬ新宋 Mono\""
		echo ""
	) | iconv -t big5 -f utf8 > ${TMPFILE}

	uisudo "${x_title}" "安裝wine 1.2" "apt-get -y install wine1.2" \
		| tee /dev/stderr | uiprogress "安裝wine1.2"
	wine regedit ${TMPFILE} 2>&1 | tee /dev/stderr | uiprogress "匯入字型設定"
	rm -fr ${TMPFILE}
	mkdir -p ${HOME}/bin
	wget -O ${HOME}/bin/winetricks "http://www.kegel.com/wine/winetricks" \
		| uiprogress "下載winetricks"
	chmod a+x ${HOME}/bin/winetricks
}

function update_locale()
{
	zhtw=`mktemp`
	jajp=`mktemp`
	(
		echo "zh_HK.UTF-8 UTF-8"
		echo "zh_TW.UTF-8 UTF-8"
		echo "zh_TW.BIG5 BIG5"
		echo "zh_TW UTF-8"
	) > ${zhtw}
	(
		echo "ja_JP.UTF-8 UTF-8"
		echo "ja_JP.SJIS SJIS"
		echo "ja_JP UTF-8"
	) > ${jajp}
	chmod a+r ${zhtw} ${jajp}
	uisudo "${x_title}" "修改中文locale設定" "cp ${zhtw} /var/lib/locales/supported.d/zh-hant"
	uisudo "${x_title}" "新增日文locale設定" "cp ${jajp} /var/lib/locales/supported.d/ja"
	uisudo "${x_title}" "更新locale" "locale-gen"
	rm -fr ${zhtw} ${jajp}
}

function make_jwine()
{
	mkdir -p ${HOME}/bin
	(
		echo "#!/bin/sh"
		echo ""
		echo "export LANG=\"ja_JP.UTF-8\""
		echo "export WINEPREFIX=\"${HOME}/.jwine\""
		echo "case \$1 in"
		echo "  config)"
		echo "    winecfg"
		echo "    ;;"
		echo "  trick)"
		echo "    winetricks"
		echo "    ;;"
		echo "  initfont)"
		echo "    TMPFILE=\`mktemp\`"
		echo "    ("
		echo "      echo \"REGEDIT4\""
		echo "      echo \"\""
		echo " 	    echo \"[HKEY_CURRENT_USER\\\\Software\\\\Wine\\\\Fonts\\\\Replacement]\""
		echo "      echo \"\\\"Helv\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"Helvetica\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"Tms Rmn\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"Times\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"MS Sans\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"MS Sans Serif\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"MS Gothic\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"MS Mincho\\\"=\\\"IPAMonaMincho\\\"\""
		echo "      echo \"\\\"MS PGothic\\\"=\\\"IPAMonaPGothic\\\"\""
		echo "      echo \"\\\"MS PMincho\\\"=\\\"IPAMonaPMincho\\\"\""
		echo "      echo \"\\\"MS UI Gothic\\\"=\\\"IPAMonaUIGothic\\\"\""
		echo "      echo \"\\\"ＭＳ ゴシック\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"ＭＳ 明朝\\\"=\\\"IPAMonaMincho\\\"\""
		echo "      echo \"\\\"ＭＳ Ｐゴシック\\\"=\\\"IPAMonaPGothic\\\"\""
		echo "      echo \"\\\"ＭＳ Ｐ明朝\\\"=\\\"IPAMonaPMincho\\\"\""
		echo "      echo \"\""
		echo "      echo \"[HKEY_LOCAL_MACHINE\\\\Software\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\\\\FontSubstitutes]\""
		echo "      echo \"\\\"MS Shell Dlg\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"MS Shell Dlg 2\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"Helv\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"Helvetica\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"Tms Rmn\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"Times\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"MS Sans\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"MS Sans Serif\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"MS Gothic\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"MS Mincho\\\"=\\\"IPAMonaMincho\\\"\""
		echo "      echo \"\\\"MS PGothic\\\"=\\\"IPAMonaPGothic\\\"\""
		echo "      echo \"\\\"MS PMincho\\\"=\\\"IPAMonaPMincho\\\"\""
		echo "      echo \"\\\"MS UI Gothic\\\"=\\\"IPAMonaUIGothic\\\"\""
		echo "      echo \"\\\"ＭＳ ゴシック\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"ＭＳ 明朝\\\"=\\\"IPAMonaMincho\\\"\""
		echo "      echo \"\\\"ＭＳ Ｐゴシック\\\"=\\\"IPAMonaPGothic\\\"\""
		echo "      echo \"\\\"ＭＳ Ｐ明朝\\\"=\\\"IPAMonaPMincho\\\"\""
		echo "      echo \"\""
		echo "    ) | iconv -t sjis -f utf8 > \${TMPFILE}"
		echo "    wine regedit \${TMPFILE}"
		echo "    rm -f \${TMPFILE}"
		echo "    ;;"
		echo "  help)"
		echo "    echo \"Usage:\""
		echo "    echo \"  \$0 {help|trick|config|initfont}  or\""
		echo "    echo \"  \$0 program\""
		echo "    ;;"
		echo "  *)"
		echo "    wine \$*"
		echo "    ;;"
		echo "esac"
	) > ${HOME}/bin/jwine
	chmod a+rx ${HOME}/bin/jwine
	${HOME}/bin/jwine initfont | uiprogress "設定wine在日文環境下使用的字型"
}

if [ "$1" == "jwine" ]; then
	make_jwine
	exit 0
fi

get_openfont
get_ja_font
setup_wine
update_locale
make_jwine

uisudo "${x_title}" "清除套件快取" "apt-get clean"

