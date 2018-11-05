# FIX YOUR MP4 FILE FOR FREE WITH PERL OPENSOURCE TOOL WET ULTIMATE SOLUTION

## What it is?

This utility is designed to recover broken / deleted / unfinished files mp4 / mov / 3gp, inside of which was h264 video. In principle, it can work with AVI, MKV, M4V and other containers, but sound restoration can be harder.

If you shoot a video on a camera, phone, action camera, record video from the screen or from drones, then it is possible that this utility will be useful to you. If your drone crashes into a tree at high speed and you want to try to pull out the last half second of video, then this utility can also help. Sometimes from nothing you can get additional frames.

## What is needed?

To restore the files you need:
1. The broken files or images of the card / flash drive / disk where the video was recorded
2. A new (SEPARATE) disk with sufficient free space.
3. A machine running `Linux` or `Windows`, `perl`, `ffmpeg` / `ffprobe` / `ffplay`
4. To restore aac-sound, you need `faad2` (libfaad-dev package) + `gcc` (to compile `aacfixer` utility)
5. Sample of good recorded file. The file must be written with the same settings on the same device as the corrupted file.

## How to use it?

1. If you have a deleted video / not finalized / there was an emergency shutdown, first get an image from it using the winhex utility or similar. You can also try to recover files, but you can lost few seconds. Linux users can point the card directly, like /dev/sdX, but having a backup when restoring data is always a good idea.
2. Take the old video file or shoot a new video that will be recorded under the same conditions as the one being restored. Be sure to record it exactly under the same conditions, including even shaking on the screen (same bitrate), if it was - so we will find exactly what we are looking for. The length of the video is 20 seconds, but if you feed more - it's ok.
3. You need to run:

```                   perl fixer.pl <good_file.mp4> <bad_file.mp4> <output_prefix>```

## How it works?

To begin, intermediate files are created:

* `*-headers.aac` - the file that you will need later to restore the sound
* `*-headers.h264` - the video file that will be used to create headers
* `*-nals.txt` - temporary file, with reference video packets. Under Windows 7, this file is created long for an unknown reason to me. This file is needed to "learn" the features of the encoding of the sample file
* `*-nals-stat.txt` is what we "learned". If something goes wrong - send this file.
* `*-stat.mp4` - temporary file, actually a copy of the sample file, only without sound, cropped up to 20 seconds.

At the very end of the work will be created:

* `*-out-video.h264` - restored video
* `*-out-audio.raw` - the restored audio. To be precise - just what was between the video.

All files will be created in the current directory, from where you run the script.

You can take any player, for example ffplay and play `*-out-video.h264`, but with sound it will be a bit more complicated.

## About restoring sound:

Different video cameras can write sound differently. At a minimum, it can be in different formats.

1. If the sound was in mp3 format, then you can simply rename *-out-audio.raw to file.mp3 and open it with any player.
2. If the sound was in PCM format (and its subspecies, such as ULAW), as some Sony video cameras do, then you can easily save it if you convert it to WAV by typing something like:

```ffmpeg -f s16le -ar 48000 -ac 2 -i somefile-out-audio.raw -c copy output.wav```

Of course, you will need to choose the parameters for your device.
3. If the audio was in AAC format, as the most popular version, then we compile the attached utility:

`                    gcc aac.c -L. -lfaad -lm -o aacfixer`

(assuming that you compiled the faad2 library and put the files libfaad.a and neaacdec.h in the current directory)

Now run:

```                  ./aacfixer somefile-headers.aac somefile-out-audio.raw```

And after a while the files will appear:

* `<prefix>-pure.wav` - is what was decoded
* `<prefix>-pure-adts.aac` - similarly, only without recoding

Bruteforce is used for recovering sound, so the operation can be slow.

## If something went wrong:

Remember that this code was written for my internal needs in just 3 days and is not required to work in all cases. In addition to these three days, I spent another week writing this text, because if something does not work, then do not worry much. If you do not succeed, create an issue and do the following:

* Upload a reference file somewhere, lasting from 10 to 20 seconds. Use services like GoogleDrive or DropBox. Do not send it to the mail or to services where there are no direct links for download, such as mega.co.nz
* Upload sample of broken file, size not more than 50 megabytes
* Describe the model of the device on which this file was recorded or the name of the programs after which it was created. Was it restored or just copied from the device.
* What happened (the drone flew into a tree, free space ran out, an emergency shutdown)
* On which system did you try to run this utility and what went wrong

The code was written to work on as many platforms as possible, do not depend on binaries and be as simple as possible, so its effectiveness was not the goal. Again, I only spent 3 days writing this code.

