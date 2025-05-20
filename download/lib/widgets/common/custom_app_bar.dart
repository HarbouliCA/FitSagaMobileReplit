import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/credit_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showCredits;
  final List<Widget>? actions;
  
  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.showCredits = false,
    this.actions,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      actions: [
        if (showCredits) _buildCreditIndicator(context),
        ...(actions ?? []),
      ],
      elevation: 0,
    );
  }
  
  Widget _buildCreditIndicator(BuildContext context) {
    return Consumer2<CreditProvider, AuthProvider>(
      builder: (context, creditProvider, authProvider, _) {
        if (!authProvider.isAuthenticated || creditProvider.loading) {
          return const SizedBox.shrink();
        }
        
        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: creditProvider.getCreditStatusColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusRound),
            border: Border.all(
              color: creditProvider.getCreditStatusColor(),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars,
                color: creditProvider.getCreditStatusColor(),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                creditProvider.getCreditStatusText(),
                style: TextStyle(
                  color: creditProvider.getCreditStatusColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(AppTheme.appBarHeight);
}

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showCredits;
  final Function(String) onSearch;
  final Function() onClear;
  final String? initialQuery;
  
  const SearchAppBar({
    Key? key,
    required this.title,
    this.showCredits = false,
    required this.onSearch,
    required this.onClear,
    this.initialQuery,
  }) : super(key: key);
  
  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
  
  @override
  Size get preferredSize => const Size.fromHeight(AppTheme.appBarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchField = false;
  
  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _showSearchField = widget.initialQuery != null && widget.initialQuery!.isNotEmpty;
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: _showSearchField
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _showSearchField = false;
                  _searchController.clear();
                  widget.onClear();
                });
              },
            )
          : null,
      title: _showSearchField
          ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for ${widget.title.toLowerCase()}...',
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              autofocus: true,
              onChanged: widget.onSearch,
              onSubmitted: widget.onSearch,
            )
          : Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
      centerTitle: !_showSearchField,
      actions: [
        if (!_showSearchField)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _showSearchField = true;
              });
            },
          ),
        if (_showSearchField && _searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchController.clear();
                widget.onSearch('');
              });
            },
          ),
        if (widget.showCredits && !_showSearchField) _buildCreditIndicator(context),
      ],
      elevation: 0,
    );
  }
  
  Widget _buildCreditIndicator(BuildContext context) {
    return Consumer2<CreditProvider, AuthProvider>(
      builder: (context, creditProvider, authProvider, _) {
        if (!authProvider.isAuthenticated || creditProvider.loading) {
          return const SizedBox.shrink();
        }
        
        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: creditProvider.getCreditStatusColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusRound),
            border: Border.all(
              color: creditProvider.getCreditStatusColor(),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars,
                color: creditProvider.getCreditStatusColor(),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                creditProvider.getCreditStatusText(),
                style: TextStyle(
                  color: creditProvider.getCreditStatusColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}