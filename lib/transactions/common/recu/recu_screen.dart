import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:millime/transactions/common/recu/recu_model.dart'; // Add intl to pubspec.yaml for date formatting

class ReceiptPage extends StatelessWidget {
  final ReceiptModel data;

  const ReceiptPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    // Formatting date and time
    final String formattedDate = DateFormat('dd-MM-yyyy').format(data.timestamp);
    final String formattedTime = DateFormat('HH:mm').format(data.timestamp);

    // List for the dynamic middle section
    final List<Map<String, String>> infoRows = [
      {'label': 'Code autorisation', 'value': data.authorizationCode},
      {'label': 'Bénéficiaire', 'value': data.beneficiary},
      {'label': 'Référence Facture', 'value': data.invoiceReference},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new, size: 20),
        title: const Text('Recu paiement', style: TextStyle(fontSize: 18)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            _buildHeaderPill(data.title),
            const SizedBox(height: 20),
            Text(
              '$formattedDate\n$formattedTime',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF136472), fontWeight: FontWeight.bold),
            ),
            const Divider(height: 40, thickness: 0.5),

            // Info rows using the list generated from the model
            ...infoRows.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['label']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(item['value']!, style: const TextStyle(color: Color(0xFF136472), fontWeight: FontWeight.bold)),
                ],
              ),
            )),

            const SizedBox(height: 20),
            _buildAmountCard(),
            const SizedBox(height: 20),
            _buildBalanceCard(),
            
            const SizedBox(height: 30),
            const Text('DESCRIPTION', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(data.description, style: const TextStyle(color: Color(0xFF136472), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- Helper methods using the 'data' model ---

  Widget _buildHeaderPill(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF136472)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(text, style: const TextStyle(color: Color(0xFF136472), fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF136472), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _row('Montant', '${data.amount.toStringAsFixed(3)} TND', Colors.white),
          _row('Commission HT', '${data.commission.toStringAsFixed(3)} TND', Colors.white),
          _row('TVA', '${data.tva.toStringAsFixed(3)} TND', Colors.white),
          const Divider(color: Colors.white54, height: 25),
          _row('Total', '${data.total.toStringAsFixed(3)} TND', Colors.white, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFE1F9F8), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _row('Solde initial', '${data.initialBalance.toStringAsFixed(3)} TND', Colors.grey[600]!, isBold: false),
          const SizedBox(height: 10),
          _row('Nouveau Solde', '${data.newBalance.toStringAsFixed(3)} TND', const Color(0xFF136472), isBold: true, isTotal: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color, {bool isBold = true, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 14)),
        Text(value, style: TextStyle(color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
      ],
    );
  }
}




