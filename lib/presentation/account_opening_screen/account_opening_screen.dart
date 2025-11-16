import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// State Management with Provider
class AccountTypeProvider extends ChangeNotifier {
  String? _selectedAccountType;

  String? get selectedAccountType => _selectedAccountType;

  void selectAccountType(String type) {
    _selectedAccountType = type;
    notifyListeners();
  }

  bool get canProceed => _selectedAccountType != null;
}

// Main Page
class AccountOpeningPage extends StatelessWidget {
  const AccountOpeningPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccountTypeProvider(),
      child: const AccountOpeningView(),
    );
  }

  
}

class AccountOpeningView extends StatelessWidget {
  const AccountOpeningView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AccountTypeProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.2,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D5F7F),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '1/5',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Demande d'ouvrir un compte",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "L'ouverture de votre compte s'effectue en 4 étapes. Entrez les informations nécessaires pour assurer votre sécurité et la confidentialité de vos données.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Choisir Type du compte",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AccountTypeCard(
                      icon: Icons.person_outline,
                      title: "Personne Physique",
                      subtitle: "Compte personnel pour particuliers",
                      isSelected: provider.selectedAccountType == 'physical',
                      onTap: () => provider.selectAccountType('physical'),
                    ),
                    const SizedBox(height: 16),
                    AccountTypeCard(
                      icon: Icons.business_outlined,
                      title: "Personne Morale",
                      subtitle: "Compte professionnel pour entreprises",
                      isSelected: provider.selectedAccountType == 'legal',
                      onTap: () => provider.selectAccountType('legal'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: provider.canProceed
                      ? () {
                          // Navigate to next page
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Compte sélectionné: ${provider.selectedAccountType == 'physical' ? 'Personne Physique' : 'Personne Morale'}',
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.canProceed
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFFE5E7EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    disabledForegroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Suivant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const AccountTypeCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF2D5F7F) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                icon,
                size: 32,
                color: const Color(0xFF2D5F7F),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// // Example usage in main.dart
// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Account Opening',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'SF Pro',
//       ),
//       home: const AccountOpeningPage(),
//     );
//   }
// }