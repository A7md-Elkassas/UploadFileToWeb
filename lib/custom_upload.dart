import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class CustomFileUpload extends StatefulWidget {
  @override
  createState() => _FileUploadAppState();
}

class _FileUploadAppState extends State<CustomFileUpload> {
  List<int> _pickedFile;
  Uint8List _bytesData;
  InputElement input;
  Response response;
  double actualPercentage;
  double percentage = 0;
  String uploadMsg = '';
  pickFile() async {
    input = FileUploadInputElement();
    input.multiple = true;
    input.draggable = true;
    input.click();

    input.onChange.listen((e) {
      final files = input.files;
      final file = files[0];
      final reader = FileReader();

      reader.onLoadEnd.listen((e) {
        _handleResult(reader.result);
      });
      reader.readAsDataUrl(file);
    });
  }

  void _handleResult(Object result) {
    setState(() {
      _bytesData = Base64Decoder().convert(result.toString().split(",").last);
      _pickedFile = _bytesData;
    });
  }

  uploadFile(BuildContext ctx) async {
    FormData formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(
        _pickedFile,
        filename: input.files.first.name,
      ),
    });

    Response response = await Dio().post("http://192.168.1.3/file_upload.php",
        data: formData, onReceiveProgress: (sent, total) {
      double percentage = ((sent / total) * 100).floorToDouble();
      actualPercentage = (percentage / 100);
      if (percentage < 100) {
        setState(() {
          uploadMsg = 'uploading ${percentage.toString()}%';
          print('uploading ${percentage.toString()}%');
        });
      } else {
        setState(() {
          uploadMsg = 'Uploaded Successfully';
          print('Uploaded Successfully');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Choose file to upload'),
          centerTitle: true,
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  child: actualPercentage == null
                      ? Text("")
                      : Container(
                          width: 250,
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              LinearProgressIndicator(
                                minHeight: 8,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.red),
                                value: actualPercentage,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                uploadMsg ?? '',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  //show file name here
                  child: input == null
                      ? Text("No File Chosen")
                      : Text(basename(input.files.first.name)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: RaisedButton.icon(
                        onPressed: () {
                          pickFile();
                        },
                        icon: Icon(Icons.folder_open),
                        label: Text("Choose File"),
                      ),
                    ),
                    const SizedBox(width: 15),
                    input == null
                        ? Container()
                        : Container(
                            child: RaisedButton.icon(
                            onPressed: () {
                              uploadFile(context);
                            },
                            icon: Icon(Icons.folder_open),
                            label: Text("Upload File"),
                          )),
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}
