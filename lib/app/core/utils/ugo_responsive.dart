// lib/utils/ugo_responsive.dart
import 'package:flutter/material.dart';

/// ===========================================================================
/// UGO RESPONSIVE KIT
/// ===========================================================================
/// Objectif : rendre tes écrans confortables et sans débordements,
/// sans changer ton design.
/// - Gère le scroll quand le contenu est plus grand que l'écran.
/// - Évite les "RenderFlex overflowed" (clavier, petits écrans).
/// - Centre le contenu et limite une largeur max (propre sur tablette/web).
/// - Fournit des helpers (breakpoints, tailles adaptatives, grilles, visibilité).
/// ===========================================================================

/// --------------------------- BREAKPOINTS -----------------------------------
class UGoBreakpoints {
  static const double phoneSmall = 0; // < 360
  static const double phone = 360; // 360 - 599
  static const double tablet = 600; // 600 - 1023
  static const double desktop = 1024; // >= 1024
}

enum UGoDeviceSize { phoneSmall, phone, tablet, desktop }

UGoDeviceSize ugoDeviceFor(double width) {
  if (width >= UGoBreakpoints.desktop) return UGoDeviceSize.desktop;
  if (width >= UGoBreakpoints.tablet) return UGoDeviceSize.tablet;
  if (width >= UGoBreakpoints.phone) return UGoDeviceSize.phone;
  return UGoDeviceSize.phoneSmall;
}

/// ----------------------------- SIZE HELPER ---------------------------------
/// Fournit des tailles "propres" selon la largeur de l'écran.
class UGoSize {
  final BuildContext context;
  final double width;
  final double height;
  final UGoDeviceSize device;

  UGoSize._(this.context, this.width, this.height, this.device);

  bool get isSmallPhone => device == UGoDeviceSize.phoneSmall;
  bool get isPhone => device == UGoDeviceSize.phone;
  bool get isTablet => device == UGoDeviceSize.tablet;
  bool get isDesktop => device == UGoDeviceSize.desktop;

  /// Taille base texte
  double get fontBase => switch (device) {
    UGoDeviceSize.phoneSmall => 12,
    UGoDeviceSize.phone => 14,
    UGoDeviceSize.tablet => 16,
    UGoDeviceSize.desktop => 16,
  };

  /// Espace standard
  double get gap => isSmallPhone ? 8 : (isTablet || isDesktop ? 16 : 12);

  /// Rayons par défaut
  double get radius => isSmallPhone ? 10 : 12;

  /// Padding par défaut
  EdgeInsets get defaultPadding =>
      EdgeInsets.symmetric(horizontal: gap, vertical: gap * 0.75);

  static UGoSize of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final device = ugoDeviceFor(size.width);
    return UGoSize._(context, size.width, size.height, device);
  }
}

/// --------------------------- RESPONSIVE WRAPPER -----------------------------
/// Enveloppe ton UI pour:
/// - gérer le clavier et le scroll,
/// - centrer et limiter la largeur,
/// - éviter les débordements verticaux.
class UGoResponsive extends StatelessWidget {
  final Widget child;

  /// Largeur max du conteneur central (420 = parfait mobile)
  final double maxWidth;

  /// Padding autour du contenu
  final EdgeInsets? padding;

  /// Cliquer à l'extérieur ferme le clavier
  final bool dismissKeyboardOnTap;

  /// Forcer une couleur de fond (sinon hérite du Scaffold)
  final Color? background;

  /// Utiliser SafeArea (true par défaut)
  final bool useSafeArea;

