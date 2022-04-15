import 'dart:convert';
import 'dart:io';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
// import 'package:firebase_admob/firebase_admob.dart';
import 'package:hookup4u/ads/ads.dart';
import 'package:image/image.dart' as i;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../util/Global.dart';
// import 'package:easy_localization/easy_localization.dart';

class EditProfile extends StatefulWidget {
  final UserModel currentUser;
  EditProfile(this.currentUser);

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  final TextEditingController aboutCtlr = new TextEditingController();
  final TextEditingController companyCtlr = new TextEditingController();
  final TextEditingController livingCtlr = new TextEditingController();
  final TextEditingController jobCtlr = new TextEditingController();
  final TextEditingController universityCtlr = new TextEditingController();
  bool visibleAge = false;
  bool visibleDistance = true;
  List<String> choice = [
    "Yes", "No"
  ];

  List<Map<String, dynamic>> listGender = [
    {'name': 'man', 'ontap': false},
    {'name': 'woman', 'ontap': false},
    {'name': 'other', 'ontap': false},
    {'name': 'agender', 'ontap': false},
    {'name': 'androgynous', 'ontap': false},
    {'name': 'bigender', 'ontap': false},
    {'name': 'gender fluid', 'ontap': false},
    {'name': 'gender non conforming', 'ontap': false},
    {'name': 'gender queer', 'ontap': false},
    {'name': 'gender questioning', 'ontap': false},
    {'name': 'intersex', 'ontap': false},
    {'name': 'non-binary', 'ontap': false},
    {'name': 'pangender', 'ontap': false},
    {'name': 'trans human', 'ontap': false},
    {'name': 'trans man', 'ontap': false},
    {'name': 'trans woman', 'ontap': false},
    {'name': 'transfeminime', 'ontap': false},
    {'name': 'transmasculine', 'ontap': false},
    {'name': 'two-spirit', 'ontap': false},
  ];
  List<Map<String, dynamic>> orientationlist = [
    {'name': 'straight', 'ontap': false},
    {'name': 'gay', 'ontap': false},
    {'name': 'lesbian', 'ontap': false},
    {'name': 'bisexual', 'ontap': false},
    {'name': 'bi-curious', 'ontap': false},
    {'name': 'pansexual', 'ontap': false},
    {'name': 'polysexual', 'ontap': false},
    {'name': 'queer', 'ontap': false},
    {'name': 'androgynobexual', 'ontap': false},
    {'name': 'androsexual', 'ontap': false},
    {'name': 'asexual', 'ontap': false},
    {'name': 'autosexual', 'ontap': false},
    {'name': 'demisexual', 'ontap': false},
    {'name': 'gray a', 'ontap': false},
    {'name': 'gynosexual', 'ontap': false},
    {'name': 'heteroflexible', 'ontap': false},
    {'name': 'homoflexible', 'ontap': false},
    {'name': 'objectumsexual', 'ontap': false},
    {'name': 'omnisexual', 'ontap': false},
    {'name': 'skoliosexual', 'ontap': false},
  ];
  List<Map<String, dynamic>> listStatus = [
    {'name': 'single', 'ontap': false},
    {'name': 'man + woman couple', 'ontap': false},
    {'name': 'man + man couple', 'ontap': false},
    {'name': 'woman + woman couple', 'ontap': false},
  ];
  List<Map<String, dynamic>> listDesire = [
    {'name': 'relationship', 'ontap': false},
    {'name': 'friendship', 'ontap': false},
    {'name': 'casual', 'ontap': false},
    {'name': 'fwb', 'ontap': false},
    {'name': 'fun', 'ontap': false},
    {'name': 'dates', 'ontap': false},
    {'name': 'texting', 'ontap': false},
    {'name': 'threesome', 'ontap': false},
  ];

  List<Map<String, dynamic>> listKinks = [
    {'name': 'role play', 'ontap': false},
    {'name': 'rope bondage', 'ontap': false},
    {'name': 'voyeurisms', 'ontap': false},
    {'name': 'exhibitionism', 'ontap': false},
    {'name': 'foot fetish', 'ontap': false},
    {'name': 'bdsm', 'ontap': false},
    {'name': 'dominant', 'ontap': false},
    {'name': 'submissive', 'ontap': false},
    {'name': 'switch', 'ontap': false},
    {'name': 'edge play', 'ontap': false},
    {'name': 'hot wifer', 'ontap': false},
    {'name': 'cuckolding', 'ontap': false},
  ];

  var selectionGender, selectionOrientation, selectionStatus;
  List selectedDesire = [];
  List selectedKinks = [];
  List selectedInterest = [];

  int selectionChoice = 0;

