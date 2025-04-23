import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateInvoiceScreen extends StatelessWidget {
  const CreateInvoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Invoice'),
      ),
      body: Center(
        child: Text(
          'Create Invoice Screen\nThis will be implemented in the next phase.',
          style: GoogleFonts.poppins(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
} 