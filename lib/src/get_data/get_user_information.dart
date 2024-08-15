import 'package:mymangatheque/src/services/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class GetUserInfo extends StatelessWidget {
  final String beforeText;
  final String afterText;

  const GetUserInfo(
      {required this.beforeText, required this.afterText, super.key});

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(beforeText),
          Text(afterText),
        ],
      ),
    );
  }
}

class GetUserProfilePicture extends StatelessWidget {
  final PocketBaseFile file;

  const GetUserProfilePicture({required this.file, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PocketBaseConnector connector = PocketBaseConnector();
    User? user = connector.getConnectedUser();

    return FutureBuilder(
      future: _fetchUserProfilePicture(user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError || snapshot.data == null) {
            return _buildLocalImage();
          } else {
            return _buildNetworkImage(snapshot.data as String);
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<String?> _fetchUserProfilePicture(User? user) async {
    if (user?.avatar == null || user?.avatar?.path == null) {
      return null;
    }
    try {
      final url = join(PocketBaseConnector().serverUrl, user!.avatar!.path);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return url;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Widget _buildLocalImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(150.0),
        child: Image.asset(
          'assets/images/unknown.webp',
          height: 175,
          width: 175,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String url) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(150.0),
        child: Image.network(
          url,
          height: 175,
          width: 175,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}