## Money money money

If for some reason you want to give me money, you can do it through:

* Bitcoin: 1bU17VMyvxYfCN257AiHrPPca1bszuLna
* Ether: 0x39b64f347b7702ddb1f8B06A25575598d624b783

Remember that I am unemployed and I really need money. If you make a money transfer, then I can use my data recovery superpowers and help you with a vengeance. However, the strength depends on the amount of money.

## Users of the latest GoPro, Xiao / Xiaomi Yi 4k and some drones

These video cameras are built on Ambarella chipsets and have almost the same stuffing. For example, my Yi4k is built on the Ambarella A9SE chipset and like GoPro, it also writes an additional preview along with the main stream. This preview is used for the mobile application. Inside the firmware there are still rudiments of the video editor, it not visible to the user, probably it will be used in future versions. This leads to the fact that 2 different files are written simultaneously and are mixed on the card itself. And if it is restored as one piece, then at the output we get a lot of broken segments. Do not try to restore such data with regular data recovery software like R-Studio, they will be broken! If you want to try your luck, then take the whole image and experiment on it.

Fortunately, as the owner of such a video camera, I can experiment a lot with it and with different recording modes. And I'm an expert in file systems, so I'm going to release a utility for low-level work with a flash card. Below is a screenshot of this utility, one day it will unmistakably restore files. But not now. While I do not have enough motivation to complete the project, so let it be just a small preview.

![Direct Disk View (ClusterView)](clusterview.png?raw=true)

## Other tools:

I decided to look for other utilities and compete with them. Yes, it's been written more for fun, but if I can compete with the professional tools?

I wrote a primitive script that read random pieces from a file and then combined them together. You can also try it, it's called montage.pl, because it practically allows you to video editing in binary form! Of course, after such a "video editing", the files will be unusable, but is it possible to restore them?

To my great surprise, many commercial utilities could not do anything, they could not even explain what they not like, and open source, such as untrunc, required some effort and patching to simply compile them, but still did not work. But let's not talk about the bad. Then there will be those things that gave at least some result:

* mp4repair.org - data recovery service. Usually I ignore such services, but this service surprised me. It's not only able to show previews for the broken file, but did not even require a reference file for this, and everything was done right in the browser! However, the price is high. Unfortunately, they told me that it is better not to restore my test file, that it will be very expensive. This really disappointed me. I tried to correspond with technical support, but unfortunately, I did not achieve anything, so I can not recommend them.
* http://slydiman.me/eng/mmedia/recover_mp4.htm - the result is almost like mine, only in the mp4 container, which in theory, should better recover the synchronization of audio and video. I could not play the result in VLC, but ffplay showed me an almost similar picture that I have. However, the author does not post new versions and seems to have decided to monetize his project. I knew about this project before writing my own. Not open source, which was the reason for creating my project.

Unfortunately, as we see, the choice is not great. And with the publication of this project, the choice has become wider!

## Contact the author

If for some reason you want to write to me personally, then write to the mail formp4review@airmail.cc
This is not my primary email, so do not expect an early reply. You can create an issue with the text "check mail".

If your question concerns the production of video in general, then it is better to ask it here:
https://video.stackexchange.com is a small but very good video production community

## Greetings:

A huge thanks to the participants stackoverflow: szatmary, Mulvya, VC.One.
Slydiman, for not implementing my feature requests and not publishing source code.
And also to sufferers with SJCAM from our conference, which motivated me to do this!

## License:

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.



---------------------------------------------------------------------------



## Что это такое?

Эта утилита предназначена для восстановления битых / удаленных / недописанных файлов mp4 / mov / 3gp, внутри которых было h264 видео. В принципе, может работать с AVI, MKV, M4V и другими контейнерами, но восстановление звука может быть осложнено.

Если вы снимаете видео на фотоаппарат, телефон, видеокамеру, записываете видео с экрана или с дронов, то возможно, что данная утилита вам пригодиться. Если ваш дрон впечатался в дерево на большой скорости и вы хотите попробовать вытащить последние полсекунды видео, то эта утилита тоже может помочь. Иногда из небытия можно достать дополнительные кадры.

## Что потребуется?

Для восстановления работоспособности файлов нам нужно:
1. Битые файлы или образы карточки/флешки/диска, куда было записано видео
2. Новый (ОТДЕЛЬНЫЙ) диск с достаточным объемом свободного места.
3. Машина под управлением Linux или Windows, perl, ffmpeg/ffprobe/ffplay
4. Для восстановления aac-звука нужен будет faad2 + gcc
5. Образец исправного файла. Файл должен быть записан с теми же настройками на том же устройстве, что и поврежденный файл.

