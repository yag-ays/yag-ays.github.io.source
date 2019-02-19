---
title: "語彙を限定して単語ベクトルのモデルサイズを小さくするminify_w2v"
date: 2019-02-19T10:03:37+09:00
draft: false
---

![https://www.pexels.com/photo/person-holding-terrestrial-globe-scale-model-taken-1079033/](/img/minify_w2v_header.png)

## 概要

最近では単語埋め込みのベクトルをニューラルネットの埋め込み層に利用する手法が多く使われていますが、学習済みの単語埋め込みは多くの語彙を含んでおり、ファイルサイズが大きくロード時間もかかります。再現性のために学習に使う外部データを固定したり、APIのためにDockerコンテナに同梱する際には、こういったリソースはなるべくサイズを減らしたいという場合があります。そこで、必要な語彙に限定することで学習済み単語埋め込みのモデルサイズを小さくするコードを書きました。

[yagays/minify_w2v: Minify word2vec model file](https://github.com/yagays/minify_w2v)

## 使い方

動作は至ってシンプルで、読み込んだ学習済み単語ベクトルの中から指定された単語のベクトルのみを抜き出して出力するだけです。

1.  学習済みモデルを読み込む
2.  必要な語彙を指定する
3.  出力する

`load_word2vec`と`save_word2vec`にはそれぞれ`binary`オプションがあり、入力および出力をバイナリフォーマットかテキストフォーマットか選択できます。

```py
mw2v = MinifyW2V()
mw2v.load_word2vec("/path/to/model.txt")
mw2v.set_target_vocab(target_vocab=["cat", "dog"])
mw2v.save_word2vec("/path/to/output.bin", binary=True)
```

## ベンチマーク

日本語 Wikipedia エンティティベクトルの単語ベクトルを元に、そこから語彙を10,000に減らしたときのファイルサイズや読み込み時間を比較した結果です。テキストファイルの場合はファイルフォーマットの構造上、語彙を減らせば線形でファイルサイズも小さくなりますし読み込み時間も小さくなります。

| Name                                                                         | Vocab. size | File size | Load time |
| :--------------------------------------------------------------------------- | ----------: | --------: | --------: |
| [`jawiki.word_vectors.200d.txt`](https://github.com/singletongue/WikiEntVec) |     727,471 |      1.6G |  1min 27s |
| [`jawiki.word_vectors.200d.bin`](https://github.com/singletongue/WikiEntVec) |     727,471 |      563M |     5.9 s |
| `jawiki.word_vectors.200d.10000.txt`                                         |      10,000 |       22M |    1.18 s |
| `jawiki.word_vectors.200d.10000.bin`                                         |      10,000 |      7.7M |    190 ms |

## plasticityai/magnitudeとの関連
単語ベクトルを効率よく扱う方法として、`magnitude`という軽量で遅延読み込み等をサポートしたパッケージがあります。Magnitude Formatsという形式で保存することで読み込み速度を大幅に短縮することができるほか、単語埋め込みで利用される類似度検索や、KerasやPytorchなど他のパッケージとのインターフェイスも提供されています。

[plasticityai/magnitude: A fast, efficient universal vector embedding utility package\.](https://github.com/plasticityai/magnitude)

単語ベクトルの読み込みの高速化を目指すのならばmagnitudeを使ったほうが効率が良いと思います。一方で、`gensim`への連携の容易さやモデルファイルの取り扱いはword2vec formatの方が良く、またminify_w2vで語彙を選別した後にmagnitudeで利用できる形に変換するという方法もあります。どの方法が一番良いかは利用ケース次第だと思います。
