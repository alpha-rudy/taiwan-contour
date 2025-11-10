## Taiwan Contour Map Making

## Usage

    $ make all   ### to make the default targets

    History: 
    * taiwan-contour-2025:
      * 台灣本島(taiwan)、蘭嶼(lanyu)、琉球(liuqiu): MOI DLA v2025 20m
      * 龜山島(guishan)、綠島(ludao): MOI DLA v2020 20m
      * 澎湖群島(penghu): MOI DLA v2025 20m
      * 金門群島(kinmen): MOI DLA v2025 20m
      * 樂山基地(leshan): MOI DLA v2016 20m
      * 馬祖(matsu)、烏坵(wuqiu)、北方三島(n3islets): JAXA AW3D30 v4.1
    * taiwan-contour-2024:
      * 台灣本島: MOI DLA v2024 20m
      * 蘭嶼: MOI DLA v2024 20m
      * 龜山島、琉球、綠島: MOI DLA v2020 20m
      * 澎湖群島: MOI DLA v2019 20m
      * 金門群島: MOI DLA v2019 20m
      * 樂山基地: MOI DLA v2016 20m
      * 馬祖、烏坵、北方三島: JAXA AW3D30 v4.1
    * taiwan-contour-2023r2:
      * 台灣本島: MOI DLA v2022 20m
      * 近海四島: MOI DLA v2020 20m
      * 澎湖群島: MOI DLA v2019 20m
      * 金門群島: MOI DLA v2019 20m
      * 樂山基地: MOI DLA v2016 20m
      * 馬祖、烏坵、北方三島: JAXA AW3D30 v3.1
    * taiwan-contour-2023:
      * 台灣本島: MOI DLA v2022 20m
      * 樂山基地: MOI DLA v2016 20m
      * 澎湖群島: MOI DLA v2019 20m
      * 金門群島: MOI DLA v2019 20m
      * 馬祖、烏坵、北方三島: JAXA AW3D30 v3.1
    * taiwan-contour-2021:
      * 台灣本島: MOI DLA v2020 20m
      * 樂山基地: MOI DLA v2016 20m
      * 澎湖群島: MOI DLA v2019 20m
      * 金門群島: MOI DLA v2019 20m
      * 馬祖、烏坵、北方三島: JAXA AW3D30 v3.1
    * taiwan-contour-2020:
      * 台灣本島: MOI DLA v2020 20m
      * 樂山基地: MOI DLA v2016 20m
      * 澎湖群島: MOI DLA v2019 20m
      * 金門群島: MOI DLA v2019 20m
      * 馬祖、烏坵、北方三島: JAXA AW3D30 v2.1
    * taiwan-contour-2019:
      * 台灣本島: MOI DLA v2019 20m
      * 樂山基地: MOI DLA v2016 20m
      * 澎湖群島: MOI DLA v2019 20m
      * 金門群島: MOI DLA v2019 20m
      * 馬祖、烏坵、北方三島: JAXA AW3D30 v2.1
    * taiwan-contour-2018:
      * 台灣本島: MOI DLA v2018 20m
      * 樂山基地: MOI DLA v2016 20m
      * 澎湖群島: MOI DLA v2016 20m
      * 金門、馬祖、烏坵、北方三島: JAXA AW3D30 v2.1
    * taiwan-contour-2017: (手工製作)
      * 台灣本島: MOI DLA v2016 20m
      * 樂山基地: MOI DLA v2016 20m
      * 澎湖群島: MOI DLA v2016 20m
      * 金門、馬祖、烏坵、北方三島: NASA SRTM90 v3.0

## Target list

* `taiwan-contour`
  * use MOI DLA Taiwan DTM v2020 20m
  * Taiwan contour lines in 10/100/500 scale
  * Regions of DTM
    * MOI DLA Taiwan DTM v2020 20m
      * taiwan island
    * MOI Taiwan DTM v2019 20m
      * penghu island
      * kinmen island
    * MOI Taiwan DTM v2016 20m
      * yaoshan
    * JAXA AW3D30 v3.1
      * matsu island
      * wuqiu island
      * n3islets

* `taiwan-contour-mix`
  * use MOI Taiwan DTM 20m v2020
  * taiwan contour lines in 10/50/100/500 scale
  * marker line for the lable of elevation

* `taiwan-lite-contour-mix`
  * use MOI Taiwan DTM 20m v2020
  * taiwan contour lines in 20/100/500 scale
  * marker line for the lable of elevation

* `taiwan-contour-2020`
  * use MOI DLA Taiwan DTM v2020 20m
  * Taiwan contour lines in 10/100/500 scale
  * Regions of DTM
    * MOI DLA Taiwan DTM v2020 20m
      * taiwan island
    * MOI Taiwan DTM v2019 20m
      * penghu island
      * kinmen island
    * MOI Taiwan DTM v2016 20m
      * yaoshan
    * JAXA AW3D30 v2.1
      * matsu island
      * wuqiu island
      * n3islets

* `taiwan-contour-2019`
  * use MOI Taiwan DTM v2019 20m
  * taiwan contour lines in 10/100/500 scale
  * Regions of DTM
    * MOI Taiwan DTM v2019 20m
      * taiwan island
      * penghu island
      * kinmen island
    * MOI Taiwan DTM v2016 20m
      * yaoshan
    * JAXA AW3D30 v2.1
      * matsu island
      * wuqiu island
      * n3islets

* `taiwan-contour-2018`
  * use MOI Taiwan DTM 20m v2018
  * taiwan contour lines in 10/100/500 scale
  * Regions of DTM
    * MOI Taiwan DTM 20m v2018
      * taiwan island
    * MOI Taiwan DTM 20m v2016
      * penghu island
      * 樂山基地
      * 台灣近海島嶼
    * JAXA AW3D30
      * kinmen
      * matsu

* `taiwan-contour-mix-2018`
  * use MOI Taiwan DTM 20m v2018
  * taiwan contour lines in 10/50/100/500 scale
  * marker line for the lable of elevation

* `taiwan-lite-contour-mix`
  * use MOI Taiwan DTM 20m v2018
  * taiwan contour lines in 20/100/500 scale
  * marker line for the lable of elevation


## Copyright and Distribution
<pre>
Copyright (c) 2019~2021 Rudy Chung
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the this copyright notice
    (or the HTTP link to this notice), this list of conditions and the
    following disclaimer in the documentation and/or other materials provided
    with the distribution.

    * Redistributions with modification must use a different map name which
    could be easily and clearly to be distinguished with this map.

    * Neither the name of Rudy Chung nor the names of its contributors may be
    used to endorse or promote products derived from this software without 
    specific prior written permission.

THIS MAP IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL RUDY BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
MAP, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
</pre>
