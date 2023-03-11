import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({Key? key}) : super(key: key);

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  void reloadPage() {
    setState(() {});
  }

  XFile? imageFile;
  int counter = 0;
  bool textScanning = false;
  bool warning = false;
  String message = "";
  String? language = "";
  List<String> words = [];
  String _selectedLanguage = "";
  List<String> foodList = [];
  String dangerousItemsDetected = "";
  String textEn =
      "Here you will use our standard list of dangerous items! Click on the camera icon to scan the ingridents text of the product or on the gallery icon to access your device album. To create your own list click on the pen in the bottom and then the little man icon down there to use your own list of items!";
  String textSe =
      "Här kommer du att använda vår standardlista över farliga föremål! Klicka på kameraikonen för att skanna produktens innehållstext eller på galleriikonen för att komma åt ditt enhetsalbum. För att skapa din egen lista klicka på pennan i botten och sedan den lilla man-ikonen där nere för att använda din egen lista med föremål!";
  String textEs =
      "¡Aquí usará nuestra lista estándar de elementos peligrosos! Haga clic en el ícono de la cámara para escanear el texto de los componentes del producto o en el ícono de la galería para acceder al álbum de su dispositivo. Para crear su propia lista, haga clic en el bolígrafo en la parte inferior y luego ¡el ícono del hombrecito ahí abajo para usar tu propia lista de elementos!";
  String warning1 = "";
  String warning2 = "";
  String ourList = "";

  List<String> chemicalsFoodEn = [
    "1,3-dichloro-2-propanol",
    "1,4-dioxane",
    "2,3,7,8-tetracholordibenzo-p-dioxin",
    "2-amino-1-methyl-6-phenylimidazo[4,5-b]pyridine",
    "2-amino-3,4-dimethylimidazo[4,5-f]quinolone (meIq)",
    "2-amino-3,8-dimethylimidazo[4,5-f]quinoxalone (meIqx)",
    "2-methylimidazole",
    "3-chloro-1,2-propanediol",
    "4-methylimidazole",
    "5-methoxypsoralen",
    "acesulfame potassium",
    "acetaldehyde",
    "acrylamide",
    "acrylonitrile",
    "aflatoxins",
    "agaritine d",
    "agave nectar",
    "alkaloids",
    "alkenylbenzene",
    "alkylated imidazoles",
    "aluminum",
    "amino-3-methylimidazo[4,5-f]quinoline",
    "annatto",
    "aristolochic acid",
    "arsenic",
    "aspartame",
    "aspergillus flavus",
    "azodicarbonamide",
    "benz[a]anthracene",
    "benzene",
    "benzo[a]pyrene",
    "benzo[b}fluoranthene",
    "benzophenone",
    "bha",
    "bht",
    "bisphenol a",
    "bisphenol a",
    "bisphenols",
    "bixin",
    "bleached starch",
    "blue #1",
    "blue #2",
    "blue 1",
    "blue 2",
    "bpa",
    "bracken fern",
    "brominated vegetable oil",
    "brominated vegetable oil",
    "brown ht",
    "butane",
    "butylated hydroxyanisole",
    "butylated hydroxytoluene",
    "bvo",
    "cadmium",
    "camauba wax",
    "canola oil",
    "caramel coloring",
    "carrageenan (native) d",
    "carrageenan",
    "chlorate (sodium salt) d",
    "chloride",
    "chlorine dioxide",
    "chloropropanols",
    "citrus red #1",
    "citrus red #2",
    "corn oil",
    "coumarin",
    "crotonaldehyde",
    "cycasin",
    "daminozide",
    "dbp",
    "ddt",
    "dep",
    "di(2-ethylhexyl) phthalate",
    "dibutylphthalate",
    "dichlorodiphenyltrichloroethane",
    "diethylphthalate",
    "dioxins",
    "disodium guanylate",
    "disodium inosinate",
    "d-limonene",
    "enriched flour",
    "equal",
    "estragole",
    "ethyl carbamate",
    "ethylene oxide",
    "eugenol d",
    "flumequine",
    "fumonisin b1",
    "fumonisins",
    "fumonsin b1",
    "furan",
    "furfural d",
    "fusarin c",
    "fusarium moniliforme",
    "genistein d",
    "green #3",
    "green 3",
    "hepatocellular carcinoma",
    "heterocyclic",
    "hexenal",
    "hfcs",
    "high fructose corn syrup",
    "hydroquinone",
    "iarc",
    "Isatidine d",
    "lasiocarpine",
    "lead",
    "magnesium sulphate",
    "malondialdehyde",
    "maté",
    "meIq",
    "meIqx",
    "mercury",
    "methoxsalen",
    "methyl eugenol",
    "methyl isobutyl ketone",
    "methylazoxymethanol",
    "methylene",
    "monocrotaline",
    "monosodium glutamate",
    "nitrosamides",
    "nitrosamines",
    "n-methyl-n-formylhydrazine d",
    "n-nitroso",
    "n-nitrosodiethanolamine",
    "n-nitrosodimethylamine",
    "norbixin",
    "nutraSweet",
    "ochratoxin",
    "olestra",
    "orange b",
    "p,p0dichlorodiphenyltrichloroethane",
    "pahs",
    "palm oil",
    "paraben",
    "patulin",
    "pbcs",
    "perchlorate",
    "perfluoroalkyl",
    "pfas",
    "phIp",
    "phthalates",
    "plastics",
    "polyamides",
    "polycyclic aromatic hydrocarbons",
    "polyesters",
    "polyfluoroalkyl",
    "polymeric",
    "polyolefins",
    "polysorbate 60",
    "polystyrene",
    "potassium benzoate",
    "potassium bromate",
    "propyl gallate",
    "propyl paraben",
    "propylene glycol",
    "psoralen",
    "ptaquiloside",
    "pulegone",
    "pyrrolizidine",
    "quercetin",
    "rbgh",
    "recombinant bovine growth hormone",
    "red #2",
    "red #3",
    "red #40",
    "red 2",
    "red 3",
    "red 40",
    "retrorsine d",
    "riddelliine",
    "saccharin",
    "safrole",
    "senkirkine d",
    "sodium benzoate",
    "sodium carboxymethyl cellulose",
    "sodium nitrates",
    "sodium nitrites",
    "sodium saccharin d",
    "soybean oil",
    "splenda",
    "styrene",
    "sucralose",
    "sugartwin",
    "sweet'n low",
    "symphytine d",
    "tbhq",
    "tcdd",
    "tert-butylhydroquinone",
    "titanium dioxide",
    "trans,trans-2,4-hexadienal",
    "trichloroethylene",
    "urethane",
    "vinyl chloride",
    "yellow #5",
    "yellow #6",
    "yellow 5",
    "yellow 6",
    "zearalenone d",
    "α,β-aldehydes",
    "β-myrcene"
  ];

  List<String> chemicalsFoodSe = [
    "1,3-diklor-2-propanol",
    "1,4-dioxan",
    "2,3,7,8-tetraklordibenso-p-dioxin",
    "2-amino-1-metyl-6-fenylimidazo[4,5-b]pyridin",
    "2-amino-3,4-dimetylimidazo[4,5-f]kinolon (meIq)",
    "2-amino-3,8-dimetylimidazo[4,5-f]kinoxalon (meIqx)",
    "2-metylimidazol",
    "3-klor-1,2-propandiol",
    "4-metylimidazol",
    "5-metoxipsoralen",
    "acesulfam kalium",
    "acetaldehyd",
    "akrylamid",
    "akrylnitril",
    "aflatoxiner",
    "agaritin d",
    "Agave nektar",
    "alkaloider",
    "alkenylbensen",
    "alkylerade imidazoler",
    "aluminium",
    "amino-3-metylimidazo[4,5-f]kinolin",
    "annatto",
    "aristolochic acid",
    "arsenik",
    "aspartam",
    "aspergillus flavus",
    "azodikarbonamid",
    "bens[a]antracen",
    "bensen",
    "benso[a]pyren",
    "benso[b}fluoranten",
    "bensofenon",
    "bha",
    "bht",
    "bisfenol a",
    "bisfenol a",
    "bisfenoler",
    "bixin",
    "blekt stärkelse",
    "blå #1",
    "blå #2",
    "blå 1",
    "blå 2",
    "bpa",
    "bracken fern",
    "bromerad vegetabilisk olja",
    "bromerad vegetabilisk olja",
    "brun ht",
    "butan",
    "butylerad hydroxyanisol",
    "butylerad hydroxitoluen",
    "bvo",
    "kadmium",
    "camaubavax",
    "canolaolja",
    "karamellfärg",
    "karragenan (infödd) d",
    "karragenan",
    "klorat (natriumsalt) d",
    "klorid",
    "klordioxid",
    "klorpropanoler",
    "citrusröd #1",
    "citrusröd #2",
    "majsolja",
    "kumarin",
    "krotonaldehyd",
    "cycasin",
    "daminozid",
    "dbp",
    "ddt",
    "dep",
    "di(2-etylhexyl)ftalat",
    "dibutylftalat",
    "diklordifenyltrikloretan",
    "dietylftalat",
    "dioxiner",
    "dinatriumguanylat",
    "dinatriuminosinat",
    "d-limonen",
    "berikat mjöl",
    "likvärdig",
    "estragol",
    "etylkarbamat",
    "etylenoxid",
    "eugenol d",
    "flumequine",
    "fumonisin b1",
    "fumonisiner",
    "fumonsin b1",
    "furan",
    "furfural d",
    "fusarin c",
    "fusarium moniliforme",
    "genistein d",
    "grön #3",
    "grön 3",
    "hepatocellulärt karcinom",
    "heterocyklisk",
    "hexenal",
    "hfcs",
    "hög fruktos majssirap",
    "hydrokinon",
    "iarc",
    "Isatidin d",
    "lasiokarpin",
    "leda",
    "magnesiumsulfat",
    "malondialdehyd",
    "para",
    "meIq",
    "meIqx",
    "kvicksilver",
    "metoxsalen",
    "metyl eugenol",
    "metylisobutylketon",
    "metylazoximetanol",
    "metylen",
    "monokrotalin",
    "mononatriumglutamat",
    "nitrosamider",
    "nitrosaminer",
    "n-metyl-n-formylhydrazin d",
    "n-nitroso",
    "n-nitrosodietanolamin",
    "n-nitrosodimetylamin",
    "norbixin",
    "nutraSweet",
    "okratoxin",
    "olestra",
    "orange b",
    "p,p0diklordifenyltrikloretan",
    "pahs",
    "palmolja",
    "paraben",
    "patulin",
    "pbcs",
    "perklorat",
    "perfluoralkyl",
    "pfas",
    "phIp",
    "ftalater",
    "plast",
    "polyamider",
    "polycykliska aromatiska kolväten",
    "polyestrar",
    "polyfluoralkyl",
    "polymer",
    "polyolefiner",
    "polysorbat 60",
    "polystyren",
    "kaliumbensoat",
    "kaliumbromat",
    "propylgallat",
    "propylparaben",
    "propylenglykol",
    "psoralen",
    "ptaquilosid",
    "pulegone",
    "pyrrolizidin",
    "quercetin",
    "rbgh",
    "rekombinant bovint tillväxthormon",
    "röd 2",
    "röd #3",
    "röd #40",
    "röd 2",
    "röd 3",
    "röd 40",
    "retrorsine d",
    "riddelliine",
    "sackarin",
    "safrole",
    "senkirkine d",
    "natriumbensoat",
    "natriumkarboximetylcellulosa",
    "natriumnitrat",
    "natriumnitrit",
    "natriumsackarin d",
    "sojabönsolja",
    "splenda",
    "styren",
    "sukralos",
    "sugartwin",
    "sweet'n low",
    "symfytin d",
    "tbhq",
    "tcdd",
    "tert-butylhydrokinon",
    "titandioxid",
    "trans,trans-2,4-hexadienal",
    "trikloretylen",
    "uretan",
    "vinylklorid",
    "gul #5",
    "gul #6",
    "gul 5",
    "gul 6",
    "zearalenone d",
    "α,β-aldehyder",
    "β-myrcene"
  ];

  List<String> chemicalsFoodEs = [
    "1,3-dicloro-2-propanol",
    "1,4-dioxano",
    "2,3,7,8-tetracholordibenzo-p-dioxina",
    "2-amino-1-metil-6-fenilimidazo[4,5-b]piridina",
    "2-amino-3,4-dimetilimidazo[4,5-f]quinolona (meIq)",
    "2-amino-3,8-dimetilimidazo[4,5-f]quinoxalona (meIqx)",
    "2-metilimidazol",
    "3-cloro-1,2-propanodiol",
    "4-metilimidazol",
    "5-metoxipsoraleno",
    "acesulfamo de potasio",
    "acetaldehído",
    "acrilamida",
    "acrilonitrilo",
    "aflatoxinas",
    "agaritina d",
    "néctar de agave",
    "alcaloides",
    "alquenilbenceno",
    "imidazoles alquilados",
    "aluminio",
    "amino-3-metilimidazo[4,5-f]quinolina",
    "anato",
    "ácido aristolóquico",
    "arsénico",
    "aspartamo",
    "aspergillus flavus",
    "azodicarbonamida",
    "benz[a]antraceno",
    "benceno",
    "benzo[a]pireno",
    "benzo[b}fluoranteno",
    "benzofenona",
    "bha",
    "bht",
    "El bisfenol A",
    "El bisfenol A",
    "bisfenoles",
    "bixina",
    "almidón blanqueado",
    "azul #1",
    "azul #2",
    "azul 1",
    "azul 2",
    "bpa",
    "helecho helecho",
    "aceite vegetal bromado",
    "aceite vegetal bromado",
    "marrón ht",
    "butano",
    "hidroxianisol butilado",
    "hidroxitolueno butilado",
    "bvo",
    "cadmio",
    "cera de camauba",
    "aceite de canola",
    "colorante caramelo",
    "carragenina (nativa) d",
    "carragenina",
    "clorato (sal de sodio) d",
    "cloruro",
    "Dioxido de cloro",
    "cloropropanoles",
    "rojo cítrico #1",
    "rojo cítrico #2",
    "aceite de maíz",
    "cumarina",
    "crotonaldehído",
    "cicasina",
    "daminozida",
    "dbp",
    "ddt",
    "profundidad",
    "ftalato de di (2-etilhexilo)",
    "Ftalato de dibutilo",
    "diclorodifeniltricloroetano",
    "dietilftalato",
    "dioxinas",
    "guanilato de disodio",
    "inosinato disódico",
    "d-limoneno",
    "harina enriquecida",
    "igual",
    "estragol",
    "carbamato de etilo",
    "óxido de etileno",
    "eugenol d",
    "flumequina",
    "fumonisina b1",
    "fumonisinas",
    "fumonsina b1",
    "furano",
    "furfural d",
    "fusarina c",
    "fusarium moniliforme",
    "genisteína d",
    "verde #3",
    "verde 3",
    "carcinoma hepatocelular",
    "heterocíclico",
    "hexenal",
    "hfcs",
    "jarabe de maíz con alta fructuosa",
    "hidroquinona",
    "iarc",
    "Isatidina d",
    "lasiocarpina",
    "dirigir",
    "sulfato de magnesio",
    "malondialdehído",
    "compañero",
    "meIq",
    "meIqx",
    "mercurio",
    "metoxsaleno",
    "metil eugenol",
    "metilisobutilcetona",
    "metilazoximetanol",
    "metileno",
    "monocrotalina",
    "glutamato monosódico",
    "nitrosamidas",
    "nitrosaminas",
    "n-metil-n-formilhidrazina d",
    "n-nitroso",
    "n-nitrosodietanolamina",
    "n-nitrosodimetilamina",
    "norbixina",
    "nutradulce",
    "ocratoxina",
    "olestra",
    "naranja b",
    "p,p0diclorodifeniltricloroetano",
    "pahs",
    "aceite de palma",
    "parabeno",
    "patulina",
    "pbcs",
    "perclorato",
    "perfluoroalquilo",
    "pfas",
    "phip",
    "ftalatos",
    "plástica",
    "poliamidas",
    "hidrocarburos aromáticos policíclicos",
    "poliésteres",
    "polifluoroalquilo",
    "polimérico",
    "poliolefinas",
    "polisorbato 60",
    "poliestireno",
    "benzoato de potasio",
    "bromato de potasio",
    "galato de propilo",
    "propilparabeno",
    "propilenglicol",
    "psoraleno",
    "ptaquilosida",
    "pulegona",
    "pirrolizidina",
    "quercetina",
    "rbgh",
    "hormona de crecimiento bovina recombinante",
    "rojo 2",
    "rojo #3",
    "rojo #40",
    "rojo 2",
    "rojo 3",
    "rojo 40",
    "retroseno d",
    "riddelliine",
    "sacarina",
    "safrol",
    "senkirkine d",
    "benzonato de sodio",
    "carboximetilcelulosa de sodio",
    "nitratos de sodio",
    "nitritos de sodio",
    "sacarina de sodio d",
    "aceite de soja",
    "esplenda",
    "estireno",
    "sucralosa",
    "gemelo de azúcar",
    "dulce n bajo",
    "sinfitina d",
    "tbhq",
    "tcdd",
    "terc-butilhidroquinona",
    "dióxido de titanio",
    "trans,trans-2,4-hexadienal",
    "tricloroetileno",
    "uretano",
    "cloruro de vinilo",
    "amarillo #5",
    "amarillo #6",
    "amarillo 5",
    "amarillo 6",
    "zearalenona d",
    "aldehídos α, β",
    "β-mirceno"
  ];

  void _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language');
    if (language != null) {
      setState(() {
        _selectedLanguage = language;
      });
    }

    String warning1En = "Items found: ";
    String warning1Se = "Hittade ämnen:";
    String warning1Es = "Artículos encontrados: ";
    String ourListEn = "Our List";
    String ourListSe = "Vår Lista";
    String ourListEs = "Nuestra Lista";

    if (language == null || language == 'English') {
      foodList = chemicalsFoodEn;
      warning1 = warning1En;
      ourList = ourListEn;
    } else if (language == 'Swedish') {
      foodList = chemicalsFoodSe;
      warning1 = warning1Se;
      ourList = ourListSe;
    } else if (language == 'Spanish') {
      foodList = chemicalsFoodEs;
      warning1 = warning1Es;
      ourList = ourListEs;
    }
  }

  void getRecognisedText(XFile image) async {
    words = [];
    dangerousItemsDetected = "";
    counter = 0;
    textScanning = false;
    message = "";
    warning = false;

    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();

    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        String lineText = line.text;
        List<String> words = lineText.split(',');

        for (String word in words) {
          String processedWord = word.toLowerCase().trim();

          processedWord = processedWord.replaceAll(RegExp(r'\(\d+\%?\)'), '');

          if (foodList.contains(processedWord)) {
            warning = true;
            counter++;
            dangerousItemsDetected =
               // " * " + dangerousItemsDetected + processedWord + "\n";
                 " * $dangerousItemsDetected$processedWord\n";
          }
        }
      }
    }

    textScanning = false;
    setState(() {});
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      message = "Error occured while scanning";
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors
                          .lightGreen, //background color of dropdown button
                      border: Border.all(
                          color: Colors.black38,
                          width: 3), //border of dropdown button
                      borderRadius: BorderRadius.circular(
                          50), //border raiuds of dropdown button
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)
                      ]),
                  child: PhysicalModel(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(20),
                    shadowColor: Colors.black,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: DropdownButton<String>(
                        hint: Text(ourList),
                        onChanged: (String? value) {
                          setState(() {});
                        },
                        items: foodList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 50, right: 45),
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromARGB(255, 41, 41, 41),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        isExpanded: true,
                        underline: Container(),
                        icon: const Padding(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Icon(Icons.arrow_drop_down)),
                        iconEnabledColor: Colors.black, //Icon color
                        iconSize: 30,
                      ),
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 20)),
                if (textScanning) const CircularProgressIndicator(),
                if (!textScanning && imageFile == null)
                  _selectedLanguage == 'English'
                      ? Text(textEn)
                      : _selectedLanguage == 'Swedish'
                          ? Text(textSe)
                          : _selectedLanguage == 'Spanish'
                              ? Text(textEs)
                              : Text(textEn),
                if (imageFile != null)
                  Image.file(File(imageFile!.path),
                      height: 200, fit: BoxFit.fill),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.only(top: 10),
                      child: IconButton(
                        icon: Image.asset('assets/images/gallery.png'),
                        iconSize: 50,
                        onPressed: () {
                          getImage(ImageSource.gallery);
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.only(top: 10),
                      child: IconButton(
                        icon: Image.asset('assets/images/camera.png'),
                        iconSize: 50,
                        onPressed: () {
                          getImage(ImageSource.camera);
                        },
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    warning
                        ? Text(
                            "$warning1 ",
                            style: const TextStyle(fontSize: 20),
                          )
                        : const Text(""),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      dangerousItemsDetected,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )
              ],
            )),
      )),
    );
  }
}
