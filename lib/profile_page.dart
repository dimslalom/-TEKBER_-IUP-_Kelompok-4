import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'auth_state.dart';
import 'dart:io';

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.2),
      size.width * 0.3,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      size.width * 0.4,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _imagePicker = ImagePicker();
  
  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      context.read<AuthState>().updateProfile(profileImage: image.path);
    }
  }

  void _changeName() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: context.read<AuthState>().username);
        return AlertDialog(
          title: const Text('Change Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthState>().updateProfile(username: controller.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) {
        final currentPass = TextEditingController();
        final newPass = TextEditingController();
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
              ),
              TextField(
                controller: newPass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Implement password change logic here
                Navigator.pop(context);
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    context.read<AuthState>().logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  Widget _buildLoggedOutView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.orange,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'Not Logged In',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          _buildActionButton(
            'Login',
            Colors.orange,
            () => _showLoginDialog(context),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            'Create Account',
            Colors.orange[700]!,
            () => _showRegisterDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (usernameController.text.isNotEmpty && 
                  passwordController.text.isNotEmpty) {
                context.read<AuthState>().login(
                  usernameController.text,
                  passwordController.text
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showRegisterDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (usernameController.text.isNotEmpty && 
                  passwordController.text == confirmPasswordController.text) {
                context.read<AuthState>().register(
                  usernameController.text,
                  passwordController.text
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, authState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Stack(
            children: [
              CustomPaint(
                painter: BackgroundPainter(),
                size: Size.infinite,
              ),
              authState.isLoggedIn
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return _buildTabletLayout();
                      } else {
                        return _buildMobileLayout();
                      }
                    },
                  )
                : _buildLoggedOutView(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditableAvatar() {
    return Consumer<AuthState>(
      builder: (context, authState, child) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 100,
                backgroundImage: authState.profileImage == 'default'
                    ? const AssetImage('assets/default_avatar.png')
                    : FileImage(File(authState.profileImage)) as ImageProvider,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange[400],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: _pickImage,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditableText(bool isBio) {
    return Consumer<AuthState>(
      builder: (context, authState, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isBio ? authState.bio : authState.username,
              style: TextStyle(
                fontSize: isBio ? 16 : 24,
                fontWeight: isBio ? FontWeight.normal : FontWeight.bold,
                color: isBio ? Colors.grey : Colors.black,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => isBio ? _changeBio() : _changeName(),
            ),
          ],
        );
      },
    );
  }

  void _changeBio() {
    final controller = TextEditingController(
      text: context.read<AuthState>().bio
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Bio'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Bio'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthState>().updateProfile(bio: controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 20),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildEditableAvatar(),
                const SizedBox(height: 32),
                _buildEditableText(false),
                const SizedBox(height: 16),
                _buildEditableText(true),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  'Log Out',
                  Colors.red,
                  _logout,
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  'Change Password',
                  Colors.orange[700]!,
                  _changePassword,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildEditableAvatar(),
            const SizedBox(height: 32),
            _buildEditableText(false),
            const SizedBox(height: 16),
            _buildEditableText(true),
            const SizedBox(height: 48),
            _buildActionButton(
              'Log Out',
              Colors.red,
              _logout,
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              'Change Password',
              Colors.orange[700]!,
              _changePassword,
            ),
          ],
        ),
      ),
    );
  }
}