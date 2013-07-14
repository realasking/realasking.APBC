#!/bin/bash 
#pre-processing photos for developing,
#it's a part of APBC, version 1.0
#Author：realasking
#2013-07-14

crop_para(){
	y1=`echo "scale=8;$original_x * $f_y / $f_x"|bc`
	y1=`echo "$y1"|cut -d"." -f1`
	if(($y1<$original_y));then
		x_new=$original_x
		y_new=`echo "$y1"|cut -d"." -f1`
		y_o=`echo "scale=8;( $original_y - $y1 ) / 2"|bc`
		y_o=`echo "$y_o"|cut -d"." -f1`
		x_o=0
	else
		x1=`echo "scale=8;$original_y * $f_x / $f_y"|bc`
		x_new=`echo "$x1"|cut -d"." -f1`
		y_new=$original_y 
		y_o=0
		x_o=`echo "scale=8;( $original_x - $x1 ) / 2"|bc`
		x_o=`echo "$x_o"|cut -d"." -f1`
	fi
}

original_size=`identify $1|cut -d" " -f3`
real_orig_x=`echo $original_size |cut -d"x" -f1`
real_orig_y=`echo $original_size |cut -d"x" -f2`
if(($real_orig_y>$real_orig_x));then 
	original_y=$real_orig_x 
	original_x=$real_orig_y 
	flag=1
else
	original_y=$real_orig_y 
	original_x=$real_orig_x 
	flag=0 
fi

if [ $3 == 3R ];then
	f_x=10
	f_y=7
	ps_x=1500
	ps_y=1050
elif [ $3 == 3D ];then
	f_x=4
	f_y=3
	ps_x=1606
	ps_y=1050
elif [ $3 == 4R ];then
	f_x=3
	f_y=2
	ps_x=1800
	ps_y=1200
elif [ $3 == 4D ];then
	f_x=4
	f_y=3
	ps_x=1800 
	ps_y=1350
elif [ $3 == 5R ];then
	f_x=7
	f_y=5
	ps_x=2100
	ps_y=1500
elif [ $3 == 6R ];then
	f_x=4
	f_y=3
	ps_x=2400
	ps_y=1800 
elif [ $3 == 8R ];then
	f_x=5
	f_y=4
	ps_x=3000
	ps_y=2400 
elif [ $3 == 12c ];then
	f_x=3
	f_y=2
	ps_x=3600
	ps_y=2400
elif [ $3 == 12bc ];then
	f_x=6
	f_y=5
	ps_x=3600 
	ps_y=3000
elif [ $3 == 14c ];then
	f_x=7
	f_y=5
	ps_x=4200
	ps_y=3000
elif [ $3 == 1366 ];then
	f_x=16
	f_y=9
	ps_x=1366
	ps_y=768
fi

if [ $5 == "DC" ];then 
	pepp="photo_exif.sh"
elif [ $5 == "DSLR" ];then 
	pepp="photo_exif_DSLR.sh"
fi

crop_para 

if(($flag==0));then
	convert -crop "$x_new"x"$y_new"+"$x_o"+"$y_o" $1 c_$1
	ps_shape=$ps_x
	ps_shape_2=$ps_y
else
	convert -crop "$y_new"x"$x_new"+"$y_o"+"$x_o" $1 c_$1 
	ps_shape=$ps_y
	ps_shape_2=$ps_x
fi

mogrify -resize ${ps_shape}x${ps_shape_2} c_$1

$pepp c_$1 $ps_shape $2 $4
mv c_$1 $4/

#mogrify -resize ${ps_shape}x${ps_shape_2}! $4/s_${ps_shape}_c_$1
mogrify -resize x${ps_shape_2} $4/s_${ps_shape}_c_$1

m_size=`identify $4/s_${ps_shape}_c_$1|cut -d" " -f3`
m_size_x=`echo $m_size |cut -d"x" -f1`
m_size_y=`echo $original_size |cut -d"x" -f2`

if(($m_size_x < $ps_shape));then 
	dlt=`echo " ( $ps_shape - $m_size_x ) / 2 "|bc`
	convert -mattecolor "#000000" -frame ${dlt}x0 $4/s_${ps_shape}_c_$1 $4/s_${ps_shape}_c_$1
else 
	dlt=`echo " ( $m_size_x - $ps_shape ) / 2 "|bc`
	dlt=`echo "scale=8;$dlt * $ps_shape_2 / $ps_shape"|bc`
	dlt=`echo $dlt|cut -d"." -f1`
	convert -mattecolor "#000000" -frame 0x${dlt} $4/s_${ps_shape}_c_$1 $4/s_${ps_shape}_c_$1
	mogrify -resize x${ps_shape_2} $4/s_${ps_shape}_c_$1
fi
