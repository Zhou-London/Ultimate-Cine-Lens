from flask import Flask, request, jsonify
from process import processImage

app = Flask(__name__)
totalImage = {}

@app.route('/api', methods=['GET'])
def helloWorld():
    d = {}
    d['alpha'] = str(request.args['alpha'])
    return jsonify(d)

@app.route('/image-path', methods=['POST'])
def process():
    imagePath = str(request.json)
    print(imagePath)
    if imagePath not in totalImage:
        imageStructure = processImage(imagePath)
        totalImage[imagePath] = imageStructure
        return jsonify(imageStructure)
    else:
        return jsonify(totalImage[imagePath])


if __name__ == '__main__':
    app.run(debug=True)
