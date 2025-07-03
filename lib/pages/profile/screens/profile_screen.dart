import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart'; // For fade-in animation
import '../bloc/profile_bloc.dart';
import '../../../models/user.dart';
import '../bloc/profile_state.dart';
import '../bloc/profile_event.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        userId: 1, // TODO: Fetch actual userId from state or API
        username: _usernameController.text,
        passwordHash: '', // TODO: Handle password securely if needed
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        fullName: _nameController.text,
        dateOfBirth: _dobController.text,
        gender: _genderController.text,
      );
      final bloc = context.read<ProfileBloc>();
      bloc.add(UpdateProfileEvent(user: user));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _nameController.text = state.user.fullName;
          _emailController.text = state.user.email;
          _phoneController.text = state.user.phoneNumber;
          _usernameController.text = state.user.username;
          _dobController.text = state.user.dateOfBirth;
          _genderController.text = state.user.gender;
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.green[900],
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green[800]!, Colors.green[900]!],
            ),
          ),
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              } else if (state is ProfileLoaded) {
                return FadeIn(
                  duration: const Duration(milliseconds: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            children: [
                              const Center(
                                child: Text(
                                  'Edit Your Profile',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter your full name'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter a username'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) => !value!.contains('@')
                                    ? 'Please enter a valid email'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Phone',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter your phone number'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _dobController,
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter your date of birth'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _genderController,
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter your gender'
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else if (state is ProfileError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              }
              return const Center(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