## Как это использовать?

1. Если у вас видео было записано на sdcard и удалено/не финализировано/было аварийное отлючение, то для начала снимите с нее образ при помощи утилиты winhex или ей подобной. Вы конечно можете попытаться восстановить файлы, но вы можете потерять несколько секунд. Пользователи Linux могут указать карту напрямую, как /dev/sdX, однако иметь резервную копию при восстановлении данных - это всегда хорошая идея.
2. Возьмите старый или снимите новый видеоролик, который будет записан при тех же условиях, что и восстанавливаемый. Обязательно записывать его ровно при тех же условиях, включая даже тряску на экране, если она была - так мы найдем ровно то, что ищем. Длительность ролика 20 секунд, но если скормить больше - ничего страшного.
3. Нужно запустить

```              perl fixer.pl <good_file.mp4> <bad_file.mp4> <output_prefix>```

## Как это работает?

Для начала создаются промежуточные файлы:

* `*-headers.aac` - файл, который понадобится для восстановления звука
* `*-headers.h264` - файл видео, который будет использован для создания заголовков
* `*-nals.txt` - временный файл, внутри которого будут разобраны пакеты. Под Windows 7 этот файл создается долго по неизвестной мне причине. Этот файл нужен, чтобы "научиться" особенностям кодирования файла-образца
* `*-nals-stat.txt` - это то, чему мы "научились". Если что-то пойдет не так - пришлите этот файл.
* `*-stat.mp4` - временный файл, фактически копия файла-образца, только без звука, обрезанная до 20 секунд.

В самом конце работы будут созданы:

* `*-out-video.h264` - восстановленное видео
* `*-out-audio.raw` - восстановленное аудио. Если быть точным - только то, что было между видео.

Все файлы будут создаты в текущей директории, откуда вы запускаете скрипт.

Вы можете взять любой плеер, например `ffplay` и проиграть `*-out-video.h264`, а вот со звуком будет немного сложнее.

## О восстановлении звука:

Разные видеокамеры по разному могут писать звук. Как минимум, он может быть в разных форматах.

1. Если звук был в формате mp3, то вы можете просто переименовать *-out-audio.raw в file.mp3 и открыть его любым плеером.
2. Если звук был в формате PCM (и его подвидах, таких как ULAW), как это делают некоторые видеокамеры от Sony, то вы легко можете спасти его, если сконвертируете его в WAV, введя что-то вроде:
ffmpeg -f s16le -ar 48000 -ac 2 -i somefile-out-audio.raw -c copy output.wav
Конечно, вам нужно будет подобрать параметры для своего устройства.
3. Если звук был в формате AAC, как самый популярный вариант, то компилируем прилагаемую утилиту:

```                 gcc aac.c -L. -lfaad -lm -o aacfixer```

(предполагается, что вы скомпилировали библиотеку faad2 и положили файлы libfaad.a и neaacdec.h в текущую директорию)

Теперь запускаем:

```                  ./aacfixer somefile-headers.aac somefile-out-audio.raw```

И после некоторого времени появятся файлы:

* `<prefix>-pure.wav` - то, что удалось декодировать.
* `<prefix>-pure-adts.aac` - аналогично, только без перекодирования

При восстановлении звука используется брутфорс, потому быстро не будет.

## Если что-то пошло не так:

Помните, что данный код был написан для своих внутренних нужд всего за 3 дня и не обязан работать во всех случаях. В дополнении в этим трем дням я потратил еще неделю, чтобы написать этот текст, потому если что-то не работает, то не надо сильно переживать Если у вас что-то не получается, то создайте issue и сделайте следующее:

* Выложите куда-то файл-образец, длительностью от 10 до 20 секунд. Выкладывайте на сервисы вроде GoogleDrive или DropBox. Не надо присылать это в почте или заливать на сервисы, где нет прямых ссылок, такие как mega.co.nz
* Выложите образец битого файла, весом не более 50 мегабайт
* Опишите модель устройства на котором был записан данный файл или название программ, после которых он появился. Был ли он восстановлен или просто скопирован с устройства.
* Что случилось (дрон влетел в дерево, кончилось место, аварийное отключение)
* На какой системе вы пытались запускать эту утилиту и что пошло не так

Код был написан так, чтобы работать на как можно большем количестве платформ, не зависеть от бинарных сборок и быть как можно проще, поэтому его эффективность не являлась целью. Опять же, на написание этого кода я потратил всего 3 дня.

## Деньги-деньги-деньги

