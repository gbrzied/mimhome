import 'package:flutter/material.dart';

// Définition de la classe de l'écran (Widget d'état)
class AccountRecoveryScreen extends StatefulWidget {
  const AccountRecoveryScreen({super.key});

  @override
  State<AccountRecoveryScreen> createState() => _AccountRecoveryScreenState();
}

class _AccountRecoveryScreenState extends State<AccountRecoveryScreen> {
  // Contrôleurs de texte pour les champs de saisie (pour la gestion des données)
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // État pour déterminer si le bouton "Confirmer" doit être activé
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    // Écouter les changements dans les champs de texte
    _phoneController.addListener(_checkConfirmationStatus);
    _emailController.addListener(_checkConfirmationStatus);
  }

  // Fonction pour vérifier si au moins un des champs n'est pas vide
  void _checkConfirmationStatus() {
    final bool hasInput = _phoneController.text.isNotEmpty || _emailController.text.isNotEmpty;
    if (hasInput != _canConfirm) {
      setState(() {
        _canConfirm = hasInput;
      });
    }
  }

  @override
  void dispose() {
    // Nettoyer les contrôleurs lorsqu'ils ne sont plus nécessaires
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Thème de couleur principal (basé sur le bouton bleu/vert foncé)
    const Color primaryColor = Color(0xFF1E6C7D);
    // Couleur de fond des boutons désactivés (gris clair)
    const Color disabledButtonColor = Color(0xFFDCDCDC);

    // Couleur du texte désactivé
    const Color disabledTextColor = Color(0xFF757575);

    return Scaffold(
      // 1. App Bar personnalisé avec barre de progression
      appBar: AppBar(
        // L'icône de retour (la flèche)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Logique de navigation 'Précédent'
            Navigator.pop(context);
          },
        ),
        // Suppression de l'ombre/élévation
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Row(
          children: [
            // Barre de progression (étape 5/5)
            Expanded(
              child: LinearProgressIndicator(
                // La valeur 5/5 = 1.0 (complètement rempli)
                value: 1.0, 
                backgroundColor: disabledButtonColor,
                valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 8),
            // Indication de l'étape
            const Text('5/5', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),

      // 2. Corps de l'écran (Titre, description et champs de saisie)
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Titre principal
            const Text(
              'Récupération du compte',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Description
            const Text(
              'Entrez vos coordonnées de récupération pour sécuriser l\'accès à votre compte.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // --- Champ Téléphone de récupération ---
            const Text(
              'Téléphone de récupération',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone, // Clavier numérique pour téléphone
              decoration: InputDecoration(
                hintText: 'Saisir votre téléphone de récupération',
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Champ Email de récupération ---
            const Text(
              'Email de récupération',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress, // Clavier adapté pour l'email
              decoration: InputDecoration(
                hintText: 'Saisir votre email de récupération',
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),

            // Espace pour pousser les boutons vers le bas
            const Spacer(), 
          ],
        ),
      ),

      // 3. Barre de boutons en bas
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0, top: 10.0),
        // S'assurer qu'il y a un espace sûr en bas (encoche, etc.)
        child: SafeArea( 
          top: false,
          child: Row(
            children: <Widget>[
              // Bouton 'Précédent'
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      // Logique 'Précédent'
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      // Pas de bordure visible pour l'effet de bouton plein
                      side: BorderSide.none, 
                    ),
                    child: const Text(
                      'Précédent',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Bouton 'Confirmer' (activé/désactivé)
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _canConfirm ? () {
                      // Logique 'Confirmer' (actif)
                      print('Téléphone: ${_phoneController.text}, Email: ${_emailController.text}');
                    } : null, // null désactive le bouton
                    style: ElevatedButton.styleFrom(
                      // Couleur de fond selon l'état
                      backgroundColor: _canConfirm ? disabledButtonColor : disabledButtonColor, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      // Pas d'ombre
                      elevation: 0, 
                    ),
                    child: Text(
                      'Confirmer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        // Couleur du texte selon l'état
                        color: _canConfirm ? Colors.black : disabledTextColor, 
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget principal pour l'exécution
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AccountRecoveryScreen(),
    );
  }
}