import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPage extends StatefulWidget {
  const ResetPage({super.key});

  @override
  State<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? phoneNumber;
  String? generatedOtp;
  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String generateOTP() {
    final random = Random();
    int otp = 100000 + random.nextInt(900000);
    return otp.toString();
  }

  Future<bool> sendOTP(String phoneNumber, String otp) async {
    const String apiKey =
        'cYB4g3XrFiHSVJ28uyTi'; // Ganti dengan API Key Fonnte Anda
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

  Future<void> fetchPhoneNumber() async {
    setState(() {
      isLoading = true;
    });
    try {
      String email = emailController.text.trim();

      if (email.isNotEmpty) {
        QuerySnapshot query = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          phoneNumber = query.docs.first.get('phone');
          generatedOtp = generateOTP();

          bool otpSent = await sendOTP(phoneNumber!, generatedOtp!);

          if (otpSent) {
            setState(() {
              isOtpSent = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kode OTP telah dikirim')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal mengirim OTP')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email tidak ditemukan')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email harus diisi')),
        );
      }
    } catch (e) {
      print("Error fetchPhoneNumber: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil nomor telepon: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void verifyOtp() {
    if (otpController.text.trim() == generatedOtp) {
      setState(() {
        isOtpVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP berhasil diverifikasi')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP tidak valid')),
      );
    }
  }

  Future<void> changePasswordWithoutLogin() async {
    setState(() {
      isLoading = true;
    });

    try {
      String newPassword = passwordController.text.trim();
      String email = emailController.text.trim();

      // Validasi input
      if (newPassword.isEmpty || newPassword.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password minimal 6 karakter')),
        );
        return;
      }

      // Cari user berdasarkan email dan tandai perubahan password
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        String userId = query.docs.first.id;

        await _firestore.collection('users').doc(userId).update({
          'passwordChanged': true, // Tanda perubahan password
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diperbarui')),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email tidak ditemukan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui password: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100],
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.greenAccent[400],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isOtpSent && !isOtpVerified) ...[
                  const Text(
                    'Masukkan email Anda untuk mendapatkan kode OTP.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: fetchPhoneNumber,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                    ),
                    child: const Text('Kirim OTP'),
                  ),
                ] else if (isOtpSent && !isOtpVerified) ...[
                  const Text(
                    'Masukkan kode OTP yang telah dikirim.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: otpController,
                    decoration: const InputDecoration(
                      labelText: 'Kode OTP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                    ),
                    child: const Text('Verifikasi OTP'),
                  ),
                ] else if (isOtpVerified) ...[
                  const Text(
                    'Masukkan password baru Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password Baru',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: changePasswordWithoutLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                    ),
                    child: const Text('Ganti Password'),
                  ),
                ],
              ],
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
