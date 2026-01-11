import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/utils/image_constant.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Données extraites des trois images
  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Flux paiement intelligent",
      "subtitle": "Contrôlez votre argent où et quand vous le souhaitez.",
      "image": ImageConstant.imgOnbording1, // Image 1
    },
    {
      "title": "Votre temps est de l'or",
      "subtitle": "Envoyez et recevez de l'argent en instantané et en toute sécurité.",
      "image": ImageConstant.imgOnbording2, // Image 2
    },
    {
      "title": "Simplifier votre facturation",
      "subtitle": "Automatisez vos paiements et vos factures",
      "image": ImageConstant.imgOnbording3, // Image 3
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF136779); // Bleu pétrole des boutons/titres
    const accentColor = Color(0xFFFFA500);  // Orange des liens/indicateurs
    const bgColor = Color(0xFFE6F3F3);      // Couleur de fond

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Icône Menu en haut à gauche
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(Icons.menu, color: primaryColor, size: 30),
              ),
            ),

            // Contenu défilant (Images + Textes)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => OnboardingContent(
                  title: _onboardingData[index]["title"]!,
                  subtitle: _onboardingData[index]["subtitle"]!,
                  image: _onboardingData[index]["image"]!,
                ),
              ),
            ),

            // Indicateurs de page (Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => _buildDot(index, _currentPage, accentColor),
              ),
            ),

            const SizedBox(height: 40),

            // Bouton principal (Dynamique : Continuer ou Commencer)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _onboardingData.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    } else {
                      // Action finale - Navigate back to login
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _onboardingData.length - 1 ? "Commencer" : "Continuer",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Footer (Sign In)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Avez-vous déjà un compte ? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "se connecter",
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour créer les points indicateurs animés
  Widget _buildDot(int index, int currentPage, Color color) {
    bool isActive = index == currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: isActive ? null : Border.all(color: Colors.black12),
      ),
    );
  }
}

// Widget interne pour le contenu de chaque page
class OnboardingContent extends StatelessWidget {
  final String title, subtitle, image;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        // Display the image based on file type
        _buildImageWidget(image),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF136779),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  // Widget to build image based on file type
  Widget _buildImageWidget(String imagePath) {
    if (imagePath.endsWith('.svg')) {
      return SvgPicture.asset(
        imagePath,
        height: 250,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        imagePath,
        height: 250,
        fit: BoxFit.contain,
      );
    }
  }
}
