import requests
import json

post_url = "http://localhost:5678/route"

#postしたいデータ


#POST送信
response = requests.post(post_url, files = {
     "weight": ("12.0", "", "text/plain; charset=UTF-8"),
     "image_file": ("sample.jpeg", open('./sample.jpeg', 'rb'), "image/png")
     })

print(response.json())