#!/usr/bin/perl

#
#    fixer.pl - this tool for fix broken video files with h264 and AVCC coding
#    Copyright (c) 2017, BukkoJot
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

use Data::Dumper;

my($ffmpeg,$ffprobe);

if($^O=~/win32/i){
$ffmpeg="ffmpeg.exe";
$ffprobe="ffprobe.exe";
} else {
$ffmpeg="ffmpeg";
$ffprobe="ffprobe";
}


if(@ARGV<3){
print "Usage:\n$0 <good_file.mp4> <bad_file.mp4> <output_prefix>\n";
exit(0);
}

my ($goodfile,$badfile,$outfile_prefix)=@ARGV;

my $sample_h264=$outfile_prefix."-headers.h264";
my $sample_stat_h264=$outfile_prefix."-stat.mp4";
my $sample_aac=$outfile_prefix."-headers.aac";
my $sample_nals=$outfile_prefix."-nals.txt";
my $sample_nals_stat=$outfile_prefix."-nals-stat.txt";
my $out_video=$outfile_prefix."-out-video.h264";
my $out_audio=$outfile_prefix."-out-audio.raw";

print "Build intemidiates...\n";
if(!-e($sample_h264)){`$ffmpeg -i "$goodfile" -c copy -frames 1 -bsf h264_mp4toannexb "$sample_h264"`;}
if(!-e($sample_stat_h264)){`$ffmpeg -i "$goodfile" -c copy -t 20 -an "$sample_stat_h264"`;}
if(!-e($sample_nals)){`$ffprobe -select_streams 0 -show_packets -show_data "$sample_stat_h264" > "$sample_nals"`;}
if(!-e($sample_aac)){`$ffmpeg -i "$goodfile" -c copy -t 1 -f adts "$sample_aac"`;}

print "Opening files...\n";
open(bfile,$badfile) or die "$badfile: $!";
open(vhead,$sample_h264);
open(nals,$sample_nals);
open(vout,">".$out_video) or die "$out_video: $!";
open(aout,">".$out_audio) or die "$out_audio: $!";
read(vhead,$header,0x100);
$header=~s/\x00\x00+\x01[\x65\x45\x25].+$//s;

binmode(vout);
binmode(aout);
binmode(bfile);
binmode(vhead);

# get nals
my $buf;
my $size;
my @nals=map{
{
min=>0xFFFFFF,
max=>0x0,
id=>$_
}
}(0..0b11111);
while(<nals>){
if(/^0.......: (.{40})/){
$buf.=$1;
next;
}
if(/^\[\/PACKET\]/ && $buf){
$buf=~s/[^0-9A-F]//igs;

while(1){
$size=hex(substr($buf,0,8));
print "NAL $size bytes, type: $type\n";
if(length($buf)>=$size*2+8){

$type=hex(substr($buf,8,2))&0b11111;
$bytes=pack("H*",substr($buf,8,$type==5?6:4));

$n=$nals[$type];
if($n->{min}>$size){ $n->{min}=$size;}
if($n->{max}<$size){ $n->{max}=$size;}
$n->{bytes}{$bytes}=1;
$n->{printbytes}{substr($buf,8,8)}=1;

$buf=substr($buf,8+$size*2);
} else {
last;
}
}

print "Remain ".length($buf).": ".substr($buf,0,32)."\n";
$buf="";


#$nals{$1.$2}=undef;
}

}

#print join("\n",keys %nals);
print Dumper(\@nals);
open(st,">".$sample_nals_stat);
print st Dumper(\@nals);
close(st);

##################################



#die;@nals{map{s/(..)/pack("C",hex($1))/eg;$_}split(/\n/,$nals)}=undef;


print vout $header;

$was_key=0;
# main loop
$shit="";

$fsize=-s(bfile);


$blocksize=10000000;

$file="";
while(1){
$fsize=read(bfile,$buf,$blocksize);
if($fsize==0){
last;
}
$file=$file.$buf;
$buf="";
$fsize=length($file)-10;

$stime=time();
for($q=0;$q<$fsize;){

my $size=unpack("N",substr($file,$q,4));
my $header=unpack("C",substr($file,$q+4,1));
my $zerobit=$header&0x80;
my $type=$header&0b11111;

if(time()!=$stime){
printf("testing at %.5x (of %.5x) gives us $size\n",tell(bfile)-$q,$fsize);
$stime=time();
}
if($size>0 && $zerobit==0 && $nals[$type]->{max}){
$nextbytes=substr($file,$q+4,$type==5?3:2);
$iskey=$type==5?1:0;

if(exists $nals[$type]->{bytes}{$nextbytes} && $size>=$nals[$type]->{min}/2 && $size <= $nals[$type]->{max}*2){
print "Got! $size bytes and ".length($shit)." shit\n";
if($ok){
print aout $shit;
}

#writing frame
$tail=length($file)-$q-4;
if($tail>$size){$tail=$size;}
$left=$size-$tail;


if($iskey || $was_key){
print vout "\x00\x00\x00\x01"; # signature
print vout substr($file,$q+4,$tail);
if($left){
read(bfile,$buf,$left);
print vout $buf;
$buf="";
}
$was_key=1;
} else {
# if very beginning and no key frames was yet - just skip this frames
if($left){
read(bfile,$buf,$left);
$buf="";
}
}
$shit="";
$ok++;
$q+=$size+4;
next;
}
}

$shit.=substr($file,$q,1);
$q++;

}

$file=substr($file,$q);

}

print `stat $out_video`;

