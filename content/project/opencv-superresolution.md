---
title: "OpenCVとPythonで深層学習モデルの超解像を手軽に試す"
date: 2020-12-24T12:20:04+09:00
draft: false
---

![](/img/opencv-superresolution_header.png)


## 概要
超解像とは、任意の画像を入力として解像度を上げた画像を出力するコンピュータービジョンのタスクです。近年の深層学習の発達により、より高精細で自然な超解像が可能になってきました。一方、そうした研究で提案された最新のモデルを動かすにはPytorchやTensorflow等のディープラーニングのパッケージを利用する必要があり、論文著者らにより公開されているコードを読み込んだり必要に応じて変更していく必要があります。モデル構造を深く理解したり自分のタスクに特化したものを作るにはそうしたコーディング技術が必須ですが、もう少し気軽に深層学習を用いた超解像を試して結果を見てみたい、どれくらい見た目が良くなるのかの感覚を掴みたい、ということがあると思います。

そこで今回はOpenCVとPythonを用いて、深層学習モデルの超解像を動かしてみようと思います。

## 方法
### 1. インストール
今回試す超解像は、OpenCVに加えて`opencv-contrib-python`というOpenCV準拠の拡張パッケージをインストールする必要があります。

```sh
$ pip install opencv-python
$ pip install opencv-contrib-python
```

### 2. モデルのダウンロード
超解像に利用するモデルはpipではインストールされないため、手動でダウンロードします。利用できる各モデルのリンクは下記URLの`README.md`に記載されています。2020/12/24現在では、以下のモデルに対応しており、拡大するときの倍率(scale)として2倍,3倍,4倍が用意されています。

- [EDSR](https://github.com/Saafke/EDSR_Tensorflow)
- [ESPCN](https://github.com/fannymonori/TF-ESPCN)
- [FSRCNN](https://github.com/Saafke/FSRCNN_Tensorflow)
- [LapSRN](https://github.com/fannymonori/TF-LapSRN)

[opencv\_contrib/modules/dnn\_superres at master · opencv/opencv\_contrib](https://github.com/opencv/opencv_contrib/tree/master/modules/dnn_superres)

これらは2016年から2017年頃にかけて提案されたモデルです。近年のコンピュータービジョンの深層学習の発展を考えると少々古く感じられますが、主要なモデルが揃っている感じです。超解像の発展における各モデルの位置付けは、下記の記事が参考になります。

- [【Intern CV Report】超解像の歴史探訪 \-2016年編\- \- Sansan Builders Blog](https://buildersbox.corp-sansan.com/entry/2019/03/20/110000)
- [トップ学会採択論文にみる、超解像ディープラーニング技術のまとめ \- Qiita](https://qiita.com/jiny2001/items/e2175b52013bf655d617)


### 3. コードを動かしてみる
それでは深層学習モデルを使った超解像を試してみましょう。ここでは[公式のTutorial](https://github.com/opencv/opencv_contrib/blob/master/modules/dnn_superres/tutorials/upscale_image_single/upscale_image_single.markdown)の通りに動かします。

```python
import cv2
from cv2 import dnn_superres

# Create an SR object - only function that differs from c++ code
sr = dnn_superres.DnnSuperResImpl_create()

# Read image
image = cv2.imread('./image.png')

# Read the desired model
path = "EDSR_x4.pb"
sr.readModel(path)

# Set the desired model and scale to get correct pre- and post-processing
sr.setModel("edsr", 4)

# Upscale the image
result = sr.upsample(image)

# Save the image
cv2.imwrite("./upscaled.png", result)
```

コードとしてはこれだけです。画像の読み込みと書き出しを除けば、超解像の処理自体は実質3行ほどで完結します。

注意点としては、`sr.readModel`で読み込むモデルと`sr.setModel`の引数（モデル名とスケール）を合わせる必要があります。例えばモデルに`EDSR_x4.pb`を利用するときは`("edsr", 4)`、モデルに`FSRCNN_x2.pb`を利用するときは`("fsrcnn", 2)`と指定します。

## 結果

今回は`1600x1600`の画像を用意し、macOSの`Preview.app`で`400x400`に縮小したあと、`EDSR_x4`で4倍にしてみました。

正直なところパット見では全然わかりませんねw。拡大して画像同士を近づけてよくよく見てみると、縮小後と比較してEDSRで超解像した画像は、輪郭であったり目の光の入り方、背後の柵などがオリジナルの画像に近づいていることがわかります。超解像を適用した画像は若干色がくすんだように見えますが、一旦は気にしないことにしましょう。

![](/img/opencv-superresolution.png)

### まとめ
今回はOpenCVを用いて深層学習モデルの超解像を適用する方法を紹介しました。OpenCVという枠組みで適用できてかつ学習済みモデルが配布されているので、気軽に実装して試すことができました。提供されている学習済みモデルの手法が少し古かったり、パラメータの変更など込み入ったことをするには機能が不足している感じは否めないですが、気軽に使えるという点ではOpenCVのcontribで提供されている今回の方法はとても良いと思います。

## 参考
- [OpenCV: Upscaling images: single\-output](https://docs.opencv.org/master/d5/d29/tutorial_dnn_superres_upscale_image_single.html)
- [Deep Learning based Super Resolution with OpenCV \| by Xavier Weber \| Towards Data Science](https://towardsdatascience.com/deep-learning-based-super-resolution-with-opencv-4fd736678066)
- [OpenCV Super Resolution with Deep Learning \- PyImageSearch](https://www.pyimagesearch.com/2020/11/09/opencv-super-resolution-with-deep-learning/)
