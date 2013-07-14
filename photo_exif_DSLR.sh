#!/bin/bash 
#A command-line tool for adding borders with exif information and watermarks for DSLR photos, 
#it's a part of APBC, version 1.0
#Author:realasking
#2013-07-14


if [ ! -d "$4" ];then
mkdir $4
fi 

fact_left_right_bottom=0.044757033
fact_top=0.02557545
fact_white_line=0.003836317
fact_bottom_font_width=0.02685421994
fact_bottom_font_left_width=0.026672634271
fact_date_place=0.6043719412724307
#修正因字体引起的作者位置无法对齐
fact_scale_bottom_info_fonts_size=0.8
fact_scale_date_position=1.2
fact_scale_author_position=1.01
#1.04
author_place_fix=42
author_size=`expr length $3`
fact_author_place=`echo "scale=8;( 613 - ( ( 3 + $author_size + $author_place_fix ) * 0.18838499184339316 ) ) / 613"|bc`
fact_author_place=`echo 0"$fact_author_place"`
#echo $fact_author_place
fact_watermark_font_width=0.04
fact_watermark_font_width_px=0.0175
#fact_watermark_X_place=0.3625
#这一项是针对Y的
fact_watermark_Y_place=0.22
fact_watermark_frame_X=0.0165
fact_watermark_frame_Y=0.0075
fact_watermark_X_place=`echo "scale=12;( ( 9 + $author_size ) * $fact_watermark_font_width_px ) + ( 2 * $fact_watermark_frame_X )"|bc`

WFONT="/usr/local/share/fonts/u/urw_chancery_l_medium_italic.ttf"
#FONT="方正细黑一_GBK"
FONT="文泉驿点阵正黑"

Machine="Olympus E-pl1"
LENS=`exiftool $1|grep "Lens ID"|cut -d ":" -f2`
Aperture=`exiv2 $1 |grep "Aperture        : "|awk '{print $3}'`
Shutter_speed=`exiv2 $1|grep "Exposure time"|awk '{print $4}'`
ISO=`exiv2 $1|grep "ISO speed       : "|awk '{print $4}'`
Exposure_bias=`exiv2 $1|grep "Exposure bias   : "|awk '{print $4}'`
Focal_length=`exiv2 $1|grep "Focal length    : "|awk '{print $4,$5}'`
Photo_Date=`exiv2 $1|grep "Image timestamp : "|cut -d" " -f4|sed "s/:/-/g"`

convert -resize $2 $1 tmp.jpg

#不能处理空格
converted_size=`identify tmp.jpg|cut -d" " -f3`
converted_pic_width=`echo $converted_size |cut -d"x" -f1`
converted_pic_height=`echo $converted_size |cut -d"x" -f2`

watermark_X=`echo "$fact_watermark_X_place * $converted_pic_width"|bc|cut -d"." -f1`
watermark_Y=`echo "$fact_watermark_Y_place * $converted_pic_height"|bc|cut -d"." -f1`
watermark_font_pt=`echo "$fact_watermark_font_width * $converted_pic_width"|bc|cut -d"." -f1`
watermark_frame_X=`echo "$fact_watermark_frame_X * $converted_pic_width"|bc|cut -d"." -f1`
watermark_frame_Y=`echo "$fact_watermark_frame_Y * $converted_pic_width"|bc|cut -d"." -f1`

#生成水印
convert -font $WFONT -pointsize $watermark_font_pt -gravity center label:"Photo by $3" wk.jpg
convert -mattecolor "#FFFFFF" -frame ${watermark_frame_X}x${watermark_frame_Y} -negate wk.jpg wk.jpg 
wts=`identify wk.jpg|cut -d" " -f3`
wtx=`echo $wts |cut -d"x" -f1`
wty=`echo $wts |cut -d"x" -f2`
wtyy=`echo "$wty / 2"|bc`

WX=`echo "$watermark_frame_X + $watermark_X"|bc`

