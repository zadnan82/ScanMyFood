// lib/List/createlist.dart - Updated version
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scanmyfood/dbHelper/shared_prefs.dart';
import 'package:scanmyfood/services/language_service.dart';

class CreateList extends StatefulWidget {
  const CreateList({Key? key}) : super(key: key);

  @override
  State<CreateList> createState() => _CreateListState();
}

class _CreateListState extends State<CreateList> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final LanguageService _languageService = LanguageService.instance;
  final TextEditingController _ingredientController = TextEditingController();
  List<String> _customIngredients = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCustomList();
  }

  void _initializeAnimations() {
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
    _ingredientController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomList() async {
    setState(() => _isLoading = true);
    try {
      final savedList = await SharedPrefs().getCustomIngredientsList();
      setState(() {
        _customIngredients = savedList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading custom list: $e');
    }
  }

  Future<void> _saveCustomList() async {
    if (_customIngredients.isEmpty) {
      Fluttertoast.showToast(
        msg: _languageService.translate('createList.addAtLeastOne',
            'Add at least one ingredient before saving'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await SharedPrefs().saveCustomIngredientsList(_customIngredients);
      setState(() => _isLoading = false);

      Fluttertoast.showToast(
        msg: _languageService.translate('createList.listSaved',
            'Your custom list has been saved successfully!'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        textColor: Colors.white,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: _languageService.translate('common.error', 'Error occurred'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        textColor: Colors.white,
      );
    }
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isEmpty) return;

    if (_customIngredients.contains(ingredient.toLowerCase())) {
      Fluttertoast.showToast(
        msg: _languageService.translate('createList.ingredientExists',
            'This ingredient is already in your list'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFF59E0B),
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _customIngredients.add(ingredient.toLowerCase());
      _ingredientController.clear();
    });
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _customIngredients.remove(ingredient);
    });
  }

  void _clearList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            _languageService.translate('createList.deleteAll', 'Delete All'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          content: Text(
            _languageService.translate('createList.confirmDelete',
                'Are you sure you want to delete all ingredients from your list?'),
            style: const TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                _languageService.translate('common.cancel', 'Cancel'),
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _customIngredients.clear();
                });
                await SharedPrefs().saveCustomIngredientsList([]);
                Fluttertoast.showToast(
                  msg: _languageService.translate('createList.listDeleted',
                      'Your custom list has been deleted!'),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: const Color(0xFF10B981),
                  textColor: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _languageService.translate('common.delete', 'Delete'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: isTablet ? 180 : 140,
                  floating: false,
                  pinned: true,
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
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: isTablet ? 28 : 24,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _languageService.translate(
                                  'createList.title', 'Create Custom List'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 32 : 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _languageService.translate('createList.subtitle',
                                  'Build your personal ingredient blacklist'),
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

                // Instructions
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
                              _languageService.translate(
                                  'createList.instruction',
                                  'Create your personalized list of unwanted ingredients. Add items one by one, then save your custom blacklist to use during scanning.'),
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Add Ingredient Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _languageService.translate(
                                'createList.addIngredient', 'Add Ingredient'),
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _ingredientController,
                                  style:
                                      TextStyle(fontSize: isTablet ? 16 : 14),
                                  decoration: InputDecoration(
                                    hintText: _languageService.translate(
                                        'createList.enterIngredientName',
                                        'Enter ingredient name (e.g. aspartame, MSG)'),
                                    hintStyle: TextStyle(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: const Color(0xFF94A3B8),
                                      size: isTablet ? 24 : 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF6366F1), width: 2),
                                    ),
                                    contentPadding:
                                        EdgeInsets.all(isTablet ? 16 : 12),
                                  ),
                                  onSubmitted: (_) => _addIngredient(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                height: isTablet ? 56 : 48,
                                width: isTablet ? 56 : 48,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1)
                                          .withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _addIngredient,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: isTablet ? 24 : 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Custom List Section
                if (_customIngredients.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 24 : 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _languageService.translate(
                                          'createList.yourCustomList',
                                          'Your Custom List'),
                                      style: TextStyle(
                                        fontSize: isTablet ? 20 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_customIngredients.length} ${_languageService.translate('createList.items', 'items')}',
                                      style: TextStyle(
                                        fontSize: isTablet ? 14 : 12,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: _clearList,
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: const Color(0xFFEF4444),
                                    size: isTablet ? 20 : 16,
                                  ),
                                  label: Text(
                                    _languageService.translate(
                                        'createList.clearList', 'Clear List'),
                                    style: TextStyle(
                                      color: const Color(0xFFEF4444),
                                      fontSize: isTablet ? 14 : 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _customIngredients.map((ingredient) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: IntrinsicWidth(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isTablet ? 16 : 12,
                                            vertical: isTablet ? 10 : 8,
                                          ),
                                          child: Text(
                                            ingredient,
                                            style: TextStyle(
                                              fontSize: isTablet ? 14 : 12,
                                              color: const Color(0xFF475569),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () =>
                                              _removeIngredient(ingredient),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                isTablet ? 8 : 6),
                                            child: Icon(
                                              Icons.close,
                                              size: isTablet ? 16 : 14,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Save Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                      child: Container(
                        width: double.infinity,
                        height: isTablet ? 60 : 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF10B981),
                              Color(0xFF059669),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveCustomList,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.save,
                                      color: Colors.white,
                                      size: isTablet ? 24 : 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _languageService.translate(
                                          'createList.saveList', 'Save List'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 16 : 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Empty State
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 40 : 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: isTablet ? 80 : 60,
                              height: isTablet ? 80 : 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.add_circle_outline,
                                color: const Color(0xFF94A3B8),
                                size: isTablet ? 40 : 30,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _languageService.translate(
                                  'createList.emptyState',
                                  'No ingredients added yet'),
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _languageService.translate(
                                  'createList.emptyStateDescription',
                                  'Start building your custom ingredient blacklist by adding ingredients above'),
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: const Color(0xFF94A3B8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
