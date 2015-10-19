#!/bin/sh

# IOS - Projekt 1, skript wedi
# Autor: Dominik Hlavac Duran (xhlava42@stud.fit.vutbr.cz) #

export LC_ALL=POSIX

#test ci funguje realpath
retst=$(realpath . > /dev/null 2>&1)
tesat=$?
if [ $tesat -ne 0 ]; then
  echo "ERROR cesta k suboru sa nenasla" >&2
  exit $tesat
fi
#-------------------------------------------------------------------------------------------
cesta=$(realpath .)
arg="$1"

most=false
list=false
before=false
after=false
barg=""
#-----------------premenne----------------------------------------

#-------------------------------------------------------------------------------------------


#funkcia pre editovanie suboru
editing() 
{
  if [ -z "$EDITOR" ]; then 
   if [ -z "$VISUAL" ]; then
     echo "ERROR nebol zadany editor" >&2 
   else
    $VISUAL "$arg";
   fi
  else 
   $EDITOR "$arg";
  fi
  if [ -f "$arg" ];then 
   echo "${arg##*/}:$(realpath "${arg}"):$(date +%Y-%m-%d)" >> $WEDI_RC #ulozi do wedi history spustenie skriptu
  fi
}
#-------------------------------------------------------------------------------------------

#------------------------funkcie-----------------------------------------------------------------

#test ci je wedi rc prazdne 
if [ -z "$WEDI_RC" ]; then 
	echo "ERROR nebola zadana cesta pre ukladanie udajov" >&2
	exit 
fi
#-------------------------------------------------------------------------------------------


# editovanie aktualneho adresara ak je wedi spustene bez argumentov
if [ "$#" = "0" ]; then
  pom=`grep "$cesta/[^/]*$" "$WEDI_RC" | sed -n '1!G;h;$p' |cut -f2 -d ':'`
  for x in $pom ; do
    if [ -f $x ];then 
      arg="$x"
      break
    fi
  done
  if  [ -z "$arg" ]; then 
    echo "ERROR nebol editovany ziadny subor" >&2
    exit 1
  else 
   editing
  fi
fi
#-------------------------------------------------------------------------------------------

#testovanie na subor/adresar
if [ -d "$arg" ]; then
  cesta="$1"
  pom=`grep "$cesta/[^/]*$" "$WEDI_RC" | sed -n '1!G;h;$p' |cut -f2 -d ':'`
  for x in $pom ; do
    if [ -f $x ];then 
      arg="$x"
      break
    fi
  done
  if  [ -z "$arg" ]; then 
     echo "ERROR nebol editovany ziadny subor" >&2
     exit 1
    else 
     editing
  fi
elif [ "$1" != "-l" ] && [ "$1" != "-m" ] && [ "$1" != "-a" ] && [ "$1" != "-b" ]; then
editing

fi
#---------

#------spracovanie_prepinacov-----------------------------------------------------------

while getopts 'mlab' opt; do
  case "$opt" in
    m)
     most=true;;
    l)
     list=true;;
    a)
      after=true ;;
    b)
      before=true
      barg=$OPTARG ;;
  esac
done
#prepinac -a----------------------- 
if $after; then
  if [ "$#" = "1" ]; then
    echo "ERROR je potrebne zadat argument vo formate YYYY-MM-DD" >&2
    exit 1  
  elif [ "$#" = "2" ]; then
    cesta=$(realpath .)
    datum=`echo "$2" | sed "s/-//g"`
    zaznam=`grep "$cesta/[^/]*$" "$WEDI_RC" | sort`
    meno_old="hatatitsddscb4542dfla"
    for polozka in $zaznam ; do
      datumwedi=`echo $polozka |cut -f3 -d ':' | sed "s/-//g"`
      if [ $datumwedi -ge $datum ];then
        meno=`echo $polozka |cut -f1 -d ':'`
        if [ "$meno" != "$meno_old" ];then
         echo "$meno"
         meno_old="$meno"
        fi
      fi
    done
  elif [ "$#" = "3" ]; then 
    cesta="$3"
    datum=`echo "$2" | sed "s/-//g"`
    zaznam=`grep "$cesta/[^/]*$" "$WEDI_RC" | sort`
    meno_old="hatatitsddscb4542dfla"
    for polozka in $zaznam ; do
      datumwedi=`echo $polozka |cut -f3 -d ':' | sed "s/-//g"`
      if [ $datumwedi -ge $datum ];then
        meno=`echo $polozka |cut -f1 -d ':'`
        if [ "$meno" != "$meno_old" ];then
         echo "$meno"
         meno_old="$meno"
        fi
      fi
    done
  elif [ "$#" > "3" ]; then
    echo "ERROR prilis vela argumentov" >&2
    exit 1 
  fi
