---
title: "漢字を構成する部首/偏旁のデータセット"
date: 2018-08-06T08:43:23+09:00
draft: true
---

![kanji_header](/img/kanji_header.png)

kanjivg-radicalは、漢字を構成する[部首](https://ja.wikipedia.org/wiki/%E9%83%A8%E9%A6%96)や[偏旁](https://ja.wikipedia.org/wiki/%E5%81%8F%E6%97%81)を容易に扱えるように対応付けしたデータセットです。

「脳」という漢字は、「月」「⺍」「凶」のように幾つかのまとまりごとに細分化できます。このように意味ある要素に分解しデータセットにすることで、漢字を文字的に分解して扱ったり、逆に特定の部首/偏旁を持つ漢字を一括して検索することができます。

このデータセットは、[KanjiVG](http://kanjivg.tagaini.net/index.html)で公開されているsvgデータを抽出および加工して作成されています。そのため、本データセットに含まれる部首/偏旁のアノテーションはすべてKanjiVGに準拠します。

---

## ダウンロード
以下のGitHubレポジトリからjson形式のファイルをダウンロードできます。`data/`配下にある各種jsonファイルが、データセットの本体です。

[yagays/kanjivg\-radical](https://github.com/yagays/kanjivg-radical)

---

## データセットの詳細
kanjivg-radicalには4種類のデータが含まれています。

1. 漢字と部首/偏旁の変換データ
2. 漢字と要素の変換データ
3. 漢字と部首/偏旁の変換データのうち、左右に分割できる漢字
4. 漢字と部首/偏旁の変換データのうち、上下に分割できる漢字

以下では、部首/偏旁は`radical`、要素は`element`、左右は`left_right`、上下は`top_buttom`と表現しています。

### 1. 漢字と部首/偏旁の変換データ
漢字と部首/偏旁を対応付けしたデータセットです。漢字から部首/偏旁と、部首/偏旁から漢字の2種類のデータがあります。

- [`kanji2radical.json`](https://github.com/yagays/kanjivg-radical/blob/master/data/kanji2radical.json) : 漢字から部首/偏旁への変換
- [`radical2kanji.json`](https://github.com/yagays/kanjivg-radical/blob/master/data/radical2kanji.json) : 部首/偏旁から漢字への変換

```
# kanji2radical.jsonのサンプル
"脳": [
    "月",
    "⺍",
    "凶"
]
```

```
# radical2kanji.jsonのサンプル
"月": [
    "肝",
    "育",
    "胆",
    "朦",
    "脱",
...
```

### 2. 漢字と要素の変換データ

漢字と要素を対応付けしたデータセットです。漢字から要素と、要素から漢字の2種類のデータがあります。

- [`kanji2element.json`](https://github.com/yagays/kanjivg-radical/blob/master/data/kanji2element.json) : 漢字から要素への変換
- [`element2kanji.json`](https://github.com/yagays/kanjivg-radical/blob/master/data/element2kanji.json) : 要素から漢字への変換

ここで使用している「要素」いう言葉は、部首/偏旁を構成する更に細かい単位での漢字のことを指しています。言語学的に定義された単語ではなく、KanjiVGで利用されていた`element`の対訳として用いています。

このデータでは構成している要素をすべて列挙しているので、結果の中には重複が含まれます。以下の例だと脳には「凶」という要素が含まれていますが、同時に「乂」という要素も含まれているため、どちらもkanji2elementの結果として出力されます。

```
# kanji2element.jsonのサンプル
"脳": [
    "乂",
    "凶",
    "丿",
    "凵",
    "⺍",
    "月"
]
```


```
# element2kanji.json
"月": [
    "溯",
    "齟",
    "蔡",
    "羂",
    "肝",
    "育",
```

### 3. 漢字と部首/偏旁の変換データのうち、左右に分割できる漢字
1.のデータセットのうち、漢字の構成が左と右の2つに分割できるものだけを集めたデータです。3つ以上に分割される漢字や、左右のどちらかが複数に分割される漢字は含まれていません。

- [`kanji2radical_left_right.json`](https://github.com/yagays/kanjivg-radical/blob/master/data/kanji2radical_left_right.json)
- [`radical2kanji_left_right.json`](https://github.com/yagays/kanjivg-radical/blob/master/data/radical2kanji_left_right.json)

```
# kanji2radical_left_right.jsonのサンプル
{'乢': ['山', '乙'],
 '嶋': ['山', '鳥'],
 '恥': ['耳', '心'],
 '擦': ['扌', '察'],
...
```

### 4. 漢字と部首/偏旁の変換データのうち、上下に分割できる漢字
1.のデータセットのうち、漢字の構成が上と下の2つに分割できるものだけを集めたデータです。3つ以上に分割される漢字や、上下のどちらかが複数に分割される漢字は含まれていません。

- [`kanji2radical_top_buttom.json`](https://github.com/yagays/kanjivg-radical/blob/master/data/kanji2radical_top_buttom.json)
- [`radical2kanji_top_buttom.json`](https://github.com/yagays/kanjivg-radical/blob/master/data/radical2kanji_top_buttom.json)

```
# kanji2radical_top_buttom.jsonのサンプル
{'云': ['二', '厶'],
 '賃': ['任', '貝'],
 '輩': ['非', '車'],
 '雪': ['雨', '⺕'],
 ...
```

## 統計

|                          | 登録漢字数 | 登録部首/偏旁/要素数 |
| :----------------------- | ----: | ----------: |
| kanji2radical            | 6,279 | 1,300       |
| kanji2element            | 6,279  | 1,306       |
| kanji2radical_left_right | 3,190 | 1,013       |
| kanji2radical_top_buttom | 1,088 | 643         |

---

## 使い方

配布しているjsonファイルを、ハッシュ関数や辞書形式など任意のプログラミング言語で読み込んで使用します。

ここでは、Pythonでの利用方法を例示します。

```py
import json

def load_json(filename):
    with open(filename) as f:
        d = json.load(f)
    return d

kanji2radical = load_json("kanji2radical.json")
radical2kanji = load_json("radical2kanji.json")    
```

```py
kanji2radical["脳"] # kanji to radicals

radical2kanji["月"] # radical to kanjis
```

より詳細な利用方法は[`example/basic_usage.ipynb`](https://github.com/yagays/kanjivg-radical/blob/master/example/basic_usage.ipynb)を参照ください。

## 作成方法

[KanjiVG](http://kanjivg.tagaini.net/index.html)で公開されているすべての漢字に対して、svg内に含まれる`g`タグの`kvg:element`属性を抽出しています。抽出方法により、データセットに以下の違いがあります。

- `kanji2radical.json`などの漢字と部首/偏旁の変換データは、対象となる漢字の直下に含まれる`kvg:element`属性のみを抽出
- `kanji2element.json`などの漢字と要素の変換データは、すべての`kvg:element`属性を再帰的に抽出

対象としたバージョンは最新版である2016/04/26リリースであり、variantを含まない`kanjivg-20160426-main.zip`を利用しています。

ちなみに、このデータセットには含まれていませんが、KanjiVGには他にも一画ごとのストロークの形状を`kvg:type`として分類し記録しています。そういったより詳細な漢字の図形的情報が必要な場合は、本家のデータセットを参照ください。

[Format \- KanjiVG](http://kanjivg.tagaini.net/format.html)

## ライセンス

このリソースは<a rel="license" href="http://creativecommons.org/licenses/by/4.0/">クリエイティブ・コモンズ 表示 4.0 国際 ライセンス</a>の下に提供されています。

This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.

## 参考
- [KanjiVG/kanjivg: Kanji description and vectorial data in correct stroke order](https://github.com/KanjiVG/kanjivg)
- [KanjiVG \- 漢字/平仮名/カタカナ/アルファベット/数字の書き順付きSVG集 MOONGIFT](https://www.moongift.jp/2017/11/kanjivg-%E6%BC%A2%E5%AD%97%E5%B9%B3%E4%BB%AE%E5%90%8D%E3%82%AB%E3%82%BF%E3%82%AB%E3%83%8A%E3%82%A2%E3%83%AB%E3%83%95%E3%82%A1%E3%83%99%E3%83%83%E3%83%88%E6%95%B0%E5%AD%97%E3%81%AE%E6%9B%B8/)
