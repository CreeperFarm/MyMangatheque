import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:path/path.dart';

class GetUserProfilePicture extends StatelessWidget {
  final PocketBaseFile file;
  final double? height;
  final double? width;

  const GetUserProfilePicture({required this.file, this.height, this.width, super.key});

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
          Assets.images.unknown,
          height: height ?? 175,
          width: width ?? 175,
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
          height: height ?? 175,
          width: width ?? 175,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
