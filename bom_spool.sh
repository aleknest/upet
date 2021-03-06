threads=2
PROJ='upet.scad'
EX='openscad '$PROJ
BOM='bom/bom_spool.txt'

list_export=("$EX -D cmd=\"report_spool\" --csglimit=3200000 --preview  -o render.png")
$list_export 2> ./0bom.txt

cat ./0bom.txt | grep ECHO | cut -d'"' -f 2 | cut -d ">" -f2 > ./1bom.txt
echo "*" >> ./1bom.txt

echo "" > $BOM
rm -f 2bom.txt
touch 2bom.txt
rm -f 4bom.txt
touch 4bom.txt

function handle_file
{
  sort $1 | uniq -c > $2
  while IFS2= read -r val
  do
    pcs="$( cut -d ' ' -f 1 <<< "$val" )";
    item="$( cut -d ' ' -f 2- <<< "$val" )";
    if [ "$pcs" != "1" ]
    then
      s="    $item, $pcs pcs"
    else
      s="    $item"
    fi
    echo "$s" >> $3
  done < $2
}

while IFS= read -r line
do
  if [[ ${line:0:1} == "#" ]] ; 
  then 
    val="${line:1}"
  else 
    if [[ ${line:0:1} == "*" ]] ; 
    then 
      handle_file ./2bom.txt ./3bom.txt ./$BOM

      rm -f ./2bom.txt
      touch ./2bom.txt

      val="${line:1}"
      if [ "$val" != "" ]
      then
        echo "* $val" >> ./$BOM
      fi
    else 
      echo "$line" >> ./2bom.txt
      echo "$line" >> ./4bom.txt
    fi
  fi
done < 1bom.txt

#echo "" >> $BOM
#echo "Aggregated BOM:" >> $BOM
#handle_file ./4bom.txt ./5bom.txt ./$BOM

rm -f ./0bom.txt
rm -f ./1bom.txt
rm -f ./2bom.txt
rm -f ./3bom.txt
rm -f ./4bom.txt
rm -f ./5bom.txt
rm -f ./render.png
