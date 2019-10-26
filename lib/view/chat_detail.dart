import 'dart:io';

import 'package:antalya/view/fullPhoto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../const.dart';

class ChatDetail extends StatefulWidget {
  final String name;
  final String imgurl;
  final String chatId;
  final String peerId;
  final String id;

  ChatDetail({this.name, this.id, this.peerId, this.imgurl, this.chatId});

  @override
  State<StatefulWidget> createState() => _chatState();
}

class _chatState extends State<ChatDetail> {
  List messages = new List();
  File imageFile;
  bool isLoading;
  String imageUrl;
  var listMessage;

  final ScrollController listScrollController = new ScrollController();
  final TextEditingController textEditingController =
      new TextEditingController();

  @override
  void initState() {
    isLoading = false;
    imageUrl = '';
    super.initState();
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image
    if (content.trim() != '') {
      textEditingController.clear();
      var documentReference = Firestore.instance
          .collection('messages')
          .document(widget.chatId)
          .collection('messages')
          .document(DateTime.now().toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': widget.id, //userId
            'idTo': widget.peerId, //receiverId
            'timestamp': DateTime.now().toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  Widget buildListMessage() {
    return Flexible(
      child: widget.chatId == ''
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    print(document);
    if (document['idFrom'] == widget.id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document['type'] == 0
              // Text
              ? Container(
                  child: Stack(children: <Widget>[
                    Text(
                      document['content'],
                      style: TextStyle(color: Colors.black),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 1,
                      child: Text(
                        DateFormat('kk:mm').format(
                            DateTime.parse(document['timestamp'])),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: greyColor,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                    )
                  ]),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Color(0xffDCF8C6),
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : document['type'] == 1
                  // Image
                  ? Container(
                      child: FlatButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: Color(0xDCF8C6),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document['content'],
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FullPhoto(url: document['content'])));
                        },
                        padding: EdgeInsets.all(0),
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
                  // Sticker
                  : Container(
                      child: new Image.asset(
                        'images/${document['content']}.gif',
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
//                isLastMessageLeft(index)
//                    ? Material(
//                        child: CachedNetworkImage(
//                          placeholder: (context, url) => Container(
//                            child: CircularProgressIndicator(
//                              strokeWidth: 1.0,
//                              valueColor:
//                                  AlwaysStoppedAnimation<Color>(themeColor),
//                            ),
//                            width: 35.0,
//                            height: 35.0,
//                            padding: EdgeInsets.all(10.0),
//                          ),
//                          imageUrl: widget.imgurl,
//                          width: 35.0,
//                          height: 35.0,
//                          fit: BoxFit.cover,
//                        ),
//                        borderRadius: BorderRadius.all(
//                          Radius.circular(18.0),
//                        ),
//                        clipBehavior: Clip.hardEdge,
//                      )
//                    : Container(width: 35.0),
                document['type'] == 0
                    ? Container(
                        child: Stack(
                          children: <Widget>[
                            Text(
                              document['content'],
                              style: TextStyle(color: Colors.black),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 1,
                              child: Text(
                                DateFormat('kk:mm').format(
                                    DateTime.parse(document['timestamp'])),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    color: greyColor,
                                    fontSize: 12.0,
                                    fontStyle: FontStyle.italic),
                              ),
                            )
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : document['type'] == 1
                        ? Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          themeColor),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xDCF8C6),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      'images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document['content'],
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullPhoto(
                                            url: document['content'])));
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        : Container(
                            child: new Image.asset(
                              'images/${document['content']}.gif',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ),
              ],
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == widget.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != widget.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        titleSpacing: -15.0,
        title: new Row(
          children: <Widget>[
            new FlatButton.icon(
              icon: new CircleAvatar(
                  backgroundImage: new NetworkImage(widget.imgurl)),
              label: new Text(
                widget.name,
                style: new TextStyle(color: Colors.white, fontSize: 18.0),
              ),
              onPressed: () {},
            ),
            //  new Text(widget.name),
          ],
        ),
        actions: <Widget>[
          new Icon(Icons.videocam),
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
          ),
          new Icon(Icons.call),
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
          ),
          new Icon(Icons.more_vert)
        ],
      ),
      body: new Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new NetworkImage(
                    "https://i.pinimg.com/originals/8f/ba/cb/8fbacbd464e996966eb9d4a6b7a9c21e.jpg"),
                fit: BoxFit.fitWidth)),
        child: new Column(
          children: <Widget>[
            new Flexible(
                child: new Column(
              children: <Widget>[
                buildListMessage(),
              ],
            )),
            new Row(children: <Widget>[
              new Flexible(
                  child: new Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: new TextField(
                    controller: textEditingController,
                    onChanged: (st) {
                      setState(() {});
                    },
                    decoration: new InputDecoration(
                      prefixIcon:
                          new Icon(Icons.insert_emoticon, color: Colors.grey),
                      hintText: "Type a message",
                      suffixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: new Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(const Radius.circular(30.0)),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
              )),
              new Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  child: new IconButton(
                    icon: new Icon(
                      textEditingController.text.length == 0
                          ? Icons.mic
                          : Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (textEditingController.text.length != 0) {
                        onSendMessage(textEditingController.text, 0);
                      }
                    },
                  ))
            ])
          ],
        ),
      ),
    ); //modified
  }
}
