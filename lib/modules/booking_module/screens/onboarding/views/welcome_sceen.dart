import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/modules/auth_module/screens/login_screen.dart';
import 'package:u_go/modules/auth_module/screens/signin_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.images});

  /// Liste d'images (URL réseau ou assets). Si null → images de démo.
  final List<String>? images;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final PageController _pageController;
  late List<String> _images;
  int _index = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _images =
        widget.images ??
        [
          // Remplace par tes propres images (assets ou URLs)
          'assets/images/image-1.jpg',
          'assets/images/image-2.jpg',
          'assets/images/image-3.jpg',
          'assets/images/image-4.jpg',
        ];

    _pageController = PageController();
    _startAutoPlay();

    // Booster un peu le cache mémoire (sans impacter le rendu)
    final ic = PaintingBinding.instance.imageCache;
    ic.maximumSize = ic.maximumSize < 200 ? 200 : ic.maximumSize;
    ic.maximumSizeBytes = ic.maximumSizeBytes < (200 << 20)
        ? (200 << 20)
        : ic.maximumSizeBytes;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Précharge juste après la 1re frame pour ne pas bloquer l’affichage initial
    SchedulerBinding.instance.addPostFrameCallback((_) => _precacheAllImages());
  }

  // ===================== PRECHARGEMENT =====================

  Future<void> _precacheAllImages() async {
    if (!mounted) return;
    final futures = <Future<void>>[];

    for (final src in _images) {
      final provider = _providerFor(src);
      futures.add(precacheImage(provider, context));
    }

    try {
      await Future.wait(futures);
    } catch (_) {
      // on ignore les erreurs de préchargement
    }
  }

  void _precacheAround(int index) {
    if (!mounted || _images.isEmpty) return;

    Future<void> precacheString(String s) => precacheImage(_providerFor(s), context);

    precacheString(_images[index]);
    precacheString(_images[(index + 1) % _images.length]);
    precacheString(_images[(index - 1 + _images.length) % _images.length]);
  }

  ImageProvider _providerFor(String src) {
    if (_isUrl(src)) {
      // ✅ utilise le cache disque de cached_network_image
      return CachedNetworkImageProvider(src);
    }
    return AssetImage(src);
  }

  // ===================== AUTO PLAY =====================

  void _startAutoPlay() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      final next = (_index + 1) % _images.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  bool _isUrl(String s) => s.startsWith('http://') || s.startsWith('https://');

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final headerH = size.height * 0.75; // bloc image

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ======== ENTÊTE AVEC CARROUSEL + OVERLAY ========
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: SizedBox(
                height: headerH,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      allowImplicitScrolling: true, // pré-render des voisines
                      onPageChanged: (i) {
                        setState(() => _index = i);
                        _precacheAround(i);
                      },
                      itemCount: _images.length,
                      itemBuilder: (_, i) {
                        final src = _images[i];
                        return _KeepAlive(_buildImage(src));
                      },
                    ),

                    // overlay mainColor à 47%
                    Container(color: mainColor.withOpacity(0.47)),

                    // Titre
                    Align(
                      alignment: const Alignment(0, -0.7),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Text(
                          "Bienvenue",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: "Agbalumo",
                            fontSize: 56,
                            color: Colors.white,
                            height: 1.0,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black54,
                                offset: Offset(1, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Sous-titre
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 24.0,
                          right: 24.0,
                          bottom: 28.0,
                        ),
                        child: Text(
                          "U-GO, le covoiturage\nmade in Côte d’Ivoire",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: "Agbalumo",
                            fontSize: 18,
                            color: Colors.white,
                            height: 1.3,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black45,
                                offset: Offset(0.5, 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Indicateurs (dots)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_images.length, (i) {
                          final active = _index == i;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            height: 8,
                            width: active ? 22 : 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                active ? 0.95 : 0.6,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ======== BOUTONS ========
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ButtonComponent(
                      txtButton: "S’inscrire",
                      colorButton: Colors.white,
                      colorText: mainColor,
                      showBorder: true,
                      borderColor: mainColor,
                      borderWidth: 3.0,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignInScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ButtonComponent(
                      txtButton: "Se connecter",
                      colorButton: mainColor,
                      colorText: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== BUILD IMAGE =====================

  Widget _buildImage(String src) {
    if (_isUrl(src)) {
      // Réseau → cache disque + rendu gapless
      return CachedNetworkImage(
        imageUrl: src,
        fit: BoxFit.cover,
        // on masque tout effet de fade/placeholder pour l’instantané
        placeholder: (_, _) => const SizedBox.shrink(),
        errorWidget: (_, _, _) => const SizedBox.shrink(),
        placeholderFadeInDuration: Duration.zero,
        fadeInDuration: Duration.zero,
        imageBuilder: (ctx, provider) => Image(
          image: provider,
          fit: BoxFit.cover,
          gaplessPlayback: true, // évite les flashs entre frames
        ),
      );
    } else {
      // Assets → gapless
      return Image.asset(src, fit: BoxFit.cover, gaplessPlayback: true);
    }
  }
}

/// Garde chaque page du carrousel "vivante" pour éviter les reconstructions
class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive(this.child);

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
