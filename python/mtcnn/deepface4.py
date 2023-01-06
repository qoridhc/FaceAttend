import cv2
from deepface import DeepFace
from mtcnn import MTCNN

dbPath = "name" # 비교할 얼굴 데이터가 들어있는 폴더 경로
imgPath = "dataset/three.jpg" # 비교할 이미지

model = MTCNN()
detector = MTCNN()

imgSize = 1
threshold = 0.35 # 임계값 설정

# cap = cv2.VideoCapture('../video.mp4')
# cap = cv2.VideoCapture(1)

def detectFromData(img): # 이미지 내부 얼굴 추출

    # db_path의 이미지와 파라미터로 들어온 이미지의 얼굴 좌표값을 비교해서 리턴
    df = DeepFace.find(img_path=img, db_path=dbPath, enforce_detection=False)
    print(df)
    currIndex = -1
    currDiff = 100

    for faceDiff in enumerate(df['VGG-Face_cosine']): # 비교값들중 가장 근접한 얼굴 찾기
        if(currDiff>faceDiff[1]):
            currDiff = faceDiff[1]
            currIndex = faceDiff[0]

    if(currIndex != -1 and currDiff <= threshold): # 만약 얼굴을 찾고 비교값이 임계값 이하라면 그사람정보를 반환
        return df['identity'][currIndex]
    else: # currIndex == -1 이면 얼굴을 찾지 못한것이므로 -1 리턴
        return -1

for i in range(imgSize):

    frame = cv2.imread(imgPath)

    # 임베딩 좌표값 출력
    # embedding = DeepFace.represent(frame, enforce_detection=False)
    # print(embedding)

    # Use MTCNN to detect faces
    result = detector.detect_faces(frame) # mtcnn 기반으로 얼굴 위치 좌표값 찾기
    print(result)

    if result != []: # 찾은 얼굴위치를 하나씩 루프에 넣어서 연산 수행
        for person in result:
            bounding_box = person['box']
            print(bounding_box)
            # 좌표값에 해당하는 사람 얼굴 자르기
            cropped_img = frame[bounding_box[1]:bounding_box[1] + bounding_box[3], bounding_box[0]: bounding_box[0] + bounding_box[2]]
            cv2.imshow('crop', cropped_img)
            # x y w h
            cv2.waitKey(0)

            detectFace = detectFromData(cropped_img) # 자른 얼굴 이미지 로컬에 저장된 얼굴 사진들과 비교
            y = bounding_box[1] - 15 if bounding_box[1] - 15 > 15 else bounding_box[1] + 15

            if (detectFace != -1): # 얼굴 비교했는데 누군지 찾지 못하면 빨간색박스 + unknown 표시
                cv2.rectangle(frame,
                              (bounding_box[0], bounding_box[1]),
                              (bounding_box[0] + bounding_box[2], bounding_box[1] + bounding_box[3]),
                              (0, 255, 0),
                              2)
                cv2.putText(frame, detectFace, (bounding_box[0], y), cv2.FONT_HERSHEY_SIMPLEX,
                            0.75, (0, 255, 0), 2)

            else: # 누군지 특정 성공하면 초록색박스 + 해당 사람 이름 표시
                cv2.rectangle(frame,
                              (bounding_box[0], bounding_box[1]),
                              (bounding_box[0] + bounding_box[2], bounding_box[1] + bounding_box[3]),
                              (0, 0, 255),
                              2)
                cv2.putText(frame, "unknown", (bounding_box[0], y), cv2.FONT_HERSHEY_SIMPLEX,
                            0.75, (0, 0, 255), 2)

    resize_img = cv2.resize(frame, (1000, 1000))

    cv2.imshow('1', resize_img)
    cv2.waitKey(0)

cv2.destroyAllWindows()