Если по какой-то причине вы хотите мне дать денег, то можете сделать это через:

* Bitcoin: 1bU17VMyvxYfCN257AiHrPPca1bszuLna
* Ether: 0x39b64f347b7702ddb1f8B06A25575598d624b783

Помните, что я безработный и деньги мне очень нужны. Если вы сделаете денежный перевод, то я смогу воспользоваться своей магией восстановления данных и помочь вам с удвоенной силой. Впрочем, сила зависит от денежной суммы.

## Пользователям последних GoPro, Xiao / Xiaomi Yi 4k и некоторых дронов

Данные видеокамеры построены на чипсетах от Ambarella и имеют почти одинаковую начинку. К примеру, моя Yi4k построена на чипсете Ambarella A9SE и как и GoPro, она пишет вместе с основным потоком еще и дополнительное превью. Это превью используется для мобильного приложения. Внутри прошивки есть еще зачатки видеоредактора, но пользователю они не видны, вероятно это будет в будущих версиях. Это приводит к тому, что 2 разных файла пишутся одновременно и перемешиваются на самой карточке. И если это восстановить как один кусок, то на выходе у нас получается много битых сегментов. Не пытайтесь восстанавливать такие данные обычными программами вроде R-Studio, они будут битыми! Если вы хотите попытать счастья, то снимите образ целиком и экспериментируйте уже над ним.

К счастью, как обладатель такой видеокамеры, я могу много экспериментироваться с ней и с разными режимами записи. А еще я являюсь экспертом в области файловых систем, поэтому собираюсь выпустить утилиту для низкоуровневой работы с флеш-картой. Ниже представлен скриншот этой утилиты, однажды она будет безошибочно восстанавливать файлы. Но не сейчас. Пока у меня нет достаточной мотивации для завершения проекта, поэтому пусть это будет лишь маленьким превью.

![Direct Disk View (ClusterView)](clusterview.png?raw=true)

## Другие утилиты:

Я решил поискать другие утилиты и посоревноваться с ними. Да, это все было написано скорее для забавы, но смогу ли я тягаться с профессиональными средствами?

Мной был написан примитивный скрипт, который читал случайные куски из файла и потом склеивал их вместе. Вы тоже можете попробовать, он называется montage.pl, так как практически позволяет монтировать видеофайлы! Конечно, такую нарезку проиграть невозможно, но можно ли ее восстановить?

К моему великому удивлению, многие коммерческие утилиты не смогли абсолютно ничего, даже просто объяснить, что им не нравится, а опенсорсные, такие как untrunc, потребовали определенных усилий и патчинга, чтобы их просто собрать, но все равно не заработали. Но не будем о плохом. Далее будут те вещи, которые дали хоть какой-то результат:

* mp4repair.org - сервис по восстановлению данных. Обычно я обхожу стороной такие сервисы, но этот сервис меня удивил. Он не только смог показать превью для битого файла, но даже не потребовал референсного файла для этого, а сделано было все прямо в браузере! Впрочем, цена высока. К сожалению, мне написали, что мой тестовый файл лучше не восстанавливать, что это будет очень дорого, а на последующие письма просто не ответили. Это очень меня разочаровало. Я пытался переписываться с техподдержкой, но к сожалению, так и не добился ничего, так что я не могу рекомендовать их.
* http://slydiman.me/eng/mmedia/recover_mp4.htm - результат практически как у меня, только в mp4 контейнере, что в теории, должно лучше сказаться на синхронизации аудио и видео. Я не смог проиграть результат в VLC, но ffplay показал мне почти аналогичную картинку, что и у меня. Правда автор не выкладывает новые версии и похоже, решил монетизировать свой проект. О этом проекте я знал еще до написания собственного. Не опенсорс, что и было причиной создания моего проекта.

Увы, как мы видим, выбор не велик. И с публикацией этого проекта, выбор стал шире!

## Написать автору

Если по какой-то причине вы хотите написать мне лично, то пишите на почту formp4review@airmail.cc
Это не основной мой емейл, потому не ждите скорого ответа. Вы можете создать issue с текстом "проверь почту".

Если же ваш вопрос касается производства видео в целом, то лучше задайте его тут:
https://video.stackexchange.com - маленькое, но очень хорошее сообщество по производству видео

## Приветы:

Огромная благодарность участникам stackoverflow: szatmary, Mulvya, VC.One.
Slydiman, за нереализацию моих фич-реквестов и не публикацию исходников.
А так же страдальцам с SJCAM из нашей конференции, которые сподвигли меня на это!

## Лицензия:

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

