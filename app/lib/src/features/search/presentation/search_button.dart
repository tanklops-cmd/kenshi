import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/navigation/app_routes.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('openSearchButton'),
      tooltip: 'Search',
      onPressed: () => context.push(AppRoutes.search),
      icon: const Icon(Icons.search),
    );
  }
}