echo "#!/bin/bash">>tmp.sh
posxf=`echo "scale=8;$converted_pic_width * 1 / 640"|bc`
posx=`echo ${posx}|cut -d"." -f1`
if((posx==0));then posx=1;fi
posxx=`echo "$posxf * 2"|bc|cut -d"." -f1`
posxxx=`echo "$posxf * 3"|bc|cut -d"." -f1`
watermark_Y_=`echo "$wtyy - $posx"|bc`
watermark_Y__=`echo "$watermark_Y_ - $posx"|bc`
echo "convert tmp.jpg tmp.png">>tmp.sh
echo "convert -size ${wtx}x${wty} xc:black -font $WFONT -pointsize $watermark_font_pt  -fill white -annotate +$posx+$wtyy  \"Photo by $3\" -fill white  -annotate +$posxxx+$watermark_Y__ \"Photo by $3\" -fill black  -annotate +$posxx+$watermark_Y_  \"Photo by $3\" mask.jpg">>tmp.sh
echo "convert -size ${wtx}x${wty} xc:transparent -font $WFONT -pointsize $watermark_font_pt  -fill black  -annotate +$posx+$wtyy \"Photo by $3\" -fill white  -annotate  +$posxxx+$watermark_Y__ \"Photo by $3\" -fill transparent  -annotate  +$posxx+$watermark_Y_  \"Photo by $3\" trans.png">>tmp.sh
echo "composite  -compose CopyOpacity mask.jpg trans.png watermark.png">>tmp.sh
echo "composite -gravity south  -geometry +$watermark_X+$watermark_Y watermark.png tmp.png tmp.png">>tmp.sh
echo "convert tmp.png tmp.jpg">>tmp.sh 
echo "rm tmp.png">>tmp.sh
sh tmp.sh 
rm tmp.sh tmp2.jpg mask.jpg trans.png watermark.png wk.jpg


bottom_font_pt=`echo "$fact_scale_bottom_info_fonts_size * $fact_bottom_font_width * $converted_pic_width * 72.0 / 96.0"|bc|cut -d"." -f1`
bottom_font_left_width=`echo "$fact_bottom_font_left_width * $converted_pic_width"|bc|cut -d"." -f1`

white_line_width=`echo "$fact_white_line * $converted_pic_width"|bc|cut -d"." -f1`
width_of_left_right_bottom=`echo "$fact_left_right_bottom * $converted_pic_width"|bc|cut -d"." -f1`
width_of_top=`echo "$fact_top * $converted_pic_width"|bc|cut -d"." -f1`
date_X=`echo "$fact_scale_date_position * $fact_date_place * $converted_pic_width"|bc|cut -d"." -f1`
author_X=`echo "$fact_author_place * $converted_pic_width"|bc|cut -d"." -f1`

info_write_Y_place=`echo "$converted_pic_height + $width_of_left_right_bottom + $white_line_width + $white_line_width + $bottom_font_left_width"|bc|cut -d"." -f1`
info_write_X_place=`echo "$width_of_left_right_bottom + $white_line_width"|bc|cut -d"." -f1`
author_write_X_place=`echo "$fact_scale_author_position * ( $author_X - $width_of_left_right_bottom - $white_line_width )"|bc|cut -d"." -f1`
date_write_X_place=`echo "$date_X + $width_of_left_right_bottom + $white_line_width"|bc|cut -d"." -f1`

width_of_top_crop=`echo "$width_of_left_right_bottom - $width_of_top"|bc`

convert -mattecolor "#FFFFFF" -frame "$white_line_width"x"$white_line_width" tmp.jpg tmp.jpg 
convert -mattecolor "#000000" -frame "$width_of_left_right_bottom"x"$width_of_left_right_bottom" tmp.jpg tmp.jpg 

#写入参数
CVMD="convert -encoding unicode -font $FONT -fill white -pointsize $bottom_font_pt -annotate"
$CVMD +$info_write_X_place+$info_write_Y_place "$Machine $LENS $Aperture ${Shutter_speed}s ISO$ISO Ev $Exposure_bias" tmp.jpg tmp.jpg 
$CVMD +$author_write_X_place+$info_write_Y_place "by $3" tmp.jpg tmp.jpg
$CVMD +$date_write_X_place+$info_write_Y_place "$Photo_Date" tmp.jpg tmp.jpg 

convert tmp.jpg -gravity North -chop 0x"$width_of_top_crop" tmp.jpg 

mv tmp.jpg $4/s_${converted_pic_width}_$1
