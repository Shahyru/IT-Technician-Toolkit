import 'package:flutter/material.dart';
import '../storage/local_storage_service.dart';

class FavoriteButton extends StatefulWidget {
  final String itemId;
  final VoidCallback? onChanged;

  const FavoriteButton({
    super.key,
    required this.itemId,
    this.onChanged,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = LocalStorageService().isFavorite(widget.itemId);
  }

  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemId != widget.itemId) {
      _isFavorite = LocalStorageService().isFavorite(widget.itemId);
    }
  }

  Future<void> _toggleFavorite() async {
    final storage = LocalStorageService();
    if (_isFavorite) {
      await storage.removeFavorite(widget.itemId);
    } else {
      await storage.saveFavorite(widget.itemId);
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.star : Icons.star_border,
        color: _isFavorite ? Colors.amber : Theme.of(context).iconTheme.color?.withOpacity(0.6),
        size: 20,
      ),
      tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
      onPressed: _toggleFavorite,
    );
  }
}
