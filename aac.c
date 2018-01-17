//
//    aac.c - this tool for fix broken aac files after fixer.pl
//    Copyright (c) 2017, BukkoJot
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "neaacdec.h"

// todo:

// +remove clicks at errors
// +stream reading
// split stream on errors
// +add wave header to pcm
// option to enable/disable pcm header

#pragma pack(1)
typedef struct{
uint32_t riff_id;
uint32_t riff_size;
uint32_t wave_id;
uint32_t fmt_id;
uint32_t fmt_size;
uint16_t format;
uint16_t channels;
uint32_t samplerate;
uint32_t byterate;
uint16_t block_align;
uint16_t bit_per_sample;
uint32_t data_id;
uint32_t data_size;
} RIFF_HEADER;

int main(int argc, char **argv){

printf("    This program is free software: you can redistribute it and/or modify\n");
printf("    it under the terms of the GNU General Public License as published by\n");
printf("    the Free Software Foundation, either version 3 of the License, or\n");
printf("    (at your option) any later version.\n");
printf("\n");
printf("    This program is distributed in the hope that it will be useful,\n");
printf("    but WITHOUT ANY WARRANTY; without even the implied warranty of\n");
printf("    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n");
printf("    GNU General Public License for more details.\n\n");

if(argc<3){
printf("Usage:\n%s: <good_file.aac> <bad_file.aac>\n\n",argv[0]);
}

FILE *puru=fopen(argv[1],"rb");
FILE *pure=fopen(argv[2],"rb");

char *filename=malloc(strlen(argv[2])+20);
sprintf(filename,"%s-pure.wav",argv[2]);
FILE *out_pcm=fopen(filename,"wb");
sprintf(filename,"%s-pure-adts.aac",argv[2]);
FILE *out_aac=fopen(filename,"wb");
free(filename);

int blocksize=1000000000;

uint8_t *buf=malloc(blocksize);
uint8_t *tmp=malloc(100000); // 8192+7
uint8_t *good_aac=malloc(10000);
int16_t *good_pcm=malloc(100000);
uint8_t *buf_start=buf;
uint8_t adts[7];
fread(adts,1,7,puru);
int good_aac_size=0;
int good_pcm_size=0;

int last_time=time(NULL);

long samplerate=0;
uint8_t channels=0;
NeAACDecFrameInfo frame;
signed short *samples;

NeAACDecHandle h=NeAACDecOpen();
NeAACDecInit(h,adts,7,&samplerate,&channels);
printf("Using parameters:\nsamplerate:%d, channels:%d\n",(int)samplerate,(int)channels);

RIFF_HEADER header={
0x46464952,
0xFFFFFFFF,
0x45564157,
0x20746d66,
16,
1,
channels,
(int)samplerate,
(int)samplerate*channels*2,
channels*2,
16,
0x61746164,
0xFFFFFFFF
};

fwrite(&header,1,sizeof(header),out_pcm);

static uid=0;

int size=0;


while(1){
if(size<0){break;}

if(size<8192 && !feof(pure)){
if(size){
memmove(buf_start,buf,size);
}
buf=buf_start;
int read=fread(buf+size,1,blocksize-size,pure);
size+=read;
}
if(size<=0){break;}

int ss=8192; // max packet size
if(ss>size){ss=size;} // I care, lol
memcpy(tmp,adts,7);
tmp[3]=(tmp[3]&0xFC) | (ss>>11);
tmp[4]=ss>>3;
tmp[5]=(tmp[5]&0x1F) | (ss<<5);
memcpy(tmp+7,buf,ss);

samples=NeAACDecDecode(h,&frame,tmp,ss+7);

if(frame.bytesconsumed>0){

if(frame.bytesconsumed>30){ // minimal size of "good" frame
if(frame.samples>0){
if(good_pcm_size){
fwrite(good_pcm,2,good_pcm_size,out_pcm);
fflush(out_pcm);
}
good_pcm_size=frame.samples;
memcpy(good_pcm,samples,frame.samples*2);
}

ss=frame.bytesconsumed;
memcpy(tmp,adts,7);
tmp[3]=(tmp[3]&0xFC) | (ss>>11);
tmp[4]=ss>>3;
tmp[5]=(tmp[5]&0x1F) | (ss<<5);

printf("Consumed %d, got samples: %d, %d bytes remain\n",(int)frame.bytesconsumed,(int)frame.samples,size);


if(good_aac_size){
fwrite(good_aac,1,good_aac_size,out_aac);
}
good_aac_size=ss;
memcpy(good_aac,tmp,ss);
}

buf+=frame.bytesconsumed-7;
size-=frame.bytesconsumed-7;

} else {

good_aac_size=0;
//good_pcm_size=0;
int now=time(NULL);
if(now-last_time){
printf("Consumed 0, position:%d\n",(int)ftell(pure)-size);
last_time=now;
}
NeAACDecClose(h);
NeAACDecHandle h=NeAACDecOpen();
NeAACDecInit(h,adts,7,&samplerate,&channels);

buf++;
size--;
if(size<=0){
break;
}
}
}

fclose(puru);
fclose(pure);
fclose(out_pcm);
fclose(out_aac);
NeAACDecClose(h);
free(tmp);
free(buf_start);
free(good_pcm);
free(good_aac);


printf("Completed\n");

return EXIT_SUCCESS;
}
