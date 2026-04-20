import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/welcome_content.dart';
import '../home/home_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int currentPage = 0;
  final PageController _pageController = PageController();

  final List<WelcomeContent> welcomeList = [
    WelcomeContent(
      newsTitle: 'News',
      newsDescription:
          'Round of 32 takeaway: low\'s shocking upset, Big TEN runs Sweat 16',
      backgroundImage:
          'https://media.wallpics.app/upscaled/2025/11/06/KJ1XwIZAkbu0Z09lSAd4oGcA44s5xPEA9h9WRIlU.webp',
    ),
    WelcomeContent(
      newsTitle: 'Updates',
      newsDescription:
          'Latest match highlights and player statistics from around the world',
      backgroundImage: 'https://wallpapercave.com/wp/wp12674885.jpg',
    ),
    WelcomeContent(
      newsTitle: 'Trending',
      newsDescription:
          'Top performers and thrilling moments from this week\'s games',
      backgroundImage:
          'https://i.pinimg.com/736x/9e/ef/d4/9eefd4c90b8ce59d6b4a3fe1dc79c781.jpg',
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
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        itemCount: welcomeList.length,
        itemBuilder: (context, index) {
          return _buildWelcomeScreen(welcomeList[index], index);
        },
      ),
    );
  }

  Widget _buildWelcomeScreen(WelcomeContent content, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(content.backgroundImage),
              fit: BoxFit.cover,
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // SizedBox(
            //   height: MediaQuery.of(context).padding.top,
            // ),

            // Expanded(
            //   flex: 3,
            //   child: Center(
            //     child: Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 24),
            //       child: Text(
            //         content.newsTitle,
            //         textAlign: TextAlign.center,
            //         style: const TextStyle(
            //           fontSize: 32,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.white,
            //           letterSpacing: 1.2,
            //           height: 1.3,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildNewsSection(content),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildProgressDots(),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ],
    );
  }

  Widget _buildNewsSection(WelcomeContent content) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // News Title
              Text(
                content.newsTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              // News Description
              Text(
                content.newsDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.3,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              // Buttons inside card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _navigateToHome();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (currentPage < welcomeList.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _navigateToHome();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC857),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 6,
                      ),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      currentPage == welcomeList.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        welcomeList.length,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: i == currentPage ? 24 : 8,
          height: 3,
          decoration: BoxDecoration(
            color: i == currentPage ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }
}
