import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:face_check/firebase/firebase_database.dart';
import 'package:face_check/firebase/firebase_storage.dart';



class ImageModel {

  String? uid;
  String? createdAt;
  String? imageUrl;
  String? professor;
  String? lecture;
  String? startAt;
  String? endAt;
  int? roomNumber;

  ImageModel({
    this.uid,
    this.imageUrl,
    this.createdAt,
    this.professor,
    this.lecture,
    this.startAt,
    this.endAt,
    this.roomNumber,
  });

  ImageModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    createdAt = json['createdAt'];
    imageUrl = json['imageUrl'];
    createdAt = json['createdAt'];
    professor = json['professor'];
    lecture = json['lecture'];
    startAt = json['startAt'];
    endAt = json['endAt'];
    roomNumber = json['roomNumber'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['uid'] = uid;
    data['imageUrl'] = imageUrl;
    data['createdAt'] = createdAt;
    data['professor'] = professor;
    data['lecture'] = lecture;
    data['startAt'] = startAt;
    data['endAt'] = endAt;
    data['roomNumber'] = roomNumber;

    return data;
  }

}

String parseDateTime(String dateTime) {
  DateTime temp = DateTime.parse(dateTime);
  String parsed = DateFormat('yyyy-MM-dd hh:mm:ss').format(temp);

  return parsed;
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin{

  final DatabaseReference dbFaceRef = FirebaseDatabase.instance.ref('FaceImages');
  final DatabaseReference dbAttendanceRef = FirebaseDatabase.instance.ref('Attendance');


  ValueNotifier<XFile?> imageFile = ValueNotifier<XFile?>(null);

  ImagePicker picker = ImagePicker();

  List<ImageModel> photoLog = [];

  List<Map<String, dynamic>> attendanceResult = [];

  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPermission();
    });
  }

  Future getPermission() async{
    // PermissionStatus photo = await Permission.photos.request();

    // Access Camera
    PermissionStatus camera = await Permission.camera.request();

    if(camera.isGranted){
      return true;
    }

    return false;
  }

  Map<String, dynamic> convertObjectToJson(Object? object) {
    Map<String, dynamic> jsonData = jsonDecode(jsonEncode(object));
    return jsonData;
  }

  void setLog(DatabaseEvent data) {
    photoLog.clear();

    photoLog = data.snapshot.children.map((e) {
      return ImageModel.fromJson(convertObjectToJson(e.value));
    }).toList().where((element) {
      if (element.professor == '홍동권' &&
          element.lecture == '컴퓨터공학캡스톤디자인(1)' &&
          element.roomNumber == 1314) {
        print(element.toJson());
        return true;
      }
      return false;
    }).toList();
  }

  void setAttendanceResult(DatabaseEvent data) {
    attendanceResult.clear();

    data.snapshot.children.forEach((element) {
      print(element.key);
      print(element.value);
      Map<String, dynamic> attendance = {element.key.toString(): element.value.toString()};
      attendanceResult.add(attendance);
    });
  }


  Future<void> takePhoto() async{
    XFile? image = await picker.pickImage(source: ImageSource.camera);

    if(image == null) return;
    imageFile.value = image;
    setState(() { });
  }

  Future<void> accessGallery() async{
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if(image == null) return;
    imageFile.value = image;
    setState(() { });
  }

  Future<bool> addImage() async{
    if(imageFile.value == null){
      return false;
    }

    Reference reference = await FireBaseFileStorageService().createSource(
      FirebaseStorage.instance.ref('FaceImages'),
      'capston/',
      File(imageFile.value!.path),
    );

    String imageUrl = await reference.getDownloadURL();

    String key = parseDateTime(DateTime.now().toString());

    Map<String, dynamic> data = ImageModel(
      uid: key,
      imageUrl: imageUrl,
      createdAt: key,
      professor: '홍동권',
      lecture: '컴퓨터공학캡스톤디자인(1)',
      startAt: 'T13:00:00',
      endAt: 'T16:50:00',
      roomNumber: 1314,
    ).toJson();

    try{
      await dbFaceRef.child(key).update(data);
      imageFile.value = null;

      return true;
    } catch(error){
      print('Error Of Create Data: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home Screen', textScaleFactor: 1.4,),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 20, right: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 이미지 추가 및 선택한 이미지 취소하기
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => imageFile.value = null,
                          child: Text('취소'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () async => await addImage(),
                              child: Text('전송'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async => await takePhoto(),
                              child: Text('촬영'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async => await accessGallery(),
                              child: Text('갤러리'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // 선택한 이미지 보여주기
                    ValueListenableBuilder<XFile?>(
                      valueListenable: imageFile,
                      builder: (_, __, ___) {
                        return imageFile.value != null ?
                        SizedBox(
                          width: width,
                          height: width,
                          child: Image.file(
                            File(imageFile.value!.path),
                            fit: BoxFit.cover,
                          ),
                        ) : Container(
                          color: Colors.grey.shade200,
                          width: width,
                          height: width,
                          child: Center(
                            child: InkWell(
                              onTap: () async => await takePhoto(),
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('출석할 이미지 추가하기', textScaleFactor: 1.2,),
                                    Icon(Icons.camera_alt_outlined),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // 해당 수업 출석체크 기록
              TabBar(
                controller: tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey.shade600,
                tabs: [
                  Tab(text: '촬영내역'),
                  Tab(text: '출결정보',),
                ],
                onTap: (_) => setState(() {

                }),
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    /// 출석용 사진 촬영 내역 리스트
                    Builder(
                      builder: (_) {
                        return StreamBuilder<DatabaseEvent>(
                          stream: dbFaceRef.orderByChild('createdAt').onValue,
                          builder: (_, snapshot) {
                            if(!snapshot.hasData) {
                              return Center(
                                child: Text(
                                  '해당 수업의 출석 기록이 존재하지 않습니다.',
                                  textScaleFactor: 1.5,
                                ),
                              );
                            }

                            setLog(snapshot.data!);

                            return ListView.separated(
                              shrinkWrap: true,
                              itemCount: photoLog.length,
                              separatorBuilder: (_, index) => Divider(
                                height: 0.0,
                                color: Colors.grey.shade400,
                                thickness: 2.0,
                              ),
                              itemBuilder: (_, index) => LogTile(imageModel: photoLog[index]),
                            );
                          },
                        );
                      },
                    ),
                    // 학생 출석 현황 리스트
                    Builder(
                      builder: (_) {
                        return StreamBuilder<DatabaseEvent>(
                          stream: dbAttendanceRef.onValue,
                          builder: (_, snapshot) {
                            if(!snapshot.hasData) {
                              return Center(
                                child: Text(
                                  '해당 수업의 출석 기록이 존재하지 않습니다.',
                                  textScaleFactor: 1.5,
                                ),
                              );
                            }

                            setAttendanceResult(snapshot.data!);

                            return ListView.separated(
                              shrinkWrap: true,
                              itemCount: attendanceResult.length,
                              separatorBuilder: (_, index) => Divider(
                                height: 0.0,
                                color: Colors.grey.shade400,
                                thickness: 2.0,
                              ),
                              itemBuilder: (_, index) {
                                String studentNumber = attendanceResult[index].keys.toList().first;
                                String attendance = attendanceResult[index][studentNumber].toString();

                                return Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(studentNumber, textScaleFactor: 1.3,),
                                      Text(
                                        attendance,
                                        style: TextStyle(
                                          color: attendance == "결석"
                                              ? Colors.red : Colors.blue,
                                        ),
                                        textScaleFactor: 1.25,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogTile extends StatefulWidget {

  final ImageModel imageModel;

  const LogTile({
    required this.imageModel,
    Key? key,
  }) : super(key: key);

  @override
  State<LogTile> createState() => _LogTileState();
}

class _LogTileState extends State<LogTile> {

  final double textScale = 1.1;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(
        left: 15, right: 15,
        top: 15, bottom: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: CachedNetworkImage(
              // color: Colors.white,
              fit: BoxFit.contain,
              imageUrl: widget.imageModel.imageUrl.toString(),
              errorWidget: (_, __, ___) => const Icon(
                Icons.error_outline,
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        parseDateTime(widget.imageModel.createdAt.toString()),
                        textScaleFactor: textScale,
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () async{
                          String message = '${widget.imageModel.createdAt}에 올린 사진이 삭제되었습니다.';
                          String url = widget.imageModel.imageUrl!;
                          await FirebaseRealTimeDatabase().remove(
                            reference: FirebaseDatabase.instance.ref('FaceImages').child(parseDateTime(widget.imageModel.uid!)),
                            data: widget.imageModel.toJson(),
                          );

                          await FireBaseFileStorageService().deleteSource(url);

                          if(!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 2),
                              margin: const EdgeInsets.all(20),
                              behavior: SnackBarBehavior.floating,
                              content: Text(message, textScaleFactor: 1.1,),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          color: Colors.amber,
                          child: Text(
                            '삭제',
                            textScaleFactor: textScale,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        '${widget.imageModel.professor}/${widget.imageModel.lecture}'
                            '/${widget.imageModel.roomNumber}',
                        textScaleFactor: textScale,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

