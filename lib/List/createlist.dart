import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateList extends StatefulWidget {
  const CreateList({Key? key}) : super(key: key);

  @override
  _CreateListState createState() => _CreateListState();
}

class _CreateListState extends State<CreateList> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();

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
    _ingredientsController.dispose();
    super.dispose();
  }

  String instruction = "";
  String ingredientText = "";
  String listSaved = "";
  String nameExist = "";
  String fillAll = "";
  String listDeleted = "";
  final _ingredientsController = TextEditingController();
  List<String> ingredients = [];
  String listToShow = "";

  void _loadSelectedLanguage() async {
    String selectedLanguage = "";
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language') ?? "English";

    setState(() {
      selectedLanguage = language;
    });

    String instructionEn =
        "Create your personalized list of unwanted ingredients. Add items one by one, then save your custom blacklist to use during scanning.";
    String instructionSe =
        "Skapa din personliga lista över oönskade ingredienser. Lägg till objekt en efter en och spara sedan din anpassade svartlista för att använda under skanning.";
    String instructionEs =
        "Crea tu lista personalizada de ingredientes no deseados. Agrega elementos uno por uno, luego guarda tu lista negra personalizada para usar durante el escaneo.";

    String ingredientTextEn = "Enter ingredient name (e.g. aspartame, MSG)";
    String ingredientTextSe = "Ange ingrediensnamn (t.ex. aspartam, MSG)";
    String ingredientTextEs =
        "Ingrese el nombre del ingrediente (ej. aspartamo, MSG)";

    String listSavedEn = "Your custom list has been saved successfully!";
    String listSavedSe = "Din anpassade lista har sparats framgångsrikt!";
    String listSavedEs = "¡Tu lista personalizada se guardó exitosamente!";

    String nameExistEn = "This ingredient is already in your list";
    String nameExistSe = "Denna ingrediens finns redan i din lista";
    String nameExistEs = "Este ingrediente ya está en tu lista";

    String fillAllEn = "Add at least one ingredient before saving";
    String fillAllSe = "Lägg till minst en ingrediens innan du sparar";
    String fillAllEs = "Agrega al menos un ingrediente antes de guardar";

    String listDeletedEn = "Your custom list has been deleted!";
    String listDeletedSe = "Din anpassade lista har raderats!";
    String listDeletedEs = "¡Tu lista personalizada ha sido eliminada!";

    if (selectedLanguage == 'English') {
      instruction = instructionEn;
      ingredientText = ingredientTextEn;
      listSaved = listSavedEn;
      nameExist = nameExistEn;
      fillAll = fillAllEn;
      listDeleted = listDeletedEn;
    } else if (language == 'Swedish') {
      instruction = instructionSe;
      ingredientText = ingredientTextSe;
      listSaved = listSavedSe;
      nameExist = nameExistSe;
      fillAll = fillAllSe;
      listDeleted = listDeletedSe;
    } else if (language == 'Spanish') {
      instruction = instructionEs;
      ingredientText = ingredientTextEs;
      listSaved = listSavedEs;
      nameExist = nameExistEs;
      fillAll = fillAllEs;
      listDeleted = listDeletedEs;
    }
  }

  void addIngredient() {
    final ingredient = _ingredientsController.text.trim();
    if (ingredient.isNotEmpty) {
      final lowerIngredient = ingredient.toLowerCase();

      if (ingredients.contains(lowerIngredient)) {
        Fluttertoast.showToast(
          msg: nameExist,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFFF59E0B),
          textColor: Colors.white,
        );
        return;
      }

      setState(() {
        ingredients.add(lowerIngredient);
        listToShow = ingredients.join(", ");
      });
      _ingredientsController.clear();

      // Add haptic feedback
      // HapticFeedback.lightImpact();
    }
  }

  void removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
      listToShow = ingredients.join(", ");
    });
  }

  checkInputs() {
    if (ingredients.isEmpty) {
      Fluttertoast.showToast(
        msg: fillAll,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        textColor: Colors.white,
      );
      return;
    }
    loadList();
  }

  Future<void> loadList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mylist', ingredients);
    clearInputFields();
  }

  void clearInputFields() {
    _ingredientsController.clear();
    setState(() {
      ingredients = [];
      listToShow = "";
    });
    FocusManager.instance.primaryFocus?.unfocus();
    Fluttertoast.showToast(
      msg: listSaved,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      textColor: Colors.white,
    );
  }

  void clearList() {
    setState(() {
      ingredients = [];
      listToShow = "";
    });
    _ingredientsController.clear();
  }

  void deleteAllLists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mylist');
    clearList();
    FocusManager.instance.primaryFocus?.unfocus();
    Fluttertoast.showToast(
      msg: listDeleted,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      textColor: Colors.white,
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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF6366F1),
                            const Color(0xFF8B5CF6),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 32 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                              size: isTablet ? 36 : 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create Custom List',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 32 : 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Build your personal ingredient blacklist',
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
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: const Color(0xFF6366F1),
                              size: isTablet ? 28 : 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              instruction,
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: const Color(0xFF475569),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Input Section
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Ingredient',
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
                                  controller: _ingredientsController,
                                  style:
                                      TextStyle(fontSize: isTablet ? 16 : 14),
                                  decoration: InputDecoration(
                                    hintText: ingredientText,
                                    hintStyle: TextStyle(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: const Color(0xFF6366F1),
                                      size: isTablet ? 24 : 20,
                                    ),
                                    suffixIcon: _ingredientsController
                                            .text.isNotEmpty
                                        ? IconButton(
                                            onPressed: () {
                                              _ingredientsController.clear();
                                              setState(() {});
                                            },
                                            icon: const Icon(
                                              Icons.clear,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          )
                                        : null,
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF6366F1),
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding:
                                        EdgeInsets.all(isTablet ? 16 : 12),
                                  ),
                                  onSubmitted: (_) => addIngredient(),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: isTablet ? 56 : 48,
                                height: isTablet ? 56 : 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF6366F1),
                                      const Color(0xFF8B5CF6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: addIngredient,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: isTablet ? 28 : 24,
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

                // Current List
                if (ingredients.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 24 : 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.list_alt,
                                  color: const Color(0xFF6366F1),
                                  size: isTablet ? 24 : 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Your Custom List (${ingredients.length} items)',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.3,
                              ),
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      ingredients.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    String ingredient = entry.value;

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6366F1)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFF6366F1)
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            ingredient,
                                            style: TextStyle(
                                              fontSize: isTablet ? 14 : 12,
                                              color: const Color(0xFF6366F1),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () =>
                                                removeIngredient(index),
                                            child: Icon(
                                              Icons.close,
                                              size: isTablet ? 18 : 16,
                                              color: const Color(0xFF6366F1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],

                // Action Buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                    child: Row(
                      children: [
                        if (ingredients.isNotEmpty) ...[
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.clear_all,
                              label: 'Clear List',
                              onPressed: clearList,
                              isTablet: isTablet,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.save,
                            label: 'Save List',
                            onPressed: checkInputs,
                            isTablet: isTablet,
                            isPrimary: true,
                          ),
                        ),
                        if (ingredients.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.delete_forever,
                              label: 'Delete All',
                              onPressed: deleteAllLists,
                              isTablet: isTablet,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isTablet,
    bool isPrimary = false,
    Color? color,
  }) {
    final buttonColor = color ??
        (isPrimary ? const Color(0xFF6366F1) : const Color(0xFF94A3B8));

    return Container(
      height: isTablet ? 56 : 48,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ],
              )
            : null,
        color: isPrimary
            ? null
            : (color?.withOpacity(0.1) ?? buttonColor.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? null
            : Border.all(
                color: buttonColor.withOpacity(0.3),
              ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : buttonColor,
              size: isTablet ? 20 : 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : buttonColor,
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
