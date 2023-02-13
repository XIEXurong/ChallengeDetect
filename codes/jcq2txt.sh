
for name in `cat used_persons_list.txt`; do
    cat data_preprocess2/${name}.jcq | grep -a "</p>$" | sed "s/<\/p>$//g" | sed "s/.*;\">//g" | sed "s/<br \/>//g" > data_preprocess2/${name}.txt
done
