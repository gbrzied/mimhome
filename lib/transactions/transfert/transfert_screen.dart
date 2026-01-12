import 'package:flutter/material.dart';
import 'package:millime/transactions/transfert/provider/transfert_provider.dart';
import 'package:provider/provider.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<TransferProvider>(
      create: (context) => TransferProvider(),
      child: TransferScreen(),
    );
  }

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransferProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.black),
        title: const Text('Transfert', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFieldLabel("Bénéficiaire"),
            _buildTextField(
              hint: "Mobile",
              onChanged: provider.updateMobile,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            
            _buildFieldLabel("Etablissement du bénéficiaire"),
            _buildDropdownField(provider),
            const SizedBox(height: 20),

            _buildFieldLabel("Montant"),
            _buildTextField(
              hint: "0,000",
              suffixText: "TND",
              onChanged: provider.updateAmount,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            _buildFieldLabel("Description"),
            _buildTextField(
              hint: "Description",
              onChanged: provider.updateDescription,
            ),
            
            const Spacer(),
            
            ElevatedButton(
              onPressed: () => provider.showConfirmation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D6978), // Couleur teal de l'image
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Valider", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
    );
  }

  Widget _buildTextField({required String hint, String? suffixText, Function(String)? onChanged, TextInputType? keyboardType}) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixText: suffixText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildDropdownField(TransferProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text("Etablissement du bénéficiaire", style: TextStyle(color: Colors.grey)),
          value: provider.transfer.establishment,
          items: provider.establishments.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: provider.updateEstablishment,
        ),
      ),
    );
  }
}