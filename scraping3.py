from flickrapi import FlickrAPI
from urllib.request import urlretrieve
import os, time, sys
from pprint import pprint

#APIキーの情報

key = "bbe026d435e986d2705cda3991e25b0d"
secret = "a43367a5270504d5"
wait_time = 0.5 #これがないとあっちのサーバーに負荷をかけてしまい、スパムとして認識されるかも

#保存フォルダの指定
q = sys.argv[1:] #python download.py 〇〇〇　←ここ(download.pyがsys.argv[0])

savedir = "./data/" + " ".join(q) #sys.argv[1]の位置に書いたワードと同じファイルに保存しようとしてる(別のワードでサーチするたびにその名前のフォルダを作ろう！)
try:
    os.mkdir(savedir)
except:
    pass

flickr = FlickrAPI(key, secret, format="parsed-json") #写真のデータがこの変数に格納される
result = flickr.photos.search(
    text = " ".join(q),   #sys.argv[1]の位置に書いたワードでサーチするよ
    per_page = 1000, #集めたい枚数を指定する
    media = "photos", #よくわからんがこうしておく
    sort = "relevance", #関連順に並ぶらしい
    safe_search = 1, #お子様に見せられない写真をブロックする
    extras = "url_q, licence" #これによって画像のurlを取得する。一番大事
)

photos = result["photos"] #resultのphotosだけを取り出す
#pprint(photos)

for i,photo in enumerate(photos["photo"]):
    url_q = photo["url_q"] #写真一枚一枚においてurlを取り出し、
    filepath = savedir + "/" + photo["id"] + ".jpg" #それを用いて写真の保存先を指定
    if os.path.exists(filepath): #もし同じ写真があったら除外する
        continue
    urlretrieve(url_q,filepath) #写真を保存先に保存
    time.sleep(wait_time) #ちょっとだけ待ってあげる