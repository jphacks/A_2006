import requests
import json


def main():
    files = { "image_file": open("../data/dog/142520422.jpg", 'rb') }
    data = {"weight":50, "coefficient":50}
    response = requests.post("http://127.0.0.1:5678/route", files=files, json=json.dumps(data)) 
    results = response.json()
    
    return results


if __name__ == "__main__":
    results = main()
    print(results)