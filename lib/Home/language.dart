import 'package:flutter/material.dart';
import 'package:flutter_circle_flags_svg/flutter_circle_flags_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language extends StatefulWidget {
  const Language({Key? key});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String selectedLanguage = 'English';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();

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

  void _loadCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('language') ?? 'English';
    });
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

  List<Map<String, String>> get filteredLanguages {
    if (searchQuery.isEmpty) return languages;
    return languages
        .where((lang) =>
            lang['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void _selectLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);

    setState(() {
      selectedLanguage = language;
    });

    Fluttertoast.showToast(
      msg: "Language changed to $language",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF10B981), // Emerald green
      textColor: Colors.white,
      fontSize: 16.0,
    );
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
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: isTablet ? 180 : 140,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF6366F1), // Indigo
                            const Color(0xFF8B5CF6), // Purple
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
                              'Choose Language',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 32 : 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select your preferred language',
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
                          hintText: 'Search languages...',
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
                                  'Current Language',
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

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6366F1)
                                : Colors.white,
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
                            onTap: () => _selectLanguage(language['name']!),
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
                                    child: Text(
                                      language['name']!,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                        fontSize: isTablet ? 18 : 16,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                      ),
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
