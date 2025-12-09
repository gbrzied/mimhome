import 'package:flutter/material.dart';
import '../../theme/text_style_helper.dart';

// Définition de la classe de l'écran de fin d'inscription
class EnrollmentSuccessScreen extends StatelessWidget {
  const EnrollmentSuccessScreen({super.key});

  // --- VALEURS DE DESIGN AJOURNÉES ---
  // Couleurs
  final Color primaryTeal = const Color(0xFF1E6C7D); // Couleur de la barre de progression
  final Color iconGrey = const Color(0xFFAAAAAA);     // Couleur du Pouce levé
  final Color lightGreyCircle = const Color(0xFFF0F0F0); // Couleur du cercle d'icône
  final Color darkText = const Color(0xFF1E1E1E);      // Titre principal
  final Color mediumGreyText = const Color(0xFF606060); // Texte secondaire
  
  // Tailles de Police
  final double mainTitleSize = 34.0; 
  final double descriptionSize = 18.0; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // 1. App Bar avec la Barre de progression
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: 1.0, 
                backgroundColor: lightGreyCircle,
                valueColor: AlwaysStoppedAnimation<Color>(primaryTeal),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            // Indication de l'étape
            const Text(
              '5/5', 
              style: TextStyle(
                fontSize: 14, 
                color: Colors.black54
              )
            ),
          ],
        ),
      ),

      // 2. Corps de l'écran centré
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, 
            children: <Widget>[
              // Icône de confirmation (Pouce levé)
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: lightGreyCircle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.thumb_up_alt,
                  size: 80,
                  color: iconGrey,
                ),
              ),

              const SizedBox(height: 30),

              // Titre principal
              Text(
                'Merci',
                textAlign: TextAlign.center,
                style: TextStyleHelper.instance.title38BoldQuicksand,
              ),

              const SizedBox(height: 15),

              // Message 1 : Inscription réussie
              Text(
                'votre inscription est faite avec\nsuccées',
                textAlign: TextAlign.center,
                style: TextStyleHelper.instance.title20RegularQuicksand,
              ),

              const SizedBox(height: 10),

              // Message 2 : Statut de la demande
              Text(
                'Votre compte est actif',
                textAlign: TextAlign.center,
                style: TextStyleHelper.instance.title14SemiBoldQuicksand,
              ),
              
              // Espace pour le centrage
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
    );
  }
}

