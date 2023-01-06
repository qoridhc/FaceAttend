import threading

import numpy as np
import requests
from deepface import DeepFace
from retinaface import RetinaFace
import cv2
import os
from operator import itemgetter
import asyncio
from firebase_db import FirebaseDB
import tkinter
import tkinter.messagebox as msgbox
from tkinter import *
from PIL import Image
from PIL import ImageTk

import firebase_admin
from firebase_admin import credentials
from firebase_admin import db

#Firebase database 인증 및 앱 초기화
cred = credentials.Certificate('firebaseAccountKey.json')
firebase_admin.initialize_app(cred,{
    'databaseURL' : 'https://capston-d05a1-default-rtdb.asia-southeast1.firebasedatabase.app/'
})

# ref = db.reference('이미지') #경로가 없으면 생성.
# ref.update({'22-11-20 20:23:59' : 'https://firebasestorage.googleapis.com/v0/b/capston-d05a1.appspot.com/o/%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7_20221011_112435.png?alt=media&token=22175628-bc75-477c-9db9-4e8ee41022cf'})
# ref.update({'22-11-21 22:33:33' : 'https://firebasestorage.googleapis.com/v0/b/capston-d05a1.appspot.com/o/nine_test.jpg?alt=media&token=db64fbf0-791f-4a79-8116-31931b813d85'})

dbPath = "name/"  # 비교할 얼굴 데이터가 들어있는 폴더 경로

imgSize = 1
threshold = 0.60  # 임계값 설정
file_list = os.listdir(dbPath)
for i in range(len(file_list)):
    print(file_list[i])

statistic = []

root = tkinter.Tk()
root.title("face_detection")
root.geometry("800x600")
root.resizable(0, 0)
label = tkinter.Label(root)

def compareFace(img):
    faceCompareInfoList = []

    # db_path의 이미지와 파라미터로 들어온 이미지의 얼굴 좌표값을 비교해서 리턴
    for i in range(len(file_list)):
        dir_name = file_list[i]

        img_list = os.listdir(dbPath + dir_name)
        faceDiffAverage = 0;
        for i in range(len(img_list)):
            result = DeepFace.verify(img, dbPath + dir_name + "/" + img_list[i], enforce_detection=False,
                                     model_name="ArcFace", detector_backend="retinaface")
            print(dir_name, result['distance'])
            faceDiffAverage += result['distance']

        faceDiffAverage /= len(img_list)

        faceCompareInfoList.append(dict(name=dir_name, faceDiffAverage=faceDiffAverage))

    faceCompareInfoList = sorted(faceCompareInfoList, key=itemgetter('faceDiffAverage'))
    statistic.append(
        dict(name=faceCompareInfoList[0]['name'], value=faceCompareInfoList[0]['faceDiffAverage']))  # 얼굴 값 통계 입력

    if (len(faceCompareInfoList) != 0 and faceCompareInfoList[0]['faceDiffAverage'] <= threshold):  # 만약 얼굴을 찾고 비교값이 임계값 이하라면 그사람정보를 반환
        return faceCompareInfoList[0]['name']
    else:  # currIndex == -1 이면 얼굴을 찾지 못한것이므로 -1 리턴
        return -1

def notFoundFaceMsg():
    return msgbox.showinfo("알림","얼굴이 존재하지 않는 이미지입니다. 새로운 이미지로 시도해주세요");

def startFaceDetection():
    print("startFaceDetection 실행" )
    faceInfoList = []

    data = db.reference('FaceImages').get()
    a = sorted(data.keys())[-1]
    url = data[a]['imageUrl']

    image_nparray = np.asarray(bytearray(requests.get(url).content), dtype=np.uint8)
    mainImg = cv2.imdecode(image_nparray, cv2.IMREAD_COLOR)
    faces = RetinaFace.detect_faces(mainImg)

    if(len(faces) <= 0):
        notFoundFaceMsg()
        return

    aligned_face = RetinaFace.extract_faces(mainImg, align=True)

    for i, face in enumerate(faces):
        identity = faces[face]

        # plt.imshow(aligned_face[i])
        # plt.show()

        detectResult = compareFace(aligned_face[i])

        detectName = -1
        if (detectResult != -1):
            detectName = detectResult

        faceInfoList.append(dict(name=detectName, facial_area=identity["facial_area"]))

    for i in range(len(faceInfoList)):
        currFaceName = faceInfoList[i]['name']
        currFaceFacialArea = faceInfoList[i]['facial_area']

        y = currFaceFacialArea[1] - 15 if currFaceFacialArea[1] - 15 > 15 else currFaceFacialArea[1] + 15

        if (currFaceName != -1):  # 누군지 특정 성공하면 초록색박스 + 해당 사람 이름 표시
            cv2.rectangle(mainImg, (currFaceFacialArea[2], currFaceFacialArea[3])
                          , (currFaceFacialArea[0], currFaceFacialArea[1]), (0, 255, 0), 4)

            cv2.putText(mainImg, currFaceName, (currFaceFacialArea[0], y), cv2.FONT_HERSHEY_SIMPLEX,
                        2, (0, 255, 0), 3)
        else:
            cv2.rectangle(mainImg, (currFaceFacialArea[2], currFaceFacialArea[3])
                          , (currFaceFacialArea[0], currFaceFacialArea[1]), (0, 0, 255), 4)

            cv2.putText(mainImg, "Unknown", (currFaceFacialArea[0], y), cv2.FONT_HERSHEY_SIMPLEX,
                        2, (0, 0, 255), 3)

    print(statistic)

    for arr in statistic:
        if(arr['value'] <= threshold):
            name = arr['name']
            ref = db.reference('Attendance')  # 경로가 없으면 생성한다.
            ref.update({name : '출석'})

    mainImg = cv2.resize(mainImg, (700, 550))
    img = cv2.cvtColor(mainImg, cv2.COLOR_BGR2RGB)
    img = Image.fromarray(img)
    imgtk = ImageTk.PhotoImage(image=img)

    label.config(image =  imgtk)
    label.image = imgtk  # class 내에서 작업할 경우에는 이 부분을 넣어야 보임.
    label.pack(side="top")
def msgInfo():
    return msgbox.askokcancel("알림","새로운 이미지가 감지되었습니다 얼굴인식을 진행하시겠습니까?")

def listener(event):
    # print(event.event_type)  # can be 'put' or 'patch'
    # print(event.path)  # relative to the reference, it seems
    # print(event.data)  # new data at /reference/event.path. None if deleted
    print("listener 실행")
    if(event.event_type == "patch"):
        if(msgInfo() == True):
            startFaceDetection()

if __name__ == '__main__':
    ref = db.reference('FaceImages')
    ref.listen(listener)
    root.mainloop()
