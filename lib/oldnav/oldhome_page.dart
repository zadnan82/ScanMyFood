 
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'bottom_nav_item.dart';
// import 'tab_navigator.dart';
// import 'package:flutter_circle_flags_svg/flutter_circle_flags_svg.dart';

// class HomePage extends StatefulWidget {
//   HomePage({Key? key}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
// void initState() {
//    getLanguage();
//    super.initState();
// }

//   BottomNavItem selectedItem = BottomNavItem.language;
//  String? language = "";
//   String flag = "";
//    Future getLanguage() async {
//     final prefs = await SharedPreferences.getInstance();
//     language =  prefs.getString('language');

//     if (language == null || language == 'English') {
//       setState(() {
//         flag = 'gb';
//       });
//     } else if (language == 'Swedish') {
//       setState(() {
//         flag = 'se';
//       });
//     } else if (language == 'Spanish') {
//       setState(() {
//         flag = 'es';
//       });
//     } 
//   }
  
//   final Map<BottomNavItem, GlobalKey<NavigatorState>> navigatorKeys = {
//     BottomNavItem.language: GlobalKey<NavigatorState>(),
//     BottomNavItem.food: GlobalKey<NavigatorState>(),
//     BottomNavItem.createlist: GlobalKey<NavigatorState>(),
     
//   };

//   final Map<BottomNavItem, Image> items = const {
//     BottomNavItem.language:  Image(
//               image: AssetImage("assets/images/globe.png"),
//               width: 50,
//               height: 50,
//             ),
//     BottomNavItem.food:  Image(
//               image: AssetImage("assets/images/food.png"),
//               width: 50,
//               height: 50,
//             ),
//      BottomNavItem.createlist:Image(
//               image: AssetImage("assets/images/createlist.png") , width: 50 , height: 50,
//             ), 
//   };

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: WillPopScope(
//         onWillPop: () async {
//           // This is when you want to remove all the pages from the
//           // stack for the specific BottomNav item.
//           navigatorKeys[selectedItem]
//               ?.currentState
//               ?.popUntil((route) => route.isFirst);

//           return false;
//         },
//         child: Stack(
//           children: items
//               .map(
//                 (item, _) => MapEntry(
//                   item,
//                   _buildOffstageNavigator(item, item == selectedItem),
//                 ),
//               )
//               .values
//               .toList(),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.white,
//         selectedItemColor: Theme.of(context).primaryColor,
//         unselectedItemColor: Colors.grey,
//         currentIndex: BottomNavItem.values.indexOf(selectedItem),
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//         onTap: (index) {
//           final currentSelectedItem = BottomNavItem.values[index];
//           if (selectedItem == currentSelectedItem) {
//             navigatorKeys[selectedItem]
//                 ?.currentState
//                 ?.popUntil((route) => route.isFirst);
//           }
//           setState(() {
//             selectedItem = currentSelectedItem;
//           });
//           getLanguage();
//         },
//         items: <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: flag == 'gb'
//                 ? CircleFlag(
//                     flag,
//                     size: 50,
//                   )
//                 : CircleFlag(
//                     flag,
//                     size: 50,
//                   ),
//             label: "Language",
//           ),
//           const BottomNavigationBarItem(
//             icon: Image(
//               image: AssetImage("assets/images/food.png"),
//               width: 50,
//               height: 50,
//             ),
//             label: "Food",
//           ),
        
//           const BottomNavigationBarItem(
//             icon: Image(
//               image: AssetImage("assets/images/createlist.png") , width: 50 , height: 50,
//             ),
//             label: "Create List",
//           ),
//           //  const BottomNavigationBarItem(
//           //   icon: Image(
//           //     image: AssetImage("assets/images/person.png") , width: 50 , height: 50,
//           //   ),
//           //   label: "My List",
//           // ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOffstageNavigator(BottomNavItem currentItem, bool isSelected) {
//     return Offstage(
//       offstage: !isSelected,
//       child: TabNavigator(
//         navigatorKey: navigatorKeys[currentItem]!,
//         item: currentItem,
//       ),
//     );
//   }
// }