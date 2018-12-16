---
title: "Wikipediaの記事ごとのページビューを取得する"
date: 2018-12-16T12:42:50+09:00
draft: false
---

![https://www.pexels.com/photo/marketing-iphone-smartphone-notebook-34069/](/img/wikipedia-pageview_header.png)

自然言語処理においてWikipediaのテキストコーパスは広く利用されており、各記事のページビュー(閲覧数)の情報もトレンド分析やエンティティリンキング等で用いられています。この記事では、Wikipediaの記事ごとのページビューを取得する方法を紹介します。

## tl;dr

- ウェブから簡単に調べるなら → Pageviews Analysis
- 少数の記事についてプログラムから利用したいなら → Pageview API
- 大量の記事についてプログラムから利用したいなら → Wikimedia Analytics Datasets

## 1. Pageviews Analysisを利用する

手軽にページビューを確認するには「[Pageviews Analysis](https://tools.wmflabs.org/pageviews/)」というウェブサイトがもっとも容易です。

Pageviews Analysisではグラフによる時系列の可視化、複数記事の比較、編集履歴の回数、csvやjsonによるダウンロードなど、多様な機能を備えています。また現在どのようなページが多く閲覧されているかといった[言語ごとの閲覧数ランキング](https://tools.wmflabs.org/topviews/)などの機能もあり、とりあえず何か調べるなら大抵のことはPageviews Analysisで完結すると思います。

![wikipedia-pageview_01](/img/wikipedia-pageview_01.png)

ちなみに日本語の記事を検索する場合は「プロジェクト」を`ja.wikipedia.org`に指定するのを忘れずに。

## 2. Pageview APIを利用する

Wikimediaにはページビューを取得する[REST API](https://www.mediawiki.org/wiki/REST_API)が用意されています。指定できるパラメータや得られる情報ははPageviews Analysisと大差ありませんが、json形式で取得できるのでプログラムへの連携が簡単になります。幾つかリストアップした記事ごとに手軽にページビューを得たいという場合には最適な方法です。ただし100リクエスト/秒という制限があるので、日本語の記事全部のページビューを得たいといった用途には不向きです。

[Wikimedia REST APIドキュメント](https://wikimedia.org/api/rest_v1/)

こちらもREST APIのドキュメントからパラメータを指定してリクエストを送り、ウェブ上で結果を確認する機能があります。同時に`curl`のコマンドやURLのエンドポイントも自動で生成してくれるので、サンプルで動かす際には便利です。

例えばプロジェクト`ja.wikipedia.org`における`機械学習`という記事の`2018/12/01`から`2018/12/03`ページビューを得るときのコマンドは以下のようになりました。

```sh
$ curl -X GET --header 'Accept: application/json; charset=utf-8' 'https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article/ja.wikipedia.org/all-access/all-agents/%E8%87%AA%E7%84%B6%E8%A8%80%E8%AA%9E%E5%87%A6%E7%90%86/daily/20181201/20181203'
```

返ってくる結果は以下のようになります。

```json
{
  "items": [
    {
      "project": "ja.wikipedia",
      "article": "機械学習",
      "granularity": "daily",
      "timestamp": "2018120100",
      "access": "all-access",
      "agent": "all-agents",
      "views": 210
    },
[...]
  ]
}
```

なお、ドキュメントにも記載されていますが、複数のクエリを機械的にリクエストするときには`User-Agent`や`Api-User-Agent`をヘッダに含めてリクエスト送り元がわかるようにしましょう。Pythonの`requests`パッケージで実行する場合は以下のようにヘッダで情報を付与します。

```python
import requests

url = "https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article/ja.wikipedia.org/all-access/all-agents/%E6%A9%9F%E6%A2%B0%E5%AD%A6%E7%BF%92/daily/20181201/20181203"
headers = {"User-Agent": "your-email@example.com"}

r = requests.get(url, headers=headers)
print(r.json())
```

ちなみに、Rにはこのエンドポイントを叩くパッケージがあるので、そちらを利用する方が簡単そうです。

- [petermeissner/wikipediatrend: A convenience R package for getting Wikipedia article access statistics \(and more\)\.](https://github.com/petermeissner/wikipediatrend)

## 3. Wikimedia Analytics Datasetsを利用する

最後はWikimediaが配布しているデータを直に見に行く方法です。こちらではすべてのwikipediaのページにおける2015年からの毎時間ごとのページビューのデータがgz圧縮されたファイルで公開されています。2018/12現在で毎時40~60MBほどのデータが吐き出されているので扱うのが少し大変ですが、全記事に対するページビューを計算したいという場合にはこの方法しかありません。

[Analytics: Pageviews](https://dumps.wikimedia.org/other/pageviews/readme.html)

ファイル名は`pageviews-YYYYMMDD-hhnnss.gz`という命名規則になっており、スペース区切りで`domain_code page_title count_views total_response_size`という内容で保存されています。肝心のページビューは`count_views`です。

```
aa Special:Statistics 1 0
aa Wikipedia 2 0
aa Wikipedia:Community_Portal 2 0
[...]
ja 機械可読目録 1 0
ja 機械学習 33 0
ja 機械工学 3 0
[...]
```

## 参考

- [Wikipedia:Pageview statistics \- Wikipedia](https://en.wikipedia.org/wiki/Wikipedia:Pageview_statistics)
- [How to use Wikipedia API to get the page view statistics of a particular page in wikipedia? \- Stack Overflow](https://stackoverflow.com/questions/5323589/how-to-use-wikipedia-api-to-get-the-page-view-statistics-of-a-particular-page-in)
- [Wikipediaのアクセス数を取得する \- そうだ車輪と名づけよう 7th](https://atyks.hateblo.jp/entry/2015/03/31/000100)