  const UGoResponsive({
    super.key,
    required this.child,
    this.maxWidth = 420,
    this.padding,
    this.dismissKeyboardOnTap = true,
    this.background,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final sz = UGoSize.of(context);
    final pad = padding ?? sz.defaultPadding;

    Widget core = LayoutBuilder(
      builder: (context, constraints) {
        final insets = MediaQuery.viewInsetsOf(context); // hauteur clavier
        Widget content = SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: pad.add(EdgeInsets.only(bottom: insets.bottom)),
                  child: child,
                ),
              ),
            ),
          ),
        );

        // Option SafeArea
        if (useSafeArea) content = SafeArea(child: content);

        // Couleur d’arrière-plan
        if (background != null) {
          content = ColoredBox(color: background!, child: content);
        }
        return content;
      },
    );

    if (!dismissKeyboardOnTap) return core;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: core,
    );
  }
}

/// ----------------------------- SCAFFOLD AID ---------------------------------
/// Scaffold avec UGoResponsive déjà branché.
class UGoScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget child;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final double maxWidth;
  final EdgeInsets? padding;
  final bool dismissKeyboardOnTap;
  final bool resizeToAvoidBottomInset;
  final bool useSafeArea;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;

  const UGoScaffold({
    super.key,
    this.appBar,
    required this.child,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.maxWidth = 420,
    this.padding,
    this.dismissKeyboardOnTap = true,
    this.resizeToAvoidBottomInset = true,
    this.useSafeArea = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: UGoResponsive(
        maxWidth: maxWidth,
        padding: padding,
        dismissKeyboardOnTap: dismissKeyboardOnTap,
        background: backgroundColor,
        useSafeArea: useSafeArea,
        child: child,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

/// ----------------------------- GRID LAYOUT ----------------------------------
/// Grille responsive: 1 col (mobile), 2 (tablette), 3/4 (desktop) automatiquement.
class UGoGrid extends StatelessWidget {
  final List<Widget> children;

  /// Padding externe
  final EdgeInsets outerPadding;

  /// Espacement entre items
  final double spacing;

  /// Hauteur minimale d’une tuile (optionnel, pour des cartes homogènes)
  final double? minTileHeight;

  const UGoGrid({
    super.key,
    required this.children,
    this.outerPadding = const EdgeInsets.all(12),
    this.spacing = 12,
    this.minTileHeight,
  });

  int _columns(double width) {
    if (width >= 1400) return 5;
    if (width >= UGoBreakpoints.desktop) return 4;
    if (width >= 900) return 3;
    if (width >= UGoBreakpoints.tablet) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = _columns(w);

    return LayoutBuilder(
      builder: (context, c) {
        return Padding(
          padding: outerPadding,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: minTileHeight == null
                  ? 1
                  : (c.maxWidth / cols) / minTileHeight!,
            ),
            itemBuilder: (_, i) => children[i],
          ),
        );
      },
    );
  }
}

/// ----------------------------- RESPONSIVE VALUE -----------------------------
/// Sélectionner une valeur selon la taille (utile pour tailles/espaces).
T ugoValue<T>({
  required BuildContext context,
  required T phone,
  T? smallPhone,
  T? tablet,
  T? desktop,
}) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= UGoBreakpoints.desktop && desktop != null) return desktop;
  if (w >= UGoBreakpoints.tablet && tablet != null) return tablet;
  if (w < UGoBreakpoints.phone && smallPhone != null) return smallPhone;
  return phone;
}

/// ----------------------------- VISIBILITÉ -----------------------------------
/// Afficher / masquer un bloc selon le form factor.
class UGoVisibility extends StatelessWidget {
  final Widget child;
  final bool phoneSmall;
  final bool phone;
  final bool tablet;
  final bool desktop;

  const UGoVisibility({
    super.key,
    required this.child,
    this.phoneSmall = true,
    this.phone = true,
    this.tablet = true,
    this.desktop = true,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final d = ugoDeviceFor(w);
    final ok = switch (d) {
      UGoDeviceSize.phoneSmall => phoneSmall,
      UGoDeviceSize.phone => phone,
      UGoDeviceSize.tablet => tablet,
      UGoDeviceSize.desktop => desktop,
    };
    return ok ? child : const SizedBox.shrink();
  }
}
