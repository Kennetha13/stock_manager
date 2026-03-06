import 'package:flutter/material.dart';

AppBar buildPrimaryAppBar(BuildContext context, {required String title}) {
  final canGoBack = Navigator.of(context).canPop();

  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: 70,
    elevation: 0,
    centerTitle: true,
    backgroundColor: const Color(0xFF2E7D32),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
        ),
      ),
    ),
    leadingWidth: canGoBack ? 72 : 0,
    leading: canGoBack
        ? Padding(
            padding: const EdgeInsets.only(left: 14, top: 10, bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          )
        : null,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: Colors.white24),
    ),
  );
}