fi
#-------------------------------------------------------------------------------------------

#prepinac -b----------------------- 
if $before; then
  if [ "$#" = "1" ]; then
    echo "ERROR je potrebne zadat argument vo formate YYYY-MM-DD"
    exit 1  
  elif [ "$#" = "2" ]; then
    cesta=$(realpath .)
    datum=`echo "$2" | sed "s/-//g"`
    zaznam=`grep "$cesta/[^/]*$" "$WEDI_RC" | sort`
    meno_old="hatatitsddscb4542dfla"
    for polozka in $zaznam ; do
      datumwedi=`echo $polozka |cut -f3 -d ':' | sed "s/-//g"`
      if [ $datumwedi -le $datum ];then
        meno=`echo $polozka |cut -f1 -d ':'`
        if [ "$meno" != "$meno_old" ];then
         echo "$meno"
         meno_old="$meno"
        fi
      fi
    done
  elif [ "$#" = "3" ]; then 
    cesta="$3"
    datum=`echo "$2" | sed "s/-//g"`
    zaznam=`grep "$cesta/[^/]*$" "$WEDI_RC" | sort`
    meno_old="hatatitsddscb4542dfla"
    for polozka in $zaznam ; do
      datumwedi=`echo $polozka |cut -f3 -d ':' | sed "s/-//g"`
      if [ $datumwedi -le $datum ];then
        meno=`echo $polozka |cut -f1 -d ':'`
        if [ "$meno" != "$meno_old" ];then
         echo "$meno"
         meno_old="$meno"
        fi
      fi
    done
  elif [ "$#" > "3" ]; then
    echo "ERROR prilis vela argumentov" >&2
    exit 1 
  fi

fi
#-------------------------------------------------------------------------------------------

#prepinac -m----------------------- neupravovat
if $most; then
  if [ "$#" = "1" ]; then
    cesta=$(realpath .)
    pom=`grep "$cesta/[^/]*$" "$WEDI_RC" | cut -f2 -d ':' |sort |uniq -c | sort -r | awk '{print $2}'`
    for x in $pom ; do
      if [ -f $x ];then 
       arg=$x
       break
     fi
    done
    if  [ -z "$arg" ]; then 
     echo "ERROR nebol editovany ziadny subor" >&2
     exit 1
    else 
     editing
    fi
  elif [ "$#" = "2" ]; then
    if [ -d $2 ]; then
      cesta="$2"
     pom=`grep "$cesta/[^/]*$" "$WEDI_RC" | cut -f2 -d ':' |sort |uniq -c | sort -r | awk '{print $2}'`
     for x in $pom ; do
       if [ -f $x ];then 
        arg=$x
        break
       fi
      done
    fi
    if  [ -z "$arg" ]; then 
     echo "ERROR nebol editovany ziadny subor" >&2
     exit 1
    else 
     editing
    fi
  elif [ "$#" > "2" ]; then
    echo "ERROR prilis vela argumentov" >&2
    exit 1 
  fi
fi
#-------------------------------------------------------------------------------------------
#prepinac -l----------------------- neupravovat
if $list; then
  if [ "$#" = "1" ]; then
    cesta=$(realpath .)
    arg=`grep "$cesta/[^/]*$" "$WEDI_RC" | cut -f1 -d ':'`
    if  [ -z "$arg" ]; then 
     echo "ERROR nebol editovany ziadny subor" >&2
     exit 1
    else 
     grep "$cesta/[^/]*$" "$WEDI_RC" | cut -f1 -d ':' |sort |uniq
    fi
  elif [ "$#" = "2" ]; then
    if [ -d $2 ]; then
      cesta=$2
      arg=`grep "$cesta/[^/]*$" "$WEDI_RC" | cut -f1 -d ':'`
      if  [ -z "$arg" ]; then 
       echo "ERROR nebol editovany ziadny subor" >&2
       exit 1
      else 
       grep "$cesta/[^/]*$" "$WEDI_RC" | cut -f1 -d ':' |sort |uniq
      fi
    else
      echo "ERROR musi byt zadany adressar" >&2
      exit 1
    fi
  elif [ "$#" > "2" ]; then
    echo "ERROR bolo zadanych vela parametrov" >&2
    exit 1 
  fi
fi

#-------------------------------------------------------------------------------------------
