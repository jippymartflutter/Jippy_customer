import 'package:flutter/material.dart';

class UserAvatarWidget extends StatelessWidget {
  final String? userName;
  final String? userEmail;
  final double size;
  final Color backgroundColor;
  final Color textColor;
  final bool isCircular;
  final double borderRadius;
  final String? imageUrl;
  final VoidCallback? onTap;

  const UserAvatarWidget({
    super.key,
    this.userName,
    this.userEmail,
    this.size = 52,
    this.backgroundColor = const Color(0xFF5C5C99),
    this.textColor = const Color(0xFFC5C2FF),
    this.isCircular = true,
    this.borderRadius = 12,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          // Use borderRadius in BoxDecoration, NOT in TextStyle
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircular ? null : BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: isCircular 
                      ? BorderRadius.circular(size / 2)
                      : BorderRadius.circular(borderRadius),
                  child: Image.network(
                    imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to initials if image fails to load
                      return _buildInitialsText();
                    },
                  ),
                )
              : _buildInitialsText(),
        ),
      ),
    );
  }

  Widget _buildInitialsText() {
    return Text(
      _getUserInitials(),
      style: TextStyle(
        fontSize: size * 0.35, // Responsive font size
        fontWeight: FontWeight.bold,
        color: textColor,
        // ❌ NEVER put borderRadius here - it's not a valid TextStyle property
        // borderRadius: BorderRadius.circular(10), // This would cause an error!
      ),
    );
  }

  String _getUserInitials() {
    if (userName != null && userName!.isNotEmpty) {
      final nameParts = userName!.trim().split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else if (nameParts.length == 1) {
        return nameParts[0][0].toUpperCase();
      }
    }
    
    if (userEmail != null && userEmail!.isNotEmpty) {
      return userEmail![0].toUpperCase();
    }
    
    return 'U'; // Default fallback
  }
}

// Example usage widget
class UserAvatarExample extends StatelessWidget {
  const UserAvatarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Avatar Examples'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Circular Avatars (Default):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const UserAvatarWidget(
                  userName: 'John Doe',
                  size: 52,
                ),
                const SizedBox(width: 16),
                const UserAvatarWidget(
                  userName: 'Jane Smith',
                  size: 40,
                  backgroundColor: Colors.blue,
                ),
                const SizedBox(width: 16),
                const UserAvatarWidget(
                  userName: 'Bob',
                  size: 60,
                  backgroundColor: Colors.green,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Rounded Rectangle Avatars:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const UserAvatarWidget(
                  userName: 'Alice Johnson',
                  size: 52,
                  isCircular: false,
                  borderRadius: 12,
                  backgroundColor: Colors.purple,
                ),
                const SizedBox(width: 16),
                const UserAvatarWidget(
                  userName: 'Charlie Brown',
                  size: 40,
                  isCircular: false,
                  borderRadius: 8,
                  backgroundColor: Colors.orange,
                ),
                const SizedBox(width: 16),
                const UserAvatarWidget(
                  userName: 'Diana Prince',
                  size: 60,
                  isCircular: false,
                  borderRadius: 16,
                  backgroundColor: Colors.red,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            const Text(
              'With Email Fallback:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const UserAvatarWidget(
              userEmail: 'user@example.com',
              size: 52,
              backgroundColor: Colors.teal,
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Interactive Avatar:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            UserAvatarWidget(
              userName: 'Tap Me',
              size: 52,
              backgroundColor: Colors.indigo,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Avatar tapped!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
