from azure.cognitiveservices.vision.customvision.prediction import CustomVisionPredictionClient
from msrest.authentication import ApiKeyCredentials



def azure_request():
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
        open("../data/dog/142520422.jpg", "rb").read()
        )

    predict = {}
    for prediction in results.predictions:
        predict[prediction.tag_name] = prediction.probability 

    return predict # 予測を辞書で返却




results = azure_request()
print(results)
# predict = []
# for prediction in results.predictions:
#     predict.append(prediction.tag_name + ": {0:.2f}%".format(prediction.probability * 100)))