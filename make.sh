#!/bin/bash

#Repacker by henlob


################################################
MYDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
TMPDIR=$MYDIR/tmp 
OUTDIR=$MYDIR/out
TOOLSDIR=$MYDIR/tools
IMG2SDAT=$MYDIR/tools/img2sdat/img2sdat.py 
CACHEDIR=$MYDIR/cache
################################################

rm -r $TMPDIR $OUTDIR $CACHEDIR >> /dev/null 
mkdir $TMPDIR $OUTDIR $CACHEDIR >> /dev/null 

if [[ ! -n $1 ]]; then
    echo "BRUH : Need all parameters !"
    exit
fi

if [[ $1 = "-h" ]]; then
    echo "Usage :"
    echo "$0 <path to images / path to zip>"
    exit
fi 

if [[ $(echo $1 | grep 7z) ]]; then 
    INPUT=ZIP 
elif [[ $(echo $1 | grep zip) ]]; then 
    INPUT=ZIP 
else 
    INPUT=RAW
fi 

if [[ $INPUT = "ZIP" ]]; then
    mkdir $CACHEDIR 2>/dev/null 
    unzip $1 -d $CACHEDIR 
    INPUT=$CACHEDIR 
fi

if [[ $INPUT = "RAW" ]]; then
    if [[ $(ls $INPUT | grep product.img) ]]; then 
        PRODUCT=1
    fi 
    echo  "Turning raw image to sparse.."
    img2simg $INPUT/system.img $TMPDIR/system.img 2>/dev/null 
    img2simg $INPUT/vendor.img $TMPDIR/vendor.img 2>/dev/null 
    cp -f $1/boot.img $OUTDIR/
    if [[ $PRODUCT = 1 ]]; then 
        img2simg $IPNUT/product.img $TMPDIR/product.img 2>/dev/null 
    fi 
    echo "Converting simg into sdat.."
    ./$IMG2SDAT $TMPDIR/system.img -o $OUTDIR -v 4 -p system 2>/dev/null 
    ./$IMG2SDAT $TMPDIR/vendor.img -o $OUTDIR -v 4 -p vendor 2>/dev/null 
    if [[ $PRODUCT = 1 ]]; then
        ./$IMG2SDAT $TMPDIR/product.img -o $OUTDIR -v 4 -p product 2>/dev/null
    fi 
    echo "Adding brotli .."
    brotli -3jf $OUTDIR/system.new.dat 
    brotli -3jf $OUTDIR/vendor.new.dat 
    if [[ $PRODUCT = 1 ]]; then 
        brotli -3jf $OUTDIR/product.new.dat 
    fi 
    echo "Copying curtana files.. "
    touch $OUTDIR/dynamic_partitions_op_list 
    if [[ $PRODUCT = 1 ]]; then 
        cat $MYDIR/prebuilt/dynamic/list >> $OUTDIR/dynamic_partitions_op_list
        cp -fpr $MYDIR/prebuilt/dynamic/META-INF/ $OUTDIR/

    else 
        cat $MYDIR/prebuilt/normal/list  >> $OUTDIR/dynamic_partitions_op_list
        cp -fpr $MYDIR/prebuilt/normal/META-INF $OUTDIR/
    fi 
    echo "How should we name your zip ?"
    read -p "" name 
    cd $OUTDIR 
    zip -r $name-henlob-repacker.zip * >> /dev/null 
    cd .. 
    rm -r $CACHEDIR
    mkdir $CACHEDIR 
    cp $OUTDIR/*repacker.zip $CACHEDIR
    rm -r $OUTDIR 
    mv $CACHEDIR $OUTDIR 
    echo "Successfully turned fastboot ROM into recovery ROM"
fi 


    
