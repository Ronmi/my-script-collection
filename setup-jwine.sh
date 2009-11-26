#!/bin/bash
# 本程式依GPLv3授權，原作者(ronmi <ronmi@rmi.twbbs.org>)不作任何擔保
# 詳細規定及權利義務，請參考 http://www.gnu.org/licenses/gpl.html

export x_title="wine環境與日文設定"

function get_openfont()
{
	openfont="ftp://ftp.opendesktop.org.tw/odp/ODOFonts/OpenFonts/opendesktop-fonts-1.4.2.tar.gz"
	TMPDIR=/tmp/openfont

	mkdir -p ${TMPDIR}
	wget --progress=dot -O ${TMPDIR}/openfont.tgz "${openfont}" 2>&1 | tee /dev/stderr \
		| zenity --progress --title=${x_title} --text="正在下載文鼎PL新宋體" --auto-close \
		--pulsate --width 400
	cd ${TMPDIR}
	tar zxf openfont.tgz
	cd opendesktop-fonts-1.4.2
	gksudo -D "${x_title}" -m "將字型複製到系統路徑" \
		"cp odokai.ttf odosung.ttc /usr/share/fonts/truetype/arphic/"
	gksudo -D "${x_title}" -m "將字型設定複製到系統路徑" \
		"cp 69-odofonts.conf 80-odofonts-simulate-MS-triditional-chinese.conf \
		/etc/fonts/conf.avail"
	gksudo -D "${x_title}" -m "設定字型" \
		"ln -sf /etc/fonts/conf.avail/69-odofonts.conf /etc/fonts/conf.d/69-odofonts.conf"
	gksudo -D "${x_title}" -m "設定字型" \
		"ln -sf /etc/fonts/conf.avail/80-odofonts-simulate-MS-triditional-chinese.conf\
		/etc/fonts/conf.d/80-odofonts-simulate-MS-triditional-chinese.conf"
	fc-cache 2>&1 | tee /dev/stderr | zenity --progress --title=${x_title} \
		--text="更新字型快取中" --auto-close --pulsate --width 400
	rm -frv ${TMPDIR} 2>&1 | zenity --progress --title=${x_title} --text="清除暫存資料" \
		--auto-close --pulsate --width 400
}

