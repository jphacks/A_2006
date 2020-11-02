from flask import Flask, request, jsonify, make_response
app = Flask(__name__)

#TODO:画像から犬の状態を判定する
coefficient_dic = {'adult':1.8, #成犬
                      'sterilized':1.6, #不妊治療済み
                      'obesity':1.4, #肥満気味
                      'increasing':1.3, #増量中
                      'pregnancy':2.4, #妊娠期
                      'lactation':6, #泌乳期
                      'growth_period':3, #成長期
                      'old': 1.4 #老犬
                }
# base64をpillowで扱えるように変換
def img_parser(img):
    img = request.form["img"]
    img = base64.b64decode(img)
    img = BytesIO(img)
    img = Image.open(img)
    return img

# 距離を返す(km)
def ideal_walk_dst(cal, weight):
    dst = ((cal/weight - 1.25*(weight)**(-1/4))*weight**(-2/5))/1.77
    return dst

def calc_rep(weight): #安静時エネルギー
    rep=70*(weight)**(2/3)
    return rep

def calc_der(rep, state): #一日あたりの理想エネルギー
    der = rep*coefficient_dic[state]
    return der

@app.route('/', methods=["POST"])
def main():

    json_data = request.get_json()
    weight = float(json_data.get("weight"))
    coefficient = json_data.get("coefficient")
    
    #TODO:POSTされた画像データを扱う
    #img = img_parser(json_data.get("img"))

    rep = calc_rep(weight)
    der = calc_der(rep, coefficient)
    dst = ideal_walk_dst(der, weight)
    
    print("[DEBUG] distance: "+str(dst))

    payload = {
        "result":True,
        "data":{
            "distance": dst,
        }
    }
    
    return jsonify(payload)

if __name__ == "__main__":
    app.run(debug=True, host='localhost', port=8080)

