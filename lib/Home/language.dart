// lib/Home/language.dart - Updated with proper navigation handling
import 'package:flutter/material.dart';
import 'package:flutter_circle_flags_svg/flutter_circle_flags_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scanmyfood/services/language_service.dart';

// Add the extension for translate method
extension LanguageServiceTranslate on BuildContext {
  String tr(String key, [String? fallback]) {
    return LanguageService.instance.translate(key, fallback ?? key);
  }
}

class Language extends StatefulWidget {
  const Language({Key? key}) : super(key: key);

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final LanguageService _languageService = LanguageService.instance;
  String selectedLanguage = 'English';
  String searchQuery = '';
  bool _isChangingLanguage = false;

  @override
  void initState() {
    super.initState();
    selectedLanguage = _languageService.currentLanguage;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<Map<String, String>> languages = [
    {'name': 'English', 'flag': 'gb', 'code': 'en'},
    {'name': 'Spanish', 'flag': 'es', 'code': 'es'},
    {'name': 'Swedish', 'flag': 'se', 'code': 'sv'},
    {'name': 'French', 'flag': 'fr', 'code': 'fr'},
    {'name': 'German', 'flag': 'de', 'code': 'de'},
    {'name': 'Italian', 'flag': 'it', 'code': 'it'},
    {'name': 'Portuguese', 'flag': 'pt', 'code': 'pt'},
    {'name': 'Dutch', 'flag': 'nl', 'code': 'nl'},
    {'name': 'Polish', 'flag': 'pl', 'code': 'pl'},
    {'name': 'Russian', 'flag': 'ru', 'code': 'ru'},
    {'name': 'Chinese', 'flag': 'cn', 'code': 'zh'},
    {'name': 'Japanese', 'flag': 'jp', 'code': 'ja'},
    {'name': 'Korean', 'flag': 'kr', 'code': 'ko'},
    {'name': 'Arabic', 'flag': 'sa', 'code': 'ar'},
    {'name': 'Hindi', 'flag': 'in', 'code': 'hi'},
    {'name': 'Turkish', 'flag': 'tr', 'code': 'tr'},
    {'name': 'Greek', 'flag': 'gr', 'code': 'el'},
    {'name': 'Hebrew', 'flag': 'il', 'code': 'he'},
    {'name': 'Norwegian', 'flag': 'no', 'code': 'no'},
    {'name': 'Danish', 'flag': 'dk', 'code': 'da'},
    {'name': 'Finnish', 'flag': 'fi', 'code': 'fi'},
    {'name': 'Czech', 'flag': 'cz', 'code': 'cs'},
    {'name': 'Hungarian', 'flag': 'hu', 'code': 'hu'},
    {'name': 'Romanian', 'flag': 'ro', 'code': 'ro'},
  ];

  // Filter out only supported languages for now
  List<Map<String, String>> get supportedLanguages {
    return languages
        .where((lang) =>
            LanguageService.supportedLanguages.containsKey(lang['name']))
        .toList();
  }

  List<Map<String, String>> get filteredLanguages {
    if (searchQuery.isEmpty) return supportedLanguages;
    return supportedLanguages
        .where((lang) =>
            lang['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void _selectLanguage(String language) async {
    if (_isChangingLanguage) return;

    setState(() {
      _isChangingLanguage = true;
    });

    try {
      await _languageService.changeLanguage(language);

      setState(() {
        selectedLanguage = language;
        _isChangingLanguage = false;
      });

      Fluttertoast.showToast(
        msg:
            "${_languageService.translate('language.languageChanged', 'Language changed to')} $language",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Trigger a rebuild of the entire app to reflect language changes
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      setState(() {
        _isChangingLanguage = false;
      });

      Fluttertoast.showToast(
        msg: _languageService.translate('common.error', 'An error occurred'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                // App Bar - FIXED: Proper back button handling
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: isTablet ? 180 : 140,
                  floating: false,
                  pinned: true,
                  // CRITICAL FIX: Show back button when navigation is possible
                  leading: Navigator.of(context).canPop()
                      ? IconButton(
                          icon: Icon(
                            Theme.of(context).platform == TargetPlatform.iOS
                                ? Icons.arrow_back_ios
                                : Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      : null,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 32 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: isTablet ? 32 : 28,
                                  height: isTablet ? 32 : 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.asset(
                                      'assets/app_logo.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.language,
                                  color: Colors.white,
                                  size: isTablet ? 28 : 24,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _languageService.translate(
                                  'language.title', 'Choose Language'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 32 : 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _languageService.translate('language.subtitle',
                                  'Select your preferred language'),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isTablet ? 18 : 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        style: TextStyle(fontSize: isTablet ? 18 : 16),
                        decoration: InputDecoration(
                          hintText: _languageService.translate(
                              'language.searchLanguages',
                              'Search languages...'),
                          hintStyle: TextStyle(
                            color: const Color(0xFF94A3B8),
                            fontSize: isTablet ? 18 : 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: const Color(0xFF94A3B8),
                            size: isTablet ? 24 : 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
                        ),
                      ),
                    ),
                  ),
                ),

                // Current Selection
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF10B981).withOpacity(0.1),
                            const Color(0xFF059669).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: const Color(0xFF10B981),
                              size: isTablet ? 24 : 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _languageService.translate(
                                      'language.currentLanguage',
                                      'Current Language'),
                                  style: TextStyle(
                                    color: const Color(0xFF64748B),
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedLanguage,
                                  style: TextStyle(
                                    color: const Color(0xFF0F172A),
                                    fontSize: isTablet ? 20 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isChangingLanguage)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFF10B981),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Language List
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 3 : 2,
                      childAspectRatio: isTablet ? 3.5 : 3.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final language = filteredLanguages[index];
                        final isSelected = language['name'] == selectedLanguage;
                        final isSupported = LanguageService.supportedLanguages
                            .containsKey(language['name']);

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6366F1)
                                : isSupported
                                    ? Colors.white
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? const Color(0xFF6366F1).withOpacity(0.3)
                                    : Colors.black.withOpacity(0.1),
                                blurRadius: isSelected ? 15 : 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF6366F1)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: InkWell(
                            onTap: isSupported && !_isChangingLanguage
                                ? () => _selectLanguage(language['name']!)
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: EdgeInsets.all(isTablet ? 16 : 12),
                              child: Row(
                                children: [
                                  CircleFlag(
                                    language['flag']!,
                                    size: isTablet ? 32 : 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          language['name']!,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : isSupported
                                                    ? const Color(0xFF0F172A)
                                                    : Colors.grey.shade500,
                                            fontSize: isTablet ? 18 : 16,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                          ),
                                        ),
                                        if (!isSupported)
                                          Text(
                                            'Coming soon',
                                            style: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: isTablet ? 12 : 10,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: isTablet ? 24 : 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: filteredLanguages.length,
                    ),
                  ),
                ),

                // Information about supported languages
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFF6366F1),
                            size: isTablet ? 24 : 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Currently supporting ${LanguageService.supportedLanguages.length} languages with ingredient databases. More languages coming soon!',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
