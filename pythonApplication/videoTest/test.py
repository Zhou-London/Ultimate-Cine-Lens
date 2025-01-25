import cv2

video = cv2.VideoCapture('videoTest/example.mp4')

count = 0

totalFrame = 0

while True:
    ret, frame = video.read()


    if count == 0:
        # cv2.imshow('Video', frame)
        cv2.imwrite(f'videoTest/exampleByFrame/{totalFrame}.jpg', frame)
        totalFrame += 1

    count += 1
    if count == 15:
        count = 0

    if not ret:
        break
    
    # if cv2.waitKey(25) & 0xFF == ord('q'):
    #     break

video.release()
cv2.destroyAllWindows()
print(totalFrame)