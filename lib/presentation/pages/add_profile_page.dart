import 'dart:io';

import 'package:flutter_example/app/theme/app_theme.dart';
import 'package:flutter_example/core/constants/global_const.dart';
import 'package:flutter_example/core/utils/avatar_utils.dart';
import 'package:flutter_example/domain/entities/profile.dart';
import 'package:flutter_example/presentation/bloc/profile/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Страница добавления/редактирования профиля.
/// Зона ответственности: ввод данных профиля (имя, пароль, сервер),
/// выбор аватара, сохранение профиля через ProfileCubit.
class AddProfilePage extends StatefulWidget {
  const AddProfilePage({super.key});

  @override
  State<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  late final ProfileCubit profileCubit;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final serverUriController = TextEditingController();
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    profileCubit = context.read<ProfileCubit>();

    final profileCubitState = profileCubit.state;
    debugPrint(profileCubitState.toString());
    initFields(profileCubitState);
  }

  void initFields(ProfileState profileCubitState) {
    if (profileCubitState is ProfileInitial) {
      profileCubit.checkProfileExists();
      serverUriController.text = GlobalConst.serverUri;
    } else if (profileCubitState is ProfileLoaded) {
      final profile = profileCubitState.profile;
      usernameController.text = profile.username;
      passwordController.text = profile.password;
      serverUriController.text = profile.serverUri;
      selectedImage = profile.imageUri != null ? File(profile.imageUri!) : null;
    }
  }

  void clearFields() {
    usernameController.text = '';
    passwordController.text = '';
    serverUriController.text = GlobalConst.serverUri;
    selectedImage = null;
  }

  // TODO эту функцию над овынести в утилиты
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(picked.path);
      final savedPath = '${appDir.path}/$fileName';
      final savedFile = await File(picked.path).copy(savedPath);
      selectedImage = savedFile;
      setState(() {});
    }
  }

  void saveProfile() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    var serverUri = serverUriController.text.trim();

    if (serverUri.isEmpty) {
      serverUriController.text = GlobalConst.serverUri;
      serverUri = GlobalConst.serverUri;
    }

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите имя и пароль')));
      return;
    }

    String? imageUri;
    if (selectedImage != null) {
      imageUri = selectedImage!.path;
    } else {
      imageUri = await AvatarUtils.generateAndSaveAvatarToFile(username);
    }

    profileCubit.updateProfile(
      Profile(
        userId: '',
        imageResId: 0,
        username: username,
        description: '',
        password: password,
        imageUri: imageUri,
        serverUri: serverUri,
      ),
    );
  }

  void profileCubitListener(BuildContext context, ProfileState state) {
    if (state is ProfileFailure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    } else if (state is ProfileLoaded) {
      context.pop();
    } else if (state is ProfileInitial) {
      clearFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      bloc: profileCubit,
      listener: profileCubitListener,
      builder: (context, profileState) {
        final isProfileLoading = profileState is ProfileLoading;
        final appText = profileState is! ProfileLoaded
            ? 'Добавить профиль'
            : 'Редактировать профиль';
        return Scaffold(
          appBar: AppBar(
            title: Text(appText),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.delete_outlined),
                onPressed: () => profileCubit.clearProfile(),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.primaryColor,
                    child: selectedImage != null
                        ? ClipOval(
                            child: Image.file(
                              selectedImage!,
                              width: 120, // = 2 * radius
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.add_a_photo, size: 60),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Имя пользователя',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Пароль'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: serverUriController,
                  decoration: const InputDecoration(labelText: 'URI сервера'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: isProfileLoading ? null : saveProfile,
              child: isProfileLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Сохранить профиль',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ),
        );
      },
    );
  }
}
