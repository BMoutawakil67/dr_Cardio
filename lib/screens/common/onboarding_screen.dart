import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Suivez votre tension\nen toute simplicité',
      description: 'Enregistrez vos mesures\npar photo ou manuellement',
      icon: Icons.monitor_heart_outlined,
      imagePath:
          'assets/images/onboarding_background.png', // Image pour la slide 1
    ),
    OnboardingPage(
      title: 'Restez connecté avec\nvotre cardiologue',
      description: 'Messagerie, téléconsultation\net alertes en temps réel',
      icon: Icons.medical_services_outlined,
      imagePath:
          'assets/images/onboarding_background2.png', // Image pour la slide 2
    ),
    OnboardingPage(
      title: 'Analysez vos progrès',
      description: 'Graphiques, statistiques\net conseils personnalisés',
      icon: Icons.analytics_outlined,
      imagePath:
          'assets/images/onboarding_background3.png', // Image pour la slide 3
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arrière-plan animé qui change avec la page
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Image.asset(
              _pages[_currentPage].imagePath,
              key: ValueKey<int>(
                  _currentPage), // Clé unique pour forcer la reconstruction
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Overlay sombre pour améliorer la lisibilité
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // Le contenu original de votre page
          SafeArea(
            child: Column(
              children: [
                // Bouton Passer
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => _navigateToProfileChoice(),
                    child: const Text(
                      'Passer →',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                // Indicateurs de pagination
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icône en blanc
                            Icon(
                              page.icon,
                              size: 150,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 48),
                            // Titre en blanc
                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            // Description en blanc
                            Text(
                              page.description,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bouton Suivant/Commencer (toujours en bleu)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _navigateToProfileChoice();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Commencer'
                            : 'Suivant',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProfileChoice() {
    Navigator.pushReplacementNamed(context, AppRoutes.profileChoice);
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final String imagePath;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.imagePath,
  });
}
