---
title: "後処理のみで単語ベクトルの性能を向上させるALL-BUT-THE-TOPを使った日本語学習済み分散表現"
date: 2019-02-23T00:49:58+09:00
draft: false
---

![https://www.pexels.com/photo/green-pine-trees-covered-with-fogs-under-white-sky-during-daytime-167699/](/img/all_but_the_top_header.png)

## 概要
ICLR2018で発表された[All\-but\-the\-Top: Simple and Effective Postprocessing for Word Representations](https://arxiv.org/abs/1702.01417)の後処理を実装し、日本語学習済み分散表現に対して適用し評価を行いました。また、作成した単語ベクトルを配布します。

## All-but-the-Top
All-but-the-Topは、学習済みの分散表現に対して特定の後処理を加えることにより、分散表現の評価に用いられるタスクにおいて性能向上を達成した手法です。単語ベクトル内に存在する偏りを無くすために、平均で標準化し、主成分分析で幾つかの方向の主成分を引くという処理をするというのものです。たったこれだけという感じですが、SIF Embeddingの研究と同様に理論的な裏付けがあるようです。こういった背景や英語での実験結果は論文を参考ください。日本語での解説は[こちらの論文紹介スライド](https://www.slideshare.net/MacotoTachenaca/allbutthetop-simple-and-effective-postprocessing-for-word-representations-98611879)が参考になります。

## 単語ベクトルのダウンロード
以下の2つの学習済み分散表現に対してAll-but-the-Topの後処理を適用したファイルです。配布するモデルは、元のファイル名に加えて`abtt`という名前が付与されています。

| ファイル                                                                                                                  | 次元数/語彙数         | ファイルサイズ |
| --------------------------------------------------------------------------------------------------------------------: | --------------: | ------: |
| [jawiki.word_vectors.100d.abtt.bin](https://www.dropbox.com/s/nhwhgick37rh64k/jawiki.word_vectors.100d.abtt.bin?dl=0) | 100 / 727,471   |    285M |
| [jawiki.word_vectors.200d.abtt.bin](https://www.dropbox.com/s/zjosb4wil5asri0/jawiki.word_vectors.200d.abtt.bin?dl=0) | 200 / 727,471   |    563M |
| [jawiki.word_vectors.300d.abtt.bin](https://www.dropbox.com/s/twyfumale4okxn6/jawiki.word_vectors.300d.abtt.bin?dl=0) | 300 / 727,471   |    840M |
| [cc.ja.300d.abtt.bin](https://www.dropbox.com/s/zjwd7sf22tn8qs5/cc.ja.300d.abtt.bin?dl=0)                             | 300 / 2,000,000 |    2.3G |

- jawiki.word_vectors: [日本語 Wikipedia エンティティベクトル](http://www.cl.ecei.tohoku.ac.jp/~m-suzuki/jawiki_vector/)
  - 20181001版の`jawiki.word_vectors`を使用
  - 鈴木正敏, 松田耕史, 関根聡, 岡崎直観, 乾健太郎. Wikipedia 記事に対する拡張固有表現ラベルの多重付与. 言語処理学会第22回年次大会(NLP2016), March 2016.
- cc.ja: [facebookresearch/fastText](https://github.com/facebookresearch/fastText/blob/master/docs/crawl-vectors.md)
  - E. Grave\*, P. Bojanowski\*, P. Gupta, A. Joulin, T. Mikolov, [Learning Word Vectors for 157 Languages](https://arxiv.org/abs/1802.06893)


## 実装
ソースコードは以下のレポジトリにあります。

[yagays/all\_but\_the\_top](https://github.com/yagays/all_but_the_top)

ハイパーパラメータであるPCAの次元数は、論文中で経験的に示された`d/100`を用いています（`d`は単語ベクトルの次元数）。

## 評価
ここでは、日本語での評価データセットが公開されている「[日本語単語類似度データセット](https://github.com/tmu-nlp/JapaneseWordSimilarityDataset)」を用いた単語類似度による評価を行いました。以下の数値は、スピアマンの順位相関係数に100を掛けたものです。

| 分散ベクトル               |        動詞 |       形容詞 |        名詞 |        副詞 |        平均 |
| :------------------- | --------: | --------: | --------: | --------: | --------: |
| word2vec.100d        | **25.06** | **21.42** | **22.69** |     18.57 | **21.94** |
| word2vec.100d + abtt |     25.05 |     19.21 |     20.85 | **21.33** |     21.61 |

| 分散ベクトル               |        動詞 |       形容詞 |        名詞 |        副詞 |        平均 |
| :------------------- | --------: | --------: | --------: | --------: | --------: |
| word2vec.200d        |     25.88 | **22.20** | **23.90** |     20.63 |     23.15 |
| word2vec.200d + abtt | **26.55** |     20.71 |     21.48 | **26.65** | **23.85** |

| 分散ベクトル               |        動詞 |       形容詞 |        名詞 |        副詞 |        平均 |
| :------------------- | --------: | --------: | --------: | --------: | --------: |
| word2vec.300d        |     25.72 | **22.34** | **24.87** |     21.85 |     23.70 |
| word2vec.300d + abtt | **26.50** |     21.59 |     23.91 | **27.22** | **24.81** |

| 分散ベクトル               |        動詞 |       形容詞 |        名詞 |        副詞 |        平均 |
| :------------------- | --------: | --------: | --------: | --------: | --------: |
| fasttext.300d        | **21.04** | **35.91** |     31.01 |     30.98 |     29.73 |
| fasttext.300d + abtt |     20.36 |     35.80 | **31.95** | **33.24** | **30.34** |

All-but-the-Topを適用することによって、200次元以上のモデルにおいて平均的にスピアマンの順位相関係数が向上していることがわかりました。ただし、すべての品詞において向上するわけではなく、形容詞や名詞では逆に数値が低くなっている場合もあります。単語埋め込みの研究においては幾つもの評価手法が存在し、これ自体は性能評価の1つの側面でしかありませんが、All-but-the-Topによる後処理が有用であることを示すことができたと思われます。

なお、単語から単語ベクトルへの変換において、分かち書きで2単語以上に分割された単語列に関しては、[堺澤ら](http://www.anlp.jp/proceedings/annual_meeting/2016/pdf_dir/P9-8.pdf)と同様に単語の平均ベクトルを用いています。また、どちらかに存在しない語彙が含まれていて単語ベクトルが計算できない場合は、類似度を`-1`としました。今回の実験が幾つかの既存研究における日本語単語類似度データセットでの結果と異なっているのは、これらの前処理や形態素解析の辞書が異なるからだと考えられるのですが、もし詳しい方がいらっしゃったらご指摘いただければと思います。

実行した評価スクリプトは [`evaluation.py`](https://github.com/yagays/all_but_the_top/blob/master/src/evaluation.py)にあります。

## ライセンス

本ページで配布しているモデルファイルのライセンスは[Creative Commons Attribution-ShareAlike 3.0.](https://creativecommons.org/licenses/by-sa/3.0/)です。

## 参考

- [All-but-the-Top: Simple and Effective Postprocessing for Word Representations](https://www.slideshare.net/MacotoTachenaca/allbutthetop-simple-and-effective-postprocessing-for-word-representations-98611879)
- [同義語を考慮した日本語の単語分散表現の学習](https://ipsj.ixsq.nii.ac.jp/ej/index.php?active_action=repository_view_main_item_detail&page_id=13&block_id=8&item_id=183799&item_no=1)
- [日本語単語ベクトルの構築とその評価](https://ipsj.ixsq.nii.ac.jp/ej/?action=pages_view_main&active_action=repository_view_main_item_detail&block_id=8&item_id=141870&item_no=1&page_id=13&utm_campaign=buffer&utm_content=buffer43028&utm_medium=social&utm_source=twitter.com)
  - 吉井らは単語類推タスクと文完成タスクの2種類で評価しているが、データセットが公開されていなかったため実験は行わなかった
- [SNLP10sentence\.pdf](http://chasen.org/~daiti-m/paper/SNLP10sentence.pdf)
- [電力が限界だとは言うけれど \- 武蔵野日記](http://komachi.hatenablog.com/entry/20180524/p1)
