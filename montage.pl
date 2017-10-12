#!/usr/bin/perl

$block=2000000; # size of block
$block_count=35; # how many pieces you want

# change files paths
open(dd,"some_good_pron.mp4");
open(oo,">montage2.bad");

binmode(dd);
binmode(oo);

$size=-s(dd);

for($q=0;$q<$block_count;$q++){
seek(dd,rand()*($size-$block),0);
read(dd,$file,$block);
print oo $file;
}

close(oo);
close(dd);