  var showMe;
  Map editInfo = {};
  Map<String, dynamic> orientationMap = {};
  Map<String, dynamic> statusMap = {};
  Map<String, dynamic> desiresMap = {};
  Map<String, dynamic> kinksMap = {};
  Map<String, dynamic> interestMap = {};
  int indexImage = 0;
  // Ads _ads = new Ads();
  // BannerAd _ad;
  @override
  void initState() {
    super.initState();
    aboutCtlr.text = widget.currentUser.editInfo['about'];
    companyCtlr.text = widget.currentUser.editInfo['company'];
    livingCtlr.text = widget.currentUser.editInfo['living_in'];
    universityCtlr.text = widget.currentUser.editInfo['university'];
    jobCtlr.text = widget.currentUser.editInfo['job_title'];
    setState(() {
      showMe = widget.currentUser.editInfo['userGender'];
      visibleAge = widget.currentUser.editInfo['showMyAge'] ?? false;
      visibleDistance = widget.currentUser.editInfo['DistanceVisible'] ?? true;
    });
    // _ad = _ads.myBanner();
    super.initState();
    initData();
    // _ad
    //   ..load()
    //   ..show();
  }

  initData(){

    // print(widget.currentUser.gender);
    selectionGender = widget.currentUser.gender;
    selectionOrientation = widget.currentUser.sexualOrientation;
    selectionStatus = widget.currentUser.status;
    print(widget.currentUser.desires);
    //init Desires
    if(widget.currentUser.desires.isNotEmpty){
      for(int i = 0; i<=widget.currentUser.desires.length-1; i++){
        selectedDesire.add(widget.currentUser.desires[i]);

        for(int j=0; j<=listDesire.length-1; j++){
          if(widget.currentUser.desires[i] == listDesire[j]['name']){
            listDesire[j]['ontap'] = true;
            break;
          }
        }

      }
    }

    //init Interest
    if(widget.currentUser.interest.isNotEmpty){
      for(int i = 0; i<=widget.currentUser.interest.length-1; i++){
        selectedInterest.add(widget.currentUser.interest[i]);
      }
    }

    //init Desires
    if(widget.currentUser.desires.isNotEmpty){
      for(int i = 0; i<=widget.currentUser.desires.length-1; i++){
        selectedDesire.add(widget.currentUser.desires[i]);

        for(int j=0; j<=listDesire.length-1; j++){
          if(widget.currentUser.desires[i] == listDesire[j]['name']){
            listDesire[j]['ontap'] = true;
            break;
          }
        }

      }
    }

  }

  @override
  void dispose() {
    super.dispose();
    print(editInfo.length);
    // if (editInfo.length > 0) {
      updateData();
    // }
    // _ads.disable(_ad);
  }

