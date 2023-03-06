 
// import 'package:flutter/material.dart';
// import 'package:scanmyfood/createlist.dart';
// import 'package:scanmyfood/food.dart';
// import 'package:scanmyfood/language.dart';
// import 'package:scanmyfood/mylist.dart';
// import 'bottom_nav_item.dart';
// import 'custom_router.dart';

// class TabNavigator extends StatelessWidget {
//   static const String tabNavigatorRoot = '/';

//   final GlobalKey<NavigatorState> navigatorKey;
//   final BottomNavItem item;

//   const TabNavigator({Key? key, required this.navigatorKey, required this.item})
//       : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final routeBuilders = _routeBuilder();
//     return Navigator(
//       key: navigatorKey,
//       initialRoute: tabNavigatorRoot,
//       onGenerateInitialRoutes: (_, initialRoute) {
//         return [
//           MaterialPageRoute(
//               settings: const RouteSettings(name: tabNavigatorRoot),
//               builder: (context) => routeBuilders[initialRoute]!(context))
//         ];
//       },
//       onGenerateRoute: CustomRouter.onGenerateNestedRoute,
//     );
//   }

//   Map<String, WidgetBuilder> _routeBuilder() {
//     return {tabNavigatorRoot: (context) => _getScren(context, item)};
//   }

//   _getScren(BuildContext context, BottomNavItem item) {
//     switch (item) {
//       case BottomNavItem.language:
//         return  Language();
//      case BottomNavItem.food:
//   return FoodPage();
//         case BottomNavItem.createlist:
//         return const CreateList();
//       case BottomNavItem.mylist:
//         return const MyList();
//       default:
//         return const Scaffold();
//     }
//   }
// }