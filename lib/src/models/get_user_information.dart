import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';

class GetUserProfilePicture extends StatelessWidget {
  final AppwriteFile file;
  final double? height;
  final double? width;

  const GetUserProfilePicture({
    required this.file,
    this.height,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final connector = AppwriteConnector();
    final user = connector.getConnectedUser();

    return FutureBuilder<String?>(
      future: _fetchUserProfilePicture(user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return _buildLocalImage();
          }
          return _buildNetworkImage(snapshot.data!);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<String?> _fetchUserProfilePicture(User? user) async {
    final avatarUrl = user?.avatar?.url;
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return null;
    }
    final safeUri = parseSafeHttpsUri(avatarUrl);
    if (safeUri == null) return null;

    return safeUri.toString();
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
        child: SafeNetworkImage(
          imageUrl: url,
          height: height ?? 175,
          width: width ?? 175,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
