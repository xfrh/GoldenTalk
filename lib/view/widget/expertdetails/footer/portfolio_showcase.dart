import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../manager/expertmanager.dart';
import '../../../../service/auth_service.dart';
import '../../../../service/locator.dart';
import '../../../../service/models/expert_model.dart';
import '../../../detailimage_screen.dart';
import 'package:path/path.dart' as Path;

class PortfolioShowcase extends StatefulWidget {
  PortfolioShowcase(this._expert);
  final Expert _expert;
  final _expertMgr = locator<ExpertManager>();
  final _auth = locator<AuthService>();
  @override
  _PortfolioShowcaseState createState() => _PortfolioShowcaseState();
}

class _PortfolioShowcaseState extends State<PortfolioShowcase> {
  String _filePath;
  File imageFile;
  FirebaseUser _currentUser;
  List<Widget> _buildReadonlyItems() {
    var items = <Widget>[];
    widget._expert.portfolios.forEach((item) {
      var image = new GestureDetector(
          onTap: () => {
                if (item.contains('http'))
                  Navigator.pushNamed(context, DetailScreen.routeName,
                      arguments: item)
              },
          child: item.contains('http')
              ? Image.network(item, width: 200.0, height: 200.0)
              : Image.asset(item, width: 200.0, height: 200.0));
      items.add(image);
    });
    return items;
  }

  List<Widget> _buildItems() {
    var items = <Widget>[];
    for (var i = 0; i < widget._expert.portfolios.length; i++) {
      if (widget._expert.portfolios[i].contains('http')) {
        var image = new GestureDetector(
          onTap: () => {
            Navigator.pushNamed(context, DetailScreen.routeName,
                arguments: widget._expert.portfolios[i])
          },
          child: Slidable(
            actionPane: SlidableScrollActionPane(),
            actionExtentRatio: 0.25,
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: 'delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => {_delete(i)},
              ),
            ],
            child: Image.network(widget._expert.portfolios[i],
                width: 200.0, height: 200.0),
          ),
        );

        items.add(image);
      } else {
        var image = Slidable(
          actionPane: SlidableScrollActionPane(),
          actionExtentRatio: 0.25,
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'update',
              color: Colors.amberAccent,
              icon: Icons.update,
              onTap: () => {_openGallery(i)},
            ),
          ],
          child: Image.asset(widget._expert.portfolios[i],
              width: 200.0, height: 200.0),
        );
        items.add(image);
      }
    }
    return items;
  }

  _openGallery(int index) async {
    this.imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    await uploadFile(index);
  }

  _update(int index) {
    widget._expert.portfolios[index] = _filePath;
    widget._expertMgr.updateExpert(widget._expert, widget._expert.expertID);
    setState(() {
      _filePath = '';
    });
  }

  Future uploadFile(int index) async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('/portfolio/${Path.basename(this.imageFile.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(this.imageFile);
    await uploadTask.onComplete;
    // print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      this._filePath = fileURL;
      _update(index);
    });
  }

  _delete(int index) {
    widget._expert.portfolios[index] =
        'images/portfolio_${(index + 1).toString()}.jpeg';
    widget._expertMgr.updateExpert(widget._expert, widget._expert.expertID);
    setState(() {
      _filePath = '';
    });
  }

  @override
  void initState() {
    setState(() {
      _currentUser = widget._auth.activeUser;
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var delegate = new SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 0.0,
    );

    return _currentUser == null
        ? Container()
        : new GridView(
            padding: const EdgeInsets.only(top: 16.0),
            gridDelegate: delegate,
            children: _currentUser.uid == widget._expert.uid
                ? _buildItems()
                : _buildReadonlyItems(),
          );
  }
}
