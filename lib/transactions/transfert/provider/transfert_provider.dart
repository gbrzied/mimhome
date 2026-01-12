import 'package:flutter/material.dart';
import 'package:millime/core/utils/navigator_service.dart';
import 'package:millime/routes/app_routes.dart';
import 'package:millime/transactions/common/confirmation/confirmation_dialog.dart';
import 'package:millime/transactions/common/recu/recu_model.dart';
import 'package:millime/transactions/transfert/model/transfert_model.dart';

class TransferProvider extends ChangeNotifier {
  final TransferModel _transfer = TransferModel();
  
  // Liste fictive d'établissements
  final List<String> establishments = ['Banque Centrale', 'Poste Tunisienne', 'Banque de Tunisie'];

  TransferModel get transfer => _transfer;

  void updateMobile(String value) {
    _transfer.mobile = value;
    notifyListeners();
  }

  void updateEstablishment(String? value) {
    _transfer.establishment = value;
    notifyListeners();
  }

  void updateAmount(String value) {
    _transfer.amount = double.tryParse(value) ?? 0.0;
    notifyListeners();
  }

  void updateDescription(String value) {
    _transfer.description = value;
    notifyListeners();
  }

  void validateTransfer() {
    // Logique d'envoi ou de validation
    print("Transfert validé pour: ${_transfer.mobile}, Montant: ${_transfer.amount} TND");
  }



  Future<void> showConfirmation(BuildContext context) async {
    final Map<String, String> transactionData = {
      'Opération': 'Paiement OFF US',
      'Bénéficiaire': _transfer.establishment ?? 'Non spécifié',
      'Référence Facture': '112233445566',
      'Montant': '${_transfer.amount.toStringAsFixed(3)} TND',
      'TVA': '0.064 TND',
    };

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ConfirmationDialog(
        details: transactionData,
        description: _transfer.description ?? 'Paiement SONEDE',
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          print("Payment Processed!");
          Navigator.pop(context);
          
          // Create receipt and navigate to receipt screen
          final receipt = ReceiptModel(
            title: 'Paiement OFF US',
            timestamp: DateTime.now(),
            authorizationCode: 'UL2FTF',
            beneficiary: _transfer.establishment ?? 'SONEDE',
            invoiceReference: '1122334455667711',
            amount: _transfer.amount,
            commission: 0.336,
            tva: 0.064,
            total: _transfer.amount,
            initialBalance: 200.0,
            newBalance: 200.0 - _transfer.amount,
            description: _transfer.description ?? 'Paiement SONEDE',
          );
          
          NavigatorService.pushNamed(AppRoutes.receiptScreen, arguments: receipt);
        },
      ),
    );
  }
}