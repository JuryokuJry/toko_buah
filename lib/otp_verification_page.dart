// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'home_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String generatedOtp; // Tambahkan ini untuk menyimpan OTP

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.generatedOtp,
  });

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  // Mengecek koneksi internet
  Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    String enteredOtp = _otpController.text;

    if (!await isConnected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada koneksi internet.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Verifikasi OTP secara lokal
    if (enteredOtp == widget.generatedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verifikasi berhasil!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP salah. Silakan coba lagi.')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100],
      appBar: AppBar(
        title: const Text('Verifikasi OTP'),
        backgroundColor: Colors.greenAccent[400],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Masukkan kode OTP yang telah dikirim ke nomor Anda',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'Kode OTP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent[400],
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verifikasi OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
