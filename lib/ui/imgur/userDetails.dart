import 'package:dev_epicture_2018/account.dart';
import 'package:dev_epicture_2018/data/imgur.dart';
import 'package:dev_epicture_2018/data/user.dart';
import 'package:dev_epicture_2018/ui/gallery/gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:http/http.dart' as http;

class DialogonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height - 75);
    path.lineTo(size.width, size.height - 75);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class UserDetails extends StatefulWidget {
  final String username;

  UserDetails({this.username});

  @override
  _UserDetailsState createState() => _UserDetailsState(username: this.username);
}

class _UserDetailsState extends State<UserDetails> with SingleTickerProviderStateMixin {
  TabController _tabController;
  final String username;
  User _user;

  _UserDetailsState({this.username});

  Future<void> _getUserInfo() async {
    http.Response response;
    response = await http.get(
      'https://api.imgur.com/3/account/' + username + '?client_id=4525911e004914a',
      headers: await Account.getHeader(context: context),
    );
    setState(() {
      _user = User.fromResponse(response.body);
    });
  }

  @override
  initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getUserInfo();
  }

  @override
  dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildImage() {
    return ClipPath(
      clipper: DialogonalClipper(),
      child: Image(
        image: AdvancedNetworkImage(_user.cover),
        fit: BoxFit.fitHeight,
        height: 250,
        colorBlendMode: BlendMode.srcOver,
        color: Color.fromARGB(120, 20, 10, 40),
      ),
    );
  }

  Widget _buildTopHeader() {
    return new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40.0),
      child: IconButton(
        icon: Icon(Icons.arrow_back, size: 32.0, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  String _formatBio(String bio) {
    if (bio != null && bio.length >= 100)
      return bio.substring(0, 100) + '...';
    else
      return bio;
  }

  Widget _buildProfileRow() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: 250 / 3),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            minRadius: 28.0,
            maxRadius: 28.0,
            backgroundImage: AdvancedNetworkImage(_user.avatar),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.70,
                  child: Text(
                    _user.url ?? username ?? '',
                    style: TextStyle(fontSize: 26.0, color: Colors.white, fontWeight: FontWeight.w400),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.70,
                  child: Text(
                    _formatBio(_user.bio) ?? '',
                    style: TextStyle(fontSize: 14.0, color: Colors.white, fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getSubmissions({int page = 0}) async {
    http.Response response;
    response = await http.get(
      'https://api.imgur.com/3/account/' + this.username + '/submissions/' + page.toString() + '?client_id=4525911e004914a&album_previews=true&mature=true',
      headers: await Account.getHeader(context: context),
    );
    return Imgur.allFromResponse(response.body);
  }

  getFavorites({int page = 0}) async {
    http.Response response;
    response = await http.get(
      'https://api.imgur.com/3/account/' + this.username + '/gallery_favorites/' + page.toString() + '?client_id=4525911e004914a&album_previews=true&mature=true',
      headers: await Account.getHeader(context: context),
    );
    return Imgur.allFromResponse(response.body);
  }

  Widget _buildBottomPart() {
    return Padding(
      padding: EdgeInsets.only(top: 140),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: 'Posts',
              ),
              Tab(
                text: 'Favorites',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Gallery(
              dataCallback: (page) => getSubmissions(page: page),
            ),
            Gallery(
              dataCallback: (page) => getFavorites(page: page),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _user == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: <Widget>[
                _buildBottomPart(),
                _buildImage(),
                _buildTopHeader(),
                _buildProfileRow(),
              ],
            ),
    );
  }
}
