---
title: "Wikipedia CirrusSearchのダンプデータを利用する"
date: 2018-07-30T21:07:52+09:00
draft: false
---

![https://www.pexels.com/photo/black-and-white-blank-challenge-connect-262488/](/img/cirrus_header.png)

Wikipediaのデータを容易に利用できる[CirrusSearch](https://www.mediawiki.org/wiki/Help:CirrusSearch/ja)のダンプデータについて紹介します。これを利用することにより、Wikipediaの巨大なXMLデータをパースしたり、[Wikipedia Extractor](http://medialab.di.unipi.it/wiki/Wikipedia_Extractor)など既存のツールで前処理することなく、直にWikipediaの各種データにアクセスすることができます。

## tl;dr
細かいことは置いておいて、素直にWikipediaの日本語エントリーに書かれているテキストを取得したい場合、

- [ここ](https://dumps.wikimedia.org/other/cirrussearch/)のCirrusSearchの任意の日付のダンプデータ`jawiki-YYYYMMDD-cirrussearch-content.json.gz`を落としてくる
- 中に入っているjsonデータをパースして、偶数行の`"text"`を取得するコードを書く

とすることで、簡単にWikipediaのテキストデータを取得することができます。

## CirrusSearchダンプデータの概要
[CirrusSearch](https://www.mediawiki.org/wiki/Help:CirrusSearch/ja)は、ElasticSearchをバックエンドに構成された検索システムです。このシステムに利用されているデータがダンプデータとして公開されており、そのファイルを利用することで、整形されたテキストを始めとして、外部リンクのリストやカテゴリのリスト等のメタデータが容易に利用できます。また、言語ごとにダンプファイルが分かれているため、日本語のWikipediaのデータだけを対象にすることが可能です。

CirrusSearchのダンプデータは以下から取得します。

[Index of /other/cirrussearch/](https://dumps.wikimedia.org/other/cirrussearch/)

Wikipediaに関するダンプデータは以下の2つです。

| ファイル                                         | 内容                               |
| :------------------------------------------- | :------------------------------- |
| `jawiki-YYYYMMDD-cirrussearch-content.json.gz` | Wikipediaの本文（`namespace`が`0`）      |
| `jawiki-YYYYMMDD-cirrussearch-general.json.gz` | Wikipediaのその他情報（`namespace`が`0`以外） |

その他の接頭辞の対応関係は以下の通りです。

- jawiki: [ウィキペディア](https://ja.wikipedia.org/wiki/%E3%83%A1%E3%82%A4%E3%83%B3%E3%83%9A%E3%83%BC%E3%82%B8)
- jawikibooks: [ウィキブックス](https://ja.wikibooks.org/wiki/%E3%83%A1%E3%82%A4%E3%83%B3%E3%83%9A%E3%83%BC%E3%82%B8)
- jawikinews: [ウィキニュース](https://ja.wikinews.org/wiki/%E3%83%A1%E3%82%A4%E3%83%B3%E3%83%9A%E3%83%BC%E3%82%B8)
- jawikiquote: [ウィキクォート](https://ja.wikiquote.org/wiki/%E3%83%A1%E3%82%A4%E3%83%B3%E3%83%9A%E3%83%BC%E3%82%B8)
- jawikisource: [ウィキソース](https://ja.wikisource.org/wiki/%E3%83%A1%E3%82%A4%E3%83%B3%E3%83%9A%E3%83%BC%E3%82%B8)
- jawikiversity: [ウィキバーシティ](https://ja.wikiversity.org/wiki/%E3%83%A1%E3%82%A4%E3%83%B3%E3%83%9A%E3%83%BC%E3%82%B8)

## CirrusSearchのデータ
CirrusSearchのダンプデータは、1行が1つのjsonとなっており、2行で1つのエントリーを表しています。

### 奇数行
奇数行にはエントリーに固有のidが記載されています。この`_id`から該当のエントリーにアクセスするには、[`https://ja.wikipedia.org/?curid=3240437`](https://ja.wikipedia.org/?curid=3240437)のように`curid`のパラーメータを指定します。

```json
{
  "index": {
    "_type": "page",
    "_id": "3240437"
  }
}
```

### 偶数行
偶数行にはエントリーの情報が記載されています。下記の例では、複数の要素が入った配列や長い文字列は`...`で省略しています。


```json
{
  "template": [
    "Template:各年の文学ヘッダ",
    ...
  ],
  "content_model": "wikitext",
  "opening_text": "1972年の文学では、1972年（昭和47年）の文学に関する出来事について記述する。",
  "wiki": "jawiki",
  "auxiliary_text": [
    "  1972年 こちらもご覧下さい   社会 政治 経済 ..."
  ],
  "language": "ja",
  "title": "1972年の文学",
  "text": "1972年の文学では、1972年（昭和47年）の文学に関する出来事について記述する。 ...",
  "defaultsort": false,
  "timestamp": "2017-03-28T05:50:27Z",
  "redirect": [],
  "wikibase_item": "Q944470",
  "heading": [
    "できごと",
    ...
  ],
  "source_text": "{{各年の文学ヘッダ|1972}}\n{{Portal|文学}}\n'''1972年の文学'''では、...",
  "version_type": "external",
  "coordinates": [],
  "version": 63522821,
  "external_link": [
    "http://www.1book.co.jp/001351.html",
    ...
  ],
  "namespace_text": "",
  "namespace": 0,
  "text_bytes": 6266,
  "incoming_links": 65,
  "category": [
    "1972年の小説",
    ...
  ],
  "outgoing_link": [
    "Template:各年の文学ヘッダ",
    ...
  ],
  "popularity_score": 4.5278205052139e-08
}  
```

よく使いそうな項目：

- `text`: 整形されたエントリーの本文（タグ等が含まれていない平文）
- `title`: エントリーのタイトル
- `category`: エントリーに登録されているカテゴリ
- `source_text`: mediawiki記法の本文（ウェブ画面でレンダリングするためのタグ等が含まれている）
- `outgoing_link`: エントリーのテキストに含まれる外部記事へのリンク

## CirrusSearchのデータを扱う
### シェルで確認する
シェルから簡易的にダンプデータの中身を確認するには、以下のように圧縮ファイルの中身を[jq](https://stedolan.github.io/jq/)を利用して整形して表示するのが容易です。

```sh
# Linuxの場合
$ zcat jawiki-20171106-cirrussearch-general.json.gz  | jq . | less
# macOSの場合
$ gzcat jawiki-20171106-cirrussearch-general.json.gz  | jq . | less
```

### Pythonでパースする
Pythonでテキストを利用するには、下記のようなコードを利用します。

```py
import json
import gzip

with gzip.open("jawiki-20180611-cirrussearch-content.json.gz") as f:
    for line in f:
        json_line = json.loads(line)
         if "index" not in json_line:
            text = json_line["text"]
```

## ライセンス
本ページはCirrusSearchのデータを一部改変して記載しております。本ページもCirrusSearchと同様に、CC-BY-SAにて公開します。

[Creative Commons Attribution-ShareAlike License](https://creativecommons.org/licenses/by-sa/3.0/)

## 参考

- [Help:CirrusSearch \- MediaWiki](https://www.mediawiki.org/wiki/Help:CirrusSearch/ja)
- [森羅：Wikipedia構造化プロジェクト2018 \| 革新知能統合研究センター](https://aip.riken.jp/labs/goalorient_tech/lang_inf_access_tech/%e6%a3%ae%e7%be%85%ef%bc%9awikipedia%e6%a7%8b%e9%80%a0%e5%8c%96%e3%83%97%e3%83%ad%e3%82%b8%e3%82%a7%e3%82%af%e3%83%882018/)
  - CirrusSearchのデータを用いたShared Task形式のプロジェクト
