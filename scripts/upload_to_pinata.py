# pinata makes it easier to work with IPFS
# pin the images that we run on IPFS
import os
from pathlib import Path
import requests

PINATA_BASE_URL = "https://api.pinata.cloud/"
endpoint = "pinning/pinFileToIPFS"
# change this filepath or make a for loop to go through all the files
filepath = "./img/st-bernard.png"
filename = filepath.split("/")[-1][0]
headers = {
    "pinata_api_key": os.getenv("PINATA_API_KEY"),
    "pinata_secret_api_key": os.getenv("PINATA_API_SECRET"),
}


def main():
    with Path(filepath).open("rb") as fp:
        image_binary = fp.read()
        response = requests.post(
            PINATA_BASE_URL + endpoint,
            files={"file": (filename, image_binary)},
            headers=headers,
        )
        print(response.json())
