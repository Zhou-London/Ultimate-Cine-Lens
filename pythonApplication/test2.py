from openai import OpenAI
import base64
from respondStructure import AnalyseStructure, Action


def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode("utf-8")


apiKey = ''

with open('dashscope_api_key.txt', 'r') as f:
    apiKey = f.read()

image = encode_image('videoTest/exampleByFrame/0.jpg')


client = OpenAI(
    api_key=apiKey,
    base_url="https://dashscope.aliyuncs.com/compatible-mode/v1"
)

completion = client.beta.chat.completions.parse(
    model="qwen-vl-plus-latest",
    messages=[
        {"role": "system", "content": "Please analyse the frame using the structure provided. If there is no that element, write 'No'. Scene and action start from 1."},
        {"role": "user", "content": [
            {"type": "image_url", "image_url": {"url": f"data:image/jpg;base64,{image}"}}
        ]}
    ],
    response_format=Action,
)

parsed = completion.choices[0].message.parsed

structure = {
    'scene': parsed.scene,
    'action': parsed.action,
    'description': parsed.description,
    'dramaticAction': {
        'gesture': parsed.dramaticAction.Gesture,
        'facialExpression': parsed.dramaticAction.FacialExpression,
        'movement': parsed.dramaticAction.Movement,
        'costume': parsed.dramaticAction.Costume,
    },
    'filming': {
        'shotType': parsed.filming.shotType.value,
        'shotAngleAndPosition': parsed.filming.shotAngleAndPosition.value,
        'cameraMovement': parsed.filming.cameraMovement.value,
    },
    'editing': {
        'transition': parsed.editing.Transition
    }
}
print(structure)

print(completion.choices[0].message.parsed)