function get_ja_font()
{
	ja="language-support-fonts-ja ipafont ipamonafont"
	TMPFILE=`mktemp`
	chmod a+r ${TMPFILE}
	T=`cat /etc/apt/sources.list.d/*|grep "http://archive.ubuntulinux.jp/ubuntu-ja/ karmic-non-free/"`
	if [ "x$T" == "x0" ]; then
		echo "deb http://archive.ubuntulinux.jp/ubuntu-ja/ karmic-non-free/" > ${TMPFILE}
		gksudo -D "${x_title}" -m "新增ipa mona字型套件庫" \
			"cp ${TMPFILE} /etc/apt/sources.list.d/ubuntu-ja.list"		
	fi
	gksudo -D "${x_title}" -m "更新套件列表" \
		"apt-get update" 2>&1 | tee /dev/stderr | tee ${TMPFILE} | zenity --progress \
		--title="${x_title}" --text="更新套件列表中" --pulsate --auto-close --width 400
	grep NO_PUBKEY "${TMPFILE}" > /dev/null
	if [ $? -eq 0 ]; then
		T=`grep NO_PUBKEY "${TMPFILE}"`
		for i in $T; do K=`echo $i|cut -b 9-`; done
		gksudo -D "${x_title}" -m "取回公鑰" \
			"apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $K" \
			| zenity --progress --title="${x_title}" --pulsate \
			--text="正在向keyserver取回公鑰" --auto-close --width 400
		gksudo -D "${x_title}" -m "再次更新套件列表" \
			"apt-get update" 2>&1 | tee /dev/stderr | zenity --progress \
			--title="${x_title}" --text="更新套件列表中" --pulsate --auto-close --width 400
	fi
	gksudo -D "${x_title}" -m "安裝日文字型" "apt-get -y install ${ja}" 2>&1 | tee /dev/stderr \
		| zenity --progress --title="${x_title}" --text="安裝日文字型" --pulsate \
		--auto-close --width 400
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
		echo "\"Arial Baltic,186\"=\"Arial,186\""
		echo "\"Arial CE,238\"=\"Arial,238\""
		echo "\"Arial CYR,204\"=\"Arial,204\""
		echo "\"Arial Greek,161\"=\"Arial,161\""
		echo "\"Arial TUR,162\"=\"Arial,162\""
		echo "\"Courier\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"Courier New\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"Courier New Baltic,186\"=\"Courier New,186\""
		echo "\"Courier New CE,238\"=\"Courier New,238\""
		echo "\"Courier New CYR,204\"=\"Courier New,204\""
		echo "\"Courier New Greek,161\"=\"Courier New,161\""
		echo "\"Courier New TUR,162\"=\"Courier New,162\""
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
		echo "\"Times New Roman Baltic,186\"=\"Times New Roman,186\""
		echo "\"Times New Roman CE,238\"=\"Times New Roman,238\""
		echo "\"Times New Roman CYR,204\"=\"Times New Roman,204\""
		echo "\"Times New Roman Greek,161\"=\"Times New Roman,161\""
		echo "\"Times New Roman TUR,162\"=\"Times New Roman,162\""
		echo "\"Tms Rmn\"=\"文鼎ＰＬ新宋 Mono\""
		echo "\"Verdana\"=\"文鼎ＰＬ新宋\""
		echo "\"新細明體\"=\"文鼎ＰＬ新宋\""
		echo "\"標楷體\"=\"文鼎ＰＬ新中楷\""
		echo "\"細明體\"=\"文鼎ＰＬ新宋 Mono\""
		echo ""
	) | iconv -t big5 -f utf8 > ${TMPFILE}

	gksudo -D "${x_title}" -m "安裝wine 1.2" "apt-get -y install wine1.2" \
		| tee /dev/stderr | zenity --progress --title="${x_title}" --text="安裝wine" \
		--auto-close --pulsate --width 400
	wine regedit ${TMPFILE} 2>&1 | tee /dev/stderr | zenity --progress --title="${x_title}" \
		--text="匯入字型設定" --auto-close --pulsate --width 400
	rm -fr ${TMPFILE}
	mkdir -p ${HOME}/bin
	wget -O ${HOME}/bin/winetricks "http://www.kegel.com/wine/winetricks" | zenity \
		--progress --title="${x_title}" --text="下載winetricks" --pulsate \
		--auto-close --width 400
	chmod a+x ${HOME}/bin/winetricks
	sh ${HOME}/bin/winetricks
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
	gksudo -D "${x_title}" -m "修改中文locale設定" "cp ${zhtw} /var/lib/locales/zh-hant"
	gksudo -D "${x_title}" -m "新增日文locale設定" "cp ${jajp} /var/lib/locales/ja"
	gksudo -D "${x_title}" -m "更新locale" "locale-gen"
	rm -fr ${zhtw} ${jajp}
}

function make_jwine()
{
	mkdir -p ${HOME}/bin
	(
		echo "#!/bin/sh"
		echo ""
		echo "export LANG=\"ja_JP\""
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
		echo "      echo \"[HKEY_LOCAL_MACHINE\\\\Software\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\\\\FontSubstitutes]\""
		echo "      echo \"\\\"MS Shell Dlg\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"MS Shell Dlg 2\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"Helv\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\\\"MS Sans Serif\\\"=\\\"IPAMonaGothic\\\"\""
		echo "      echo \"\""
		echo "    ) > \${TMPFILE}"
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
}

get_openfont
get_ja_font
setup_wine
update_locale
make_jwine

gksudo -D "${x_title}" -m "清除套件快取" "apt-get clean"

zenity --info --title="${x_title}" --text="日文wine環境已經設定好，前導用的shell scrip已放置在\n\
${HOME}/bin/jwine，請在終端機中執行\n${HOME}/bin/jwine help 來查看說明"