  Future updateData() async {
    Map<String, dynamic> updateMap = {};

    if(editInfo.length > 0){
      updateMap.addAll({'editInfo': editInfo, 'age': widget.currentUser.age});
    }
    if(orientationMap.length > 0){
      updateMap.addAll(orientationMap);
    }

    if(statusMap.length > 0){
      updateMap.addAll(statusMap);
    }

    if(desiresMap.length > 0){
      updateMap.addAll(desiresMap);
    }

    if(interestMap.length > 0){
      updateMap.addAll(interestMap);
    }

    if(kinksMap.length > 0){
      updateMap.addAll(kinksMap);
    }

    if(updateMap.length > 0 ){
      FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.currentUser.id)
          .set(updateMap,
          SetOptions(merge : true)
      );
    }

  }

  Future source(
      BuildContext context, currentUser, bool isProfilePicture, String show) async {


    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text(isProfilePicture
                  ? "Update profile picture"
                  : "Add pictures"),
              content: StatefulBuilder(
                builder: (BuildContext context2, StateSetter setState2){
                  return Column(
                    children: [
                      Text(
                        "Select source",
                      ),

                    ],
                  );
                },
              ),
              insetAnimationCurve: Curves.decelerate,
              actions: currentUser.imageUrl.length < 9
                  ? <Widget>[

                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GestureDetector(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.photo_camera,
                                size: 28,
                              ),
                              Text(
                                " Camera",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    decoration: TextDecoration.none),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            showDialog(
                                context: context,
                                builder: (context) {
                                  getImage(ImageSource.camera, context,
                                      currentUser, isProfilePicture, show);
                                  return Center(
                                      child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ));
                                });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GestureDetector(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.photo_library,
                                size: 28,
                              ),
                              Text(
                                " Gallery",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    decoration: TextDecoration.none),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  getImage(ImageSource.gallery, context,
                                      currentUser, isProfilePicture, show);
                                  return Center(
                                      child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ));
                                });
                          },
                        ),
                      ),
                    ]
                  : [
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Center(
                            child: Column(
                          children: <Widget>[
                            Icon(Icons.error),
                            Text(
                              "Can't uplaod more than 9 pictures",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  decoration: TextDecoration.none),
                            ),
                          ],
                        )),
                      )
                    ]);
        });
  }

  Future getImage(
      ImageSource imageSource, context, currentUser, isProfilePicture,String show) async {
    try {
      var image = await ImagePicker().pickImage(source: imageSource,
        imageQuality: 10
      );
      if (image != null) {
        File croppedFile = await ImageCropper.cropImage(
            sourcePath: image.path,
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            androidUiSettings: AndroidUiSettings(
                toolbarTitle: 'Crop',
                toolbarColor: primaryColor,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true),
            iosUiSettings: IOSUiSettings(
              minimumAspectRatio: 1.0,
            ));
        if (croppedFile != null) {
          await uploadFile(
              await compressimage(croppedFile), currentUser, isProfilePicture, show);
        }
      }
      Navigator.pop(context);
    } catch (e) {
      print("error");
      print(e);
      // Navigator.pop(context);
    }
  }

  Future uploadFile(File image, UserModel currentUser, isProfilePicture, String show) async {

    if(image != null){
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('users/${currentUser.id}/${image.hashCode}.jpg');
      UploadTask uploadTask = ref.putFile(File(image.path));
      uploadTask.then((res) async {
        String fileURL = await res.ref.getDownloadURL();

        Map<String, dynamic> updateObject = {
            "Pictures": [
              {
                "url": fileURL,
                "show": show
              }

            ],
        };
        print(updateObject);
        // Map<String, dynamic> updateObject = {
        //   "Pictures": FieldValue.arrayUnion([
        //     fileURL,
        //   ]),
        // };
        try {
          if (isProfilePicture) {
            //currentUser.imageUrl.removeAt(0);
            // currentUser.imageUrl.insert(0, fileURL);
            currentUser.imageUrl.insert(0,{
              "url": fileURL,
              "show": show
            });
            print(currentUser.imageUrl);
            print("object");
            await FirebaseFirestore.instance
                .collection("Users")
                .doc(currentUser.id)
                .set({"Pictures": currentUser.imageUrl},
                SetOptions(merge : true)

            );
          } else {
            currentUser.imageUrl.add({
              "url": fileURL,
              "show": show
            });
            print(currentUser.imageUrl[currentUser.imageUrl.length-1]['url']);

            await FirebaseFirestore.instance
                .collection("Users")
                .doc(currentUser.id)
                .set({"Pictures": currentUser.imageUrl},
                SetOptions(merge : true)

            );
            // widget.currentUser.imageUrl.add(fileURL);
          }
          if (mounted) setState(() {});
        } catch (err) {
          print("Error: $err");
        }
      });
    }

    // StorageReference storageReference = FirebaseStorage.instance
    //     .ref()
    //     .child('users/${currentUser.id}/${image.hashCode}.jpg');
    // StorageUploadTask uploadTask = storageReference.putFile(image);
    //
    // if (uploadTask.isInProgress == true) {}
    // if (await uploadTask.onComplete != null) {
    //   storageReference.getDownloadURL().then((fileURL) async {
    //     Map<String, dynamic> updateObject = {
    //       "Pictures": FieldValue.arrayUnion([
    //         fileURL,
    //       ])
    //     };
    //     try {
    //       if (isProfilePicture) {
    //         //currentUser.imageUrl.removeAt(0);
    //         currentUser.imageUrl.insert(0, fileURL);
    //         print("object");
    //         await Firestore.instance
    //             .collection("Users")
    //             .document(currentUser.id)
    //             .setData({"Pictures": currentUser.imageUrl}, merge: true);
    //       } else {
    //         await Firestore.instance
    //             .collection("Users")
    //             .document(currentUser.id)
    //             .setData(updateObject, merge: true);
    //         widget.currentUser.imageUrl.add(fileURL);
    //       }
    //       if (mounted) setState(() {});
    //     } catch (err) {
    //       print("Error: $err");
    //     }
    //   });
    // }
  }

  Future compressimage(File image) async {
    final tempdir = await getTemporaryDirectory();
    final path = tempdir.path;
    i.Image imagefile = i.decodeImage(image.readAsBytesSync());
    final compressedImagefile = File('$path.jpg')
      ..writeAsBytesSync(i.encodeJpg(imagefile, quality: 80));
    // setState(() {
    return compressedImagefile;
    // });
  }

  @override
  Widget build(BuildContext context) {
    // Profile _profile = new Profile(widget.currentUser);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 0,
          title: Text(
            "Edit Profile",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: primaryColor),
      body: Scaffold(
        backgroundColor: primaryColor,
        body: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              color: Colors.white),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * .65,
                    width: MediaQuery.of(context).size.width,
                    child: GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        childAspectRatio:
                            MediaQuery.of(context).size.aspectRatio * 1.5,
                        crossAxisSpacing: 4,
                        padding: EdgeInsets.all(10),
                        children: List.generate(9, (index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                decoration: widget.currentUser.imageUrl.length > index
                                    ? BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        // image: DecorationImage(
                                        //     fit: BoxFit.cover,
                                        //     image: CachedNetworkImageProvider(
                                        //       widget.currentUser.imageUrl[index],
                                        //     )),
                                      )
                                    : BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            style: BorderStyle.solid,
                                            width: 1,
                                            color: secondryColor)),
                                child: Stack(
                                  children: <Widget>[
                                    widget.currentUser.imageUrl.length > index
                                        ? CachedNetworkImage(
                                            height: MediaQuery.of(context).size.height *
                                                .2,
                                            fit: BoxFit.cover,
                                            imageUrl: (widget.currentUser.imageUrl[index].runtimeType == String)? widget.currentUser.imageUrl[index] : widget.currentUser.imageUrl[index]['url'] ?? '',
                                            placeholder: (context, url) =>
                                                Center(
                                              child: CupertinoActivityIndicator(
                                                radius: 10,
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) => Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.error,
                                                    color: Colors.black,
                                                    size: 25,
                                                  ),
                                                  Text(
                                                    "Enable to load",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    // Center(
                                    //     child:
                                    //         widget.currentUser.imageUrl.length >
                                    //                 index
                                    //             ? CupertinoActivityIndicator(
                                    //                 radius: 10,
                                    //               )
                                    //             : Container()),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        padding: widget.currentUser.imageUrl.length > index?
                                          EdgeInsets.all(4):EdgeInsets.all(4),
                                          // width: 12,
                                          // height: 16,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: primaryColor,
                                          ),
                                          child: widget.currentUser.imageUrl.length > index
                                              ? InkWell(
                                                  child: Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 22,
                                                  ),
                                                  onTap: () async {
                                                    if(index == 0){
                                                      ArtSweetAlert.show(
                                                          context: context,
                                                          artDialogArgs: ArtDialogArgs(
                                                              type: ArtSweetAlertType.info,
                                                              title: "Info",
                                                              text: "You cannot edit profile image"
                                                          )
                                                      );

                                                    }else{
                                                      indexImage = index;
                                                      bool show = true;
                                                      if(widget.currentUser.imageUrl[index].runtimeType == String || widget.currentUser.imageUrl[index]['show'] == "true"){
                                                        show = true;
                                                      }else{
                                                        show = false;
                                                      }
                                                      if (widget.currentUser.imageUrl.length > 1) {
                                                        // _deletePicture(index);

                                                        showPrivateImageDialog(context, true, widget.currentUser, true, show);
                                                      } else {
                                                        showPrivateImageDialog(context, true, widget.currentUser, true, show);
                                                        // source(context, widget.currentUser, true);
                                                      }
                                                    }

                                                  },
                                                )
                                              : InkWell(
                                                  child: Icon(
                                                    Icons.add_circle_outline,
                                                    size: 22,
                                                    color: Colors.white,
                                                  ),
                                                  onTap: () {
                                                    bool show = false;
                                                    if(widget.currentUser.imageUrl[index].runtimeType == String || widget.currentUser.imageUrl[index]['show'] == "true"){
                                                      show = true;
                                                    }else{
                                                      show = false;
                                                    }
                                                    showPrivateImageDialog(context, true, widget.currentUser, true, show);
                                                    // source(context, widget.currentUser, false);
                                                  }
                                                )),
                                    ),

                                    if(widget.currentUser.imageUrl.length > index)
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                          padding:EdgeInsets.all(4),
                                          // width: 12,
                                          // height: 16,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: primaryColor,
                                          ),
                                          child: InkWell(
                                            child: Icon(
                                              (widget.currentUser.imageUrl[index].runtimeType == String || widget.currentUser.imageUrl[index]['show'] == "true")?
                                              Icons.visibility : Icons.visibility_off_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                            onTap: () async {

                                            },
                                          )
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          );
                        })),
                  ),
                  InkWell(
                    child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  primaryColor.withOpacity(.5),
                                  primaryColor.withOpacity(.8),
                                  primaryColor,
                                  primaryColor,
                                ])),
                        height: 50,
                        width: 340,
                        child: Center(
                            child: Text(
                          "Add media",
                          style: TextStyle(
                              fontSize: 15,
                              color: textColor,
                              fontWeight: FontWeight.bold),
                        ))),
                    onTap: () async {
                      // showPrivateImageDialog(context, false, widget.currentUser, true);
                      // await source(context, widget.currentUser, false);
                      await source(context, widget.currentUser, false, "true");
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListBody(
                      mainAxis: Axis.vertical,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            "About ",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black87),
                          ),
                              // .tr(args: ['${widget.currentUser.name}']),
                          subtitle: CupertinoTextField(
                            controller: aboutCtlr,
                            cursorColor: primaryColor,
                            maxLines: 10,
                            minLines: 3,
                            placeholder: "About you",
                            padding: EdgeInsets.all(10),
                            onChanged: (text) {
                              editInfo.addAll({'about': text});
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "Job title",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black87),
                          ),
                          subtitle: CupertinoTextField(
                            controller: jobCtlr,
                            cursorColor: primaryColor,
                            placeholder: "Add job title",
                            padding: EdgeInsets.all(10),
                            onChanged: (text) {
                              editInfo.addAll({'job_title': text});
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "Company",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black87),
                          ),
                          subtitle: CupertinoTextField(
                            controller: companyCtlr,
                            cursorColor: primaryColor,
                            placeholder: "Add company",
                            padding: EdgeInsets.all(10),
                            onChanged: (text) {
                              editInfo.addAll({'company': text});
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "University",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black87),
                          ),
                          subtitle: CupertinoTextField(
                            controller: universityCtlr,
                            cursorColor: primaryColor,
                            placeholder: "Add university",
                            padding: EdgeInsets.all(10),
                            onChanged: (text) {
                              editInfo.addAll({'university': text});
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "Living in",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black87),
                          ),
                          subtitle: CupertinoTextField(
                            controller: livingCtlr,
                            cursorColor: primaryColor,
                            placeholder: "Add city",
                            padding: EdgeInsets.all(10),
                            onChanged: (text) {
                              editInfo.addAll({'living_in': text});
                            },
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 10),
                        //   child: ListTile(
                        //     title: Text(
                        //       "I am",
                        //       style: TextStyle(
                        //           fontWeight: FontWeight.w500,
                        //           fontSize: 16,
                        //           color: Colors.black87),
                        //     ),
                        //     subtitle: DropdownButton(
                        //       iconEnabledColor: primaryColor,
                        //       iconDisabledColor: secondryColor,
                        //       isExpanded: true,
                        //       items: [
                        //         DropdownMenuItem(
                        //           child: Text("Man"),
                        //           value: "man",
                        //         ),
                        //         DropdownMenuItem(
                        //             child: Text("Woman"),
                        //             value: "woman"),
                        //         DropdownMenuItem(
                        //             child: Text("Other"),
                        //             value: "other"),
                        //       ],
                        //       onChanged: (val) {
                        //         editInfo.addAll({'userGender': val});
                        //         setState(() {
                        //           showMe = val;
                        //         });
                        //       },
                        //       value: showMe,
                        //     ),
                        //   ),
                        // ),
                        SizedBox(
                          height: 10,
                        ),
                        ListTile(
                            title: Text(
                              "Control your profile",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Colors.black87),
                            ),
                            subtitle: Card(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: <Widget>[
                                  //     Padding(
                                  //       padding: const EdgeInsets.all(8.0),
                                  //       child: Text("Don't Show My Age"),
                                  //     ),
                                  //     Switch(
                                  //         activeColor: primaryColor,
                                  //         value: visibleAge,
                                  //         onChanged: (value) {
                                  //           editInfo
                                  //               .addAll({'showMyAge': value});
                                  //           setState(() {
                                  //             visibleAge = value;
                                  //           });
                                  //         })
                                  //   ],
                                  // ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Make My Distance Visible"),
                                      ),
                                      Switch(
                                          activeColor: primaryColor,
                                          value: visibleDistance,
                                          onChanged: (value) {
                                            editInfo.addAll(
                                                {'DistanceVisible': value});
                                            setState(() {
                                              visibleDistance = value;
                                            });
                                          })
                                    ],
                                  ),
                                ],
                              ),
                            )),

                        Padding(
                          padding: const EdgeInsets.only(
                              top: 5.0, bottom: 5,
                              right: 10, left: 10
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Gender",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),

                              SizedBox(height: 12,),

                              Container(
                                  height: Get.height * 0.75,
                                  child: GridView.count(
                                    physics: NeverScrollableScrollPhysics(),
                                    // Create a grid with 2 columns. If you change the scrollDirection to
                                    // horizontal, this produces 2 rows.
                                    crossAxisCount: 2,
                                    childAspectRatio: 4/1,
                                    crossAxisSpacing: 4.0,
                                    mainAxisSpacing: 8.0,
                                    // Generate 100 widgets that display their index in the List.
                                    children: List.generate(listGender.length, (index) {
                                      return OutlineButton(
                                        highlightedBorderColor: primaryColor,
                                        child: Container(
                                          // height: MediaQuery.of(context).size.height * .055,
                                          // width: MediaQuery.of(context).size.width * .65,
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              bottom: 8,
                                              left: 8,
                                              right: 8
                                          ),
                                          child: Center(
                                              child: Text("${listGender[index]["name"]}".toUpperCase(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: Global.font,
                                                      color: listGender[index]["name"] == selectionGender
                                                          ? primaryColor
                                                          : secondryColor,
                                                      fontWeight: FontWeight.normal
                                                  )
                                              )
                                          ),
                                        ),
                                        borderSide: BorderSide(
                                            width: 1,
                                            style: BorderStyle.solid,
                                            color: listGender[index]["name"] == selectionGender
                                                ? primaryColor
                                                : secondryColor),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25)),
                                        onPressed: () {
                                          selectionGender = listGender[index]["name"];
                                          setState(() {

                                            var userGender = {
                                              'userGender': selectionGender,
                                              'showOnProfile': widget.currentUser.showingGender
                                            };
                                            editInfo.addAll(userGender);

                                          });
                                        },
                                      );
                                    }),
                                  )
                              )
                            ],
                          ),
                        ),


                        Padding(
                          padding: const EdgeInsets.only(
                              top: 5.0, bottom: 5,
                              right: 10, left: 10
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Sexual Orientation",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),

                              SizedBox(height: 12,),

                              Container(
                                  height: Get.height * 0.75,
                                  child: GridView.count(
                                    physics: NeverScrollableScrollPhysics(),
                                    // Create a grid with 2 columns. If you change the scrollDirection to
                                    // horizontal, this produces 2 rows.
                                    crossAxisCount: 2,
                                    childAspectRatio: 4/1,
                                    crossAxisSpacing: 4.0,
                                    mainAxisSpacing: 8.0,
                                    // Generate 100 widgets that display their index in the List.
                                    children: List.generate(orientationlist.length, (index) {
                                      return OutlineButton(
                                        highlightedBorderColor: primaryColor,
                                        child: Container(
                                          // height: MediaQuery.of(context).size.height * .055,
                                          // width: MediaQuery.of(context).size.width * .65,
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              bottom: 8,
                                              left: 8,
                                              right: 8
                                          ),
                                          child: Center(
                                              child: Text("${orientationlist[index]["name"]}".toUpperCase(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: Global.font,
                                                      color: orientationlist[index]["name"] == selectionOrientation
                                                          ? primaryColor
                                                          : secondryColor,
                                                      fontWeight: FontWeight.normal
                                                  )
                                              )
                                          ),
                                        ),
                                        borderSide: BorderSide(
                                            width: 1,
                                            style: BorderStyle.solid,
                                            color: orientationlist[index]["name"] == selectionOrientation
                                                ? primaryColor
                                                : secondryColor),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25)),
                                        onPressed: () {
                                          selectionOrientation = orientationlist[index]["name"];
                                          setState(() {

                                            var userOrientation = {
                                              "sexualOrientation": {
                                                'orientation': selectionOrientation,
                                                'showOnProfile': widget.currentUser.showingOrientation
                                              },
                                            };
                                            orientationMap.addAll(userOrientation);
                                          });
                                        },
                                      );
                                    }),
                                  )
                              )
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              top: 5.0, bottom: 5,
                              right: 10, left: 10
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Status",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),

                              SizedBox(height: 12,),

                              Container(
                                  height: Get.height * 0.15,
                                  child: GridView.count(
                                    physics: NeverScrollableScrollPhysics(),
                                    // Create a grid with 2 columns. If you change the scrollDirection to
                                    // horizontal, this produces 2 rows.
                                    crossAxisCount: 2,
                                    childAspectRatio: 4/1,
                                    crossAxisSpacing: 4.0,
                                    mainAxisSpacing: 8.0,
                                    // Generate 100 widgets that display their index in the List.
                                    children: List.generate(listStatus.length, (index) {
                                      return OutlineButton(
                                        highlightedBorderColor: primaryColor,
                                        child: Container(
                                          // height: MediaQuery.of(context).size.height * .055,
                                          // width: MediaQuery.of(context).size.width * .65,
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              bottom: 8,
                                              left: 8,
                                              right: 8
                                          ),
                                          child: Center(
                                              child: Text("${listStatus[index]["name"]}".toUpperCase(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: Global.font,
                                                      color: listStatus[index]["name"] == selectionStatus
                                                          ? primaryColor
                                                          : secondryColor,
                                                      fontWeight: FontWeight.normal
                                                  )
                                              )
                                          ),
                                        ),
                                        borderSide: BorderSide(
                                            width: 1,
                                            style: BorderStyle.solid,
                                            color: listStatus[index]["name"] == selectionStatus
                                                ? primaryColor
                                                : secondryColor),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25)),
                                        onPressed: () {
                                          selectionStatus = listStatus[index]["name"];
                                          setState(() {

                                            var userStatus = {
                                              'status': selectionStatus,
                                            };
                                            statusMap.addAll(userStatus);
                                          });
                                        },
                                      );
                                    }),
                                  )
                              )
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              top: 5.0, bottom: 5,
                              right: 10, left: 10
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "I am looking for",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500
                                ),
                              ),

                              SizedBox(height: 12,),

                              Container(
                                  height: Get.height * 0.3,
                                  child: GridView.count(
                                    physics: NeverScrollableScrollPhysics(),
                                    // Create a grid with 2 columns. If you change the scrollDirection to
                                    // horizontal, this produces 2 rows.
                                    crossAxisCount: 2,
                                    childAspectRatio: 4/1,
                                    crossAxisSpacing: 4.0,
                                    mainAxisSpacing: 8.0,
                                    // Generate 100 widgets that display their index in the List.
                                    children: List.generate(listDesire.length, (index) {
                                      return OutlineButton(
                                        highlightedBorderColor: primaryColor,
                                        child: Container(
                                          // height: MediaQuery.of(context).size.height * .055,
                                          // width: MediaQuery.of(context).size.width * .65,
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              bottom: 8,
                                              left: 8,
                                              right: 8
                                          ),
                                          child: Center(
                                              child: Text("${listDesire[index]["name"]}".toUpperCase(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: Global.font,
                                                      color: listDesire[index]["ontap"]
                                                          ? primaryColor
                                                          : secondryColor,
                                                      fontWeight: FontWeight.normal
                                                  )
                                              )
                                          ),
                                        ),
                                        borderSide: BorderSide(
                                            width: 1,
                                            style: BorderStyle.solid,
                                            color: listDesire[index]["ontap"]
                                                ? primaryColor
                                                : secondryColor),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25)),
                                        onPressed: () {
                                          setState(() {

                                            listDesire[index]["ontap"] = !listDesire[index]["ontap"];
                                            if (listDesire[index]["ontap"]) {
                                              selectedDesire.add(listDesire[index]["name"]);
                                              print(listDesire[index]["name"]);
                                              print(selectedDesire);
                                            } else {
                                              selectedDesire.remove(listDesire[index]["name"]);
                                              print(selectedDesire);
                                            }
                                            desiresMap.addAll({
                                              'desires': selectedDesire,
                                            });

                                          });
                                        },
                                      );
                                    }),
                                  )
                              )
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              top: 5.0, bottom: 5,
                              right: 10, left: 10
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Kinks & Desires",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500
                                ),
                              ),

                              SizedBox(height: 12,),

                              Container(
                                  height: Get.height * 0.45,
                                  child: GridView.count(
                                    physics: NeverScrollableScrollPhysics(),
                                    // Create a grid with 2 columns. If you change the scrollDirection to
                                    // horizontal, this produces 2 rows.
                                    crossAxisCount: 2,
                                    childAspectRatio: 4/1,
                                    crossAxisSpacing: 4.0,
                                    mainAxisSpacing: 8.0,
                                    // Generate 100 widgets that display their index in the List.
                                    children: List.generate(listKinks.length, (index) {
                                      return OutlineButton(
                                        highlightedBorderColor: primaryColor,
                                        child: Container(
                                          // height: MediaQuery.of(context).size.height * .055,
                                          // width: MediaQuery.of(context).size.width * .65,
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              bottom: 8,
                                              left: 8,
                                              right: 8
                                          ),
                                          child: Center(
                                              child: Text(listKinks[index]["name"].toUpperCase(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: Global.font,
                                                      color: listKinks[index]["ontap"]
                                                          ? primaryColor
                                                          : secondryColor,
                                                      fontWeight: FontWeight.normal
                                                  )
                                              )
                                          ),
                                        ),
                                        borderSide: BorderSide(
                                            width: 1,
                                            style: BorderStyle.solid,
                                            color: listKinks[index]["ontap"]
                                                ? primaryColor
                                                : secondryColor),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25)),
                                        onPressed: () {
                                          setState(() {

                                            listKinks[index]["ontap"] = !listKinks[index]["ontap"];
                                            if (listKinks[index]["ontap"]) {
                                              selectedKinks.add(listKinks[index]["name"]);
                                              print(listKinks[index]["name"]);
                                              print(selectedKinks);
                                            } else {
                                              selectedKinks.remove(listKinks[index]["name"]);
                                              print(selectedKinks);
                                            }
                                            kinksMap.addAll({
                                              'kinks': selectedKinks,
                                            });

                                          });
                                        },
                                      );
                                    }),
                                  )
                              )
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              top: 5.0, bottom: 5,
                              right: 10, left: 10
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Interest",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500
                                ),
                              ),

                              SizedBox(height:12),

                              if(selectedInterest.isNotEmpty)
                                for(int i=0; i<=selectedInterest.length-1; i++)
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 8,
                                        right: 8,
                                        top: 8,
                                        bottom: 8
                                    ),
                                    margin: EdgeInsets.only(
                                      bottom: 10
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey[500],
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(5))
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                              selectedInterest[i]
                                          )
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: IconButton(
                                              onPressed:(){
                                                print("Cek");
                                                selectedInterest.removeAt(i);
                                                print(selectedInterest);
                                                interestMap.addAll({
                                                  'interest': selectedInterest,
                                                });
                                                setState(() {

                                                });
                                              },
                                              icon:Icon(Icons.cancel)
                                            )
                                        )

                                      ],
                                    ),
                                  ),

                              SizedBox(
                                height: 5,
                              ),


                              InkWell(
                                onTap: () async {
                                  await dialogInterest(context);
                                },
                                child: Row(
                                  children: [

                                    Expanded(
                                        flex: 1,
                                        child:Icon(
                                          Icons.add,
                                          color: Colors.green[600],
                                        )
                                    ),

                                    Expanded(
                                        flex: 5,
                                        child:Text(
                                          "Add new interest",
                                          style: TextStyle(
                                              color: Colors.green[600],
                                              fontSize: 15
                                          ),
                                        )
                                    ),

                                  ],
                                )
                              )

                            ],
                          ),
                        ),

                        SizedBox(
                          height: 100,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  dialogInterest(BuildContext context2) async {
    TextEditingController interestText = TextEditingController();
    ArtDialogResponse response = await ArtSweetAlert.show(
        barrierDismissible: false,
        context: context2,
        artDialogArgs: ArtDialogArgs(
          showCancelBtn: true,
          // denyButtonText: "Cancel",
          title: "Enter your interest",
          confirmButtonText: "Save",
          customColumns: [

            Container(
              padding: EdgeInsets.fromLTRB(10,2,10,2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.red)
              ),
              child: TextField(

                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "Your interest",
                ),
                controller: interestText,
              ),
            ),

            SizedBox(height: 20,)

          ]
        )
    );

    if(response==null) {
      return;
    }

    if(response.isTapConfirmButton) {
      setState(() {
        selectedInterest.add(interestText.text);

        interestMap.addAll({
          'interest': selectedInterest,
        });
      });
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "Saved!"
          )
      );
      return;
    }

  }

  Future showPrivateImageDialog(BuildContext context2, bool isProfilePicture, UserModel userModel, bool deleted,
      bool show) async{

    // print(show);
    await showDialog<String>(
      context: context2,
      builder: (BuildContext context){
        return StatefulBuilder(builder: (BuildContext context3, StateSetter setState2){
          return CupertinoAlertDialog(
            content: Material(
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    InkWell(
                      onTap: () async {
                        var url = "";
                        if(widget.currentUser.imageUrl[indexImage].runtimeType == String){
                          url = widget.currentUser.imageUrl[indexImage];
                        }else{
                          url = widget.currentUser.imageUrl[indexImage]['url'];
                        }
                        var data = {
                          "url": url,
                          "show": "true"
                        };

                        widget.currentUser.imageUrl.removeAt(indexImage);
                        widget.currentUser.imageUrl.insert(0,data);
                        await FirebaseFirestore.instance
                            .collection("Users")
                            .doc(widget.currentUser.id)
                            .set({"Pictures": widget.currentUser.imageUrl},
                            SetOptions(merge : true)

                        );
                        setState(() {
                          Get.back();
                        });
                      },
                      child: Container(
                          padding: EdgeInsets.only(
                              left: 18,
                              right: 18,
                              top: 10,
                              bottom: 10
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text("Set as my profile image",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white
                            ),
                          )
                      ),
                    ),


                    SizedBox(height: 12,),

                    InkWell(
                      onTap: () async {

                        var url = "";
                        if(widget.currentUser.imageUrl[indexImage].runtimeType == String){
                          url = widget.currentUser.imageUrl[indexImage];
                        }else{
                          url = widget.currentUser.imageUrl[indexImage]['url'];
                        }
                        bool showPhotos = !show;
                        var data = {
                          "url": url,
                          "show": showPhotos.toString()
                        };

                        widget.currentUser.imageUrl[indexImage] = data;
                        print(widget.currentUser.imageUrl);
                        await FirebaseFirestore.instance
                            .collection("Users")
                            .doc(widget.currentUser.id)
                            .set({"Pictures": widget.currentUser.imageUrl},
                            SetOptions(merge : true)

                        );
                        setState(() {
                          Get.back();
                        });

                      },
                      child: Container(
                          padding: EdgeInsets.only(
                              left: 18,
                              right: 18,
                              top: 10,
                              bottom: 10
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text((!show)?
                            "Set this image to public":
                            "Set this image to private",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white
                            ),
                          )
                      ),
                    ),

                    SizedBox(height: 12,),

                    InkWell(
                      onTap: () async {
                        await _deletePicture(indexImage);
                        Get.back();
                      },
                      child: Container(
                          padding: EdgeInsets.only(
                              left: 18,
                              right: 18,
                              top: 10,
                              bottom: 10
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text("Delete this image",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white
                            ),
                          )
                      ),
                    ),

                  ],
                ),

              )
            ),
          );
        });
      },
      barrierDismissible: true,
    );
  }

  Future <void> _deletePicture(index) async {
    if (widget.currentUser.imageUrl[index] != null) {
      try {
        var _ref = FirebaseStorage.instance.ref(widget.currentUser.imageUrl[index]);
        print(_ref.fullPath);
        await _ref.delete();
      } catch (e) {
        print(e);
      }
    }
    setState(() {
      widget.currentUser.imageUrl.removeAt(index);
    });
    var temp = [];
    temp.add(widget.currentUser.imageUrl);
    await FirebaseFirestore.instance
        .collection("Users")
        .doc("${widget.currentUser.id}")
        .set({"Pictures": temp[0]},
        SetOptions(merge : true)
    );
  }
}
