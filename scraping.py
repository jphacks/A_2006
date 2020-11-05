from bs4 import BeautifulSoup
import urllib.request, urllib.error, urllib.parse



def select_img(keyword="TT兄弟"):    
    
    max_page = 3 # ページ数（20枚/ページ）
    
    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:47.0) Gecko/20100101 Firefox/47.0",
    }
    
    # cnt = random.choice([i for i in range(200) if i%20 == 0])
    url = 'https://search.yahoo.co.jp/image/search?p={}&fr=top_ga1_sa&ei=UTF-8'.format(urllib.parse.quote(keyword))
    
    req = urllib.request.Request(url=url, headers=headers)
    res = urllib.request.urlopen(req)
    soup = BeautifulSoup(res, features="lxml")
    
    # div = soup.find_all(class_="sw-ThumbnailGrid")
    # print(div)
    imgs = soup.find_all('img')
    
    print(imgs)

    # img = random.choice(imgs)
    # img = img["src"]
    # tmp = urllib.request.urlopen(img)
    # data = tmp.read()
    # return data


if __name__ == "__main__":
    select_img("犬")