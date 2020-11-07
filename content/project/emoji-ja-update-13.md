---
title: "絵文字の日本語読み辞書をUNICODE 13.0対応に更新しました"
date: 2020-11-07T21:01:50+09:00
draft: false
---

![https://www.pexels.com/photo/egyptian-symbols-3199399/](/img/emoji_ja_13.png)


[Unicode絵文字の日本語読み/キーワード/分類辞書](https://github.com/yagays/emoji-ja/)を、Unicode 13.0に更新しました。

今回は[@HeroadZ](https://github.com/HeroadZ/)にPull Requestを送っていただきました。ありがとうございます（PR放置してごめんなさい🙏）。


- 前回の記事：[絵文字の日本語読み辞書をUnicode 12\.0対応に更新しました](https://yag-ays.github.io/project/emoji-ja-update-12/)
- 前々回の記事：[📙Unicode絵文字の日本語読み/キーワード/分類辞書📙](https://yag-ays.github.io/project/emoji-ja/)

--- 

## 🔖 リリース
Githubレポジトリの`20201107`リリースからダウンロードするか、現在masterブランチに含まれている各種ファイルを利用ください。

- [Release 20201107 · yagays/emoji\-ja](https://github.com/yagays/emoji-ja/releases/tag/20201107)

前回からのアップデートは、Unicode 13.0で追加された新規絵文字の対応のみです。

## ➡ 括弧やコンマといった記号の読みの追加

今回のリリースから記号の読みが追加されており、これは辞書が参照しているUnicode CLDRのリストに追加されたためです。はたして記号は絵文字なのかという疑問が湧きますが、特に区別する必要性も感じられなかったので、元のソースに従ってすべて辞書に追加しています。


```
"«": {
    "keywords": [
        "カッコ",
        "二重ギュメ",
        "山パーレン",
        "左ギュメ",
        "左山括弧",
        "引用符"
    ],
    "short_name": "左山括弧",
    "group": "",
    "subgroup": ""
},
```


## 📝 参考

- [Unicode 13\.0\.0](https://unicode.org/versions/Unicode13.0.0/)
- [Unicode 13\.0 Emoji List](https://emojipedia.org/unicode-13.0/)