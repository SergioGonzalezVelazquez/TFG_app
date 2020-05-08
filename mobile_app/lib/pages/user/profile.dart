import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tfg_app/utils/validators.dart';
import 'package:tfg_app/widgets/buttons.dart';
import 'package:tfg_app/widgets/inputs.dart';
import 'package:tfg_app/widgets/progress.dart';
import 'package:tfg_app/services/auth.dart';
import 'package:tfg_app/themes/custom_icon_icons.dart';
import 'package:tfg_app/models/user.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  /// Name use for navigate to this screen
  static const route = "/profile";

  ///Creates a StatelessElement to manage this widget's location in the tree.
  _ProfilePageState createState() => _ProfilePageState();
}

/// State object for ProfilePage that contains fields that affect
/// how it looks.
class _ProfilePageState extends State<ProfilePage> {
  // Create controllers for handle changes in text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // new profile image uploaded from camera or gallery
  File _file;

  //Auth user
  User _user;

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  // Flags to render loading spinner UI.
  bool _isLoading = false;
  bool _editable = false;

  AuthService _authService;

  // Create a global key that uniquely identifies the Scaffold widget,
  // and allows to display snackbars.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  /// Method called when this widget is inserted into the tree.
  @override
  void initState() {
    _authService = AuthService();
    _user = _authService.user;
    _emailController.text = _user.email;
    _nameController.text = _user.name;
    super.initState();
  }

  // Clean up the controllers when the widget is removed from the
  // widget tree.
  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /**
  * Functions used to handle events in this screen 
  */
  bool _updated() {
    return (_nameController.text.trim() != _user.name) ||
        (_emailController.text.trim() != _user.email);
  }

  /// Dialog to select image from gallery or take new photo with camera
  _selectImage(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text('Foto de perfil'),
            children: <Widget>[
              SimpleDialogOption(
                child: Row(children: <Widget>[
                  Icon(
                    CustomIcon.camera,
                    size: 16,
                    color: Theme.of(context).textTheme.subtitle1.color,
                  ),
                  SizedBox(width: 15),
                  Text('Photo with camera')
                ]),
                onPressed: _handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Row(children: <Widget>[
                  Icon(
                    CustomIcon.picture,
                    size: 16,
                    color: Theme.of(context).textTheme.subtitle1.color,
                  ),
                  SizedBox(width: 15),
                  Text('Photo with camera')
                ]),
                onPressed: _handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  _handleTakePhoto() async {
    Navigator.pop(context);

    File file = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 675, maxWidth: 960);

    setState(() {
      this._file = file;
    });
  }

  _handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 675, maxWidth: 960);
    setState(() {
      this._file = file;
    });
  }

  clearImage() {
    setState(() {
      _file = null;
    });
  }

  /**
  * Widgets (ui components) used in this screen 
  */

  Widget _updateProfilePage(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1),
      children: <Widget>[
        _profilePhoto(),
        _profileForm(context),
        _updateProfileButton(),
      ],
    );
  }

  Form _profileForm(BuildContext context) {
    double verticalPadding = MediaQuery.of(context).size.height * 0.02;

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          customTextInput("Nombre y apellidos", CustomIcon.user,
              validator: (val) => Validator.username(val),
              controller: _nameController,
              enabled: _editable),
          SizedBox(
            height: verticalPadding,
          ),
          customTextInput("Correo Electrónico", CustomIcon.mail,
              controller: _emailController,
              validator: (val) => Validator.email(val),
              keyboardType: TextInputType.emailAddress,
              enabled: false),
          SizedBox(
            height: verticalPadding,
          ),
        ],
      ),
    );
  }

  Widget _updateProfileButton() {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Visibility(
      visible: _editable,
      child: Row(
        children: <Widget>[
          primaryButton(context, () {
            setState(() {
              _editable = false;
            });
          }, "Cancelar", width: deviceWidth * 0.25, light: true),
          SizedBox(
            width: deviceWidth * 0.04,
          ),
          primaryButton(context, () async {
            setState(() {
              _editable = false;
            });
            await _authService.updateProfile(name: _nameController.text.trim());
          }, "Guardar cambios", width: deviceWidth * 0.51, enabled: _updated())
        ],
      ),
    );
  }

  Widget _profilePhoto() {
    double imageSize = MediaQuery.of(context).size.width * 0.3;
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.05),
        height: imageSize,
        width: imageSize,
        child: Stack(
          children: <Widget>[
            Container(
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: _user.photoUrl != null
                      ? CachedNetworkImageProvider(_user.photoUrl)
                      : AssetImage("assets/images/default-user.jpg"),
                ),
              ),
            ),
            Visibility(
              visible: _editable,
              child: Positioned(
                bottom: 0,
                left: MediaQuery.of(context).size.width * 0.12,
                child: FlatButton(
                  onPressed: () => _selectImage(context),
                  shape: CircleBorder(),
                  color: Theme.of(context).primaryColor,
                  child: Icon(
                    CustomIcon.camera,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Mi cuenta'),
        actions: <Widget>[
          // edit profile
          Visibility(
            visible: !_editable,
            child: IconButton(
              icon: Icon(CustomIcon.pencil),
              onPressed: () {
                setState(() {
                  _editable = true;
                });
              },
            ),
          )
        ],
      ),
      body: _isLoading
          ? circularProgress(context, text: "Actualizando perfil")
          : _updateProfilePage(context),
    );
  }
}
