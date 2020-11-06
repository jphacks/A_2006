from flask import Flask, request, jsonify, make_response
from azure.cognitiveservices.vision.customvision.prediction import CustomVisionPredictionClient
from msrest.authentication import ApiKeyCredentials
from werkzeug.utils import secure_filename
from PIL import Image
import json

# サニタイズ卍
ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg','gif'])
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

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
    der = rep*state
    return der


def azure_request(img_by):
    project_ID = "xxx"
    iteration_name = "xxx"
    key = "xxxx"
    endpointurl = "xxxx"

    prediction_credentials = ApiKeyCredentials(
        in_headers={"Prediction-key": key}
        )

    predictor = CustomVisionPredictionClient(
        endpointurl,
        prediction_credentials
        )

    results = predictor.classify_image(
        project_ID, 
        iteration_name, 
        img_by
        )
    predict = {}
    for prediction in results.predictions:
        predict[prediction.tag_name] = prediction.probability 

    return predict # 予測を辞書で返却



app = Flask(__name__)

@app.route('/route', methods=["POST"])
def main():
    # json_data = request.get_json()
    # print(json_data)
    # weight = float(json_data.get("weight"))
    # coefficient = json_data.get("coefficient")

    #《追加》=======================================================================
    # 画像をazureにぶん投げて結果を取得
    img = request.files['image_file'] 
    weight = request.files["weight"].filename
    azure_results = azure_request(img) 
    # ['normal: 65.00%', 'slender: 56.72%', 'fat: 9.45%']こんな感じで帰ってくる
    print("[DEBUG] azure_results: ", azure_results)

    # fat指数（適当）
    fat = azure_results["slender"]*(-1) + azure_results["fat"]*1 + 1
    #=======================================================================
    print("[DEBUG] fat指数: ", fat)
    
    #TODO:POSTされた画像データを扱う
    #img = img_parser(json_data.get("img"))

    rep = calc_rep(float(weight))
    der = calc_der(rep, fat)
    dst = ideal_walk_dst(der, float(weight))



    print("[DEBUG] distance: "+str(dst))

    payload = {
        "result":True,
        "data":{
            "distance": dst,
        }
    }
    
    return jsonify(payload)

if __name__ == "__main__":
    app.run(debug=True, host='localhost', port=5678)