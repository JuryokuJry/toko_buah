import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'otp_verification_page.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.teal[100],
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.greenAccent[400],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Image.network(
              'https://masterbundles.com/wp-content/uploads/2023/06/fresh-vegetables-logo-411-931x1024.png',
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'Register',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (passwordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password tidak cocok!')),
                  );
                  return;
                }

                try {
                  // Mendaftar pengguna baru
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );

                  final user = userCredential.user;
                  if (user != null) {
                    // Simpan data pengguna ke Firestore
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .set({
                      'username': usernameController.text,
                      'email': emailController.text,
                      'phone': phoneController.text,
                    });

                    // Generate OTP
                    String otp = generateOTP();

                    // Kirim OTP menggunakan Fonnte
                    bool otpSent = await sendOTP(phoneController.text, otp);

                    if (otpSent) {
                      // Arahkan ke halaman OTP Verification
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtpVerificationPage(
                            phoneNumber: phoneController.text,
                            generatedOtp: otp, // Kirim OTP ke halaman OTP
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Gagal mengirim OTP, coba lagi!')),
                      );
                    }
                  }
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message ?? 'Terjadi kesalahan'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.greenAccent[400],
              ),
              child: const Text('Register'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Or',
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk menghasilkan OTP acak
  String generateOTP() {
    final random = Random();
    int otp = 100000 + random.nextInt(900000);
    return otp.toString();
  }

  // Fungsi untuk mengirim OTP menggunakan Fonnte
  Future<bool> sendOTP(String phoneNumber, String otp) async {
    const String apiKey = 'cYB4g3XrFiHSVJ28uyTi'; // API Key
    const String apiUrl = 'https://api.fonnte.com/send';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'target': phoneNumber,
          'message': 'Kode OTP Anda adalah: $otp',
        }),
      );

      if (response.statusCode == 200) {
        print('OTP sent successfully');
        return true;
      } else {
        print('Failed to send OTP: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }
}
