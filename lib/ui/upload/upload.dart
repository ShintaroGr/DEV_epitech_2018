import 'dart:convert';

import 'package:dev_epicture_2018/account.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Upload extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UploadState();
}

class _ImgurData {
  String title = '';
  String description = '';
  String image = '';
}

class _UploadState extends State<Upload> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _data = _ImgurData();
  bool _uploading = false;

  Future getGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    List<int> imageBytes = image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  Future getCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    List<int> imageBytes = image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  void submit() async {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _uploading = true;
      });
      http.Response response = await http.post(
        'https://api.imgur.com/3/image?client_id=4525911e004914a',
        headers: await Account.getHeader(context: context, important: true),
        body: {"image": _data.image, "title": _data.title, "description": _data.description},
      );
      setState(() {
        _uploading = false;
      });
      if (json.decode(response.body)["success"]) {
        Scaffold.of(context).showSnackBar(
          new SnackBar(
            content: new Text(
              "Image Uploaded",
              textAlign: TextAlign.center,
            ),
          ),
        );
      } else {
        Scaffold.of(context).showSnackBar(
          new SnackBar(
            content: new Text(
              "Failed",
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _uploading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              alignment: FractionalOffset(0.5, 0.5),
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: this._formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Title',
                        filled: true,
                        fillColor: Colors.white70,
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(50.0),
                          ),
                        ),
                      ),
                      onSaved: (String value) {
                        this._data.title = value;
                      },
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.white30,
                          onPressed: () async {
                            this._data.image = await getCamera();
                          },
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                        RaisedButton(
                          color: Colors.white30,
                          onPressed: () async {
                            this._data.image = await getGallery();
                          },
                          child: Icon(
                            Icons.photo,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: RaisedButton(
                        shape: StadiumBorder(),
                        child: Text(
                          'Upload',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => submit(),
                        color: Colors.white30,
                      ),
                      margin: EdgeInsets.only(top: 20.0),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
