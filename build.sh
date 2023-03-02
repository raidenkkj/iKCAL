#!/system/bin/sh

# Colors
yellow=$(tput setaf 3)
green=$(tput setaf 2)
boldgreen=${bold}${green}
boldred=${bold}${red}
red=$(tput setaf 1)
blue=$(tput setaf 4)
bold=$(tput bold)
blink=$(tput blink)
default=$(tput sgr0)

# Utilities
iname=iKCAL
year=$(date +%Y)
month=$(date +%m)
day=$(date +%d)
hour=$(date +%H)
minute=$(date +%M)
bddate=$(date +%d-%m-%Y)
outdir=$HOME/storage/downloads/builds

printf "\033c"
echo "${bold}${green}"
echo "|      iKCAL Module Builder     |"
echo "|      raidenkk @ telegram      |"
echo "${bold}"
read -r -p ${boldgreen}'Codename: '${blue} cdnm
read -r -p ${boldgreen}'Version: '${blue} vers
read -r -p ${boldgreen}'Version code: '${blue} vcode

init=$(date +%s)

[ "$(grep bdate $(pwd)/module.prop)" ] && sed -i -e "/bdate=/s/=.*/=$bddate/" "$(pwd)/module.prop"

[ ! "$(grep bdate $(pwd)/module.prop)" ] && echo "bdate=$bddate" >>"$(pwd)/module.prop"

sed -i -e "/version=/s/=.*/=$vers/" "$(pwd)/module.prop"
sed -i -e "/versionCode=/s/=.*/=$vcode/" "$(pwd)/module.prop"
sed -i -e "/codename=/s/=.*/=$cdnm/" "$(pwd)/module.prop"

echo "${bold}"
echo "${boldgreen}Build starting at $(date)"
echo ""

echo "${default}${bold}Zipping ${blink}$iname-$cdnm-$day$month$year$hour$minute..."
echo ""


zip -0 -r9 -ll "$iname-$cdnm-$day$month$year$hour$minute.zip" . -x 'ikcal' -x '*.bak*' -x '*.git*' -x '*mod-util.sh*' -x '*changelog.md*' -x '*images*' -x '*build.sh*' -x '*placeholder*'

if [[ -d "$outdir" ]]; then
	mv -f "$iname-$cdnm-$day$month$year$hour$minute.zip" $outdir
else
	mkdir $outdir
	mv -f "$iname-$cdnm-$day$month$year$hour$minute.zip" $outdir
fi

exit=$(date +%s)

exec_time=$((exit - init))

[ $? -ne "1" ] && {
    echo ""
	echo "${boldgreen}Build done in "$((exec_time / 60))" minutes and $exec_time seconds!${blue} Check the out folder to the finished build."
	exit 0
} || {
    echo ""
	echo "${boldred}Build failed in "$((exec_time / 60))" minutes and $exec_time seconds!${yellow} Please fix the error(s) and try again."
	exit 1
}
