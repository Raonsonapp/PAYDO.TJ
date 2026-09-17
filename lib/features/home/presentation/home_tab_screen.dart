import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/home_category.dart';

/// Home tab-и асосӣ. Ин феҳристи виҷетҳои дигар (RootShell)-ро надорад —
/// он худ як "tab body" аст, на Scaffold-и мустақил, то бо
/// BottomNavigationBar-и RootShell дуруст кор кунад.
class HomeTabScreen extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final ValueChanged<String>? onCategoryTap;

  const HomeTabScreen({
    super.key,
    this.onSearchTap,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    const userName = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        centerTitle: false,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userName.isNotEmpty)
                      Text(
                        'Салом, $userName 👋',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.appTagline,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 16),
                    _SearchBar(onTap: onSearchTap),
                    const SizedBox(height: 24),
                    Text(
                      'Категорияҳо',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = HomeCategory.all[index];
                    return _CategoryTile(
                      category: category,
                      onTap: () => onCategoryTap?.call(category.routeKey),
                    );
                  },
                  childCount: HomeCategory.all.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  const _SearchBar({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded,
                color: AppColors.textSecondaryLight),
            const SizedBox(width: 10),
            Text(
              'Ҷустуҷӯи маҳсулот, кор, хизмат...',
              style: TextStyle(color: AppColors.textSecondaryLight.withOpacity(0.9)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final HomeCategory category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(category.icon, color: category.color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            category.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
