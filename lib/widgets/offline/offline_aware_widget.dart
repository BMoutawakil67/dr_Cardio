import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dr_cardio/services/unified_connectivity_service.dart';
import 'package:dr_cardio/config/app_theme.dart';

/// Widget qui grise automatiquement son contenu quand l'app est hors ligne
class OfflineAwareWidget extends StatefulWidget {
  final Widget child;
  final bool requiresConnection;
  final String? offlineMessage;
  final VoidCallback? onTap;
  final bool showOverlay;

  const OfflineAwareWidget({
    super.key,
    required this.child,
    this.requiresConnection = true,
    this.offlineMessage,
    this.onTap,
    this.showOverlay = true,
  });

  @override
  State<OfflineAwareWidget> createState() => _OfflineAwareWidgetState();
}

class _OfflineAwareWidgetState extends State<OfflineAwareWidget> {
  final UnifiedConnectivityService _connectivityService = UnifiedConnectivityService();
  late bool _isOnline;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _isOnline = _connectivityService.isOnline;
    _subscription = _connectivityService.connectionChange.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _showOfflineSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.offlineMessage ?? 'Cette fonctionnalité nécessite une connexion Internet',
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.warningOrange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.requiresConnection && !_isOnline;

    return GestureDetector(
      onTap: isDisabled
          ? _showOfflineSnackbar
          : widget.onTap,
      child: Stack(
        children: [
          // Contenu principal avec opacité réduite si hors ligne
          Opacity(
            opacity: isDisabled ? 0.4 : 1.0,
            child: IgnorePointer(
              ignoring: isDisabled,
              child: widget.child,
            ),
          ),
          // Overlay avec icône wifi off si grisé
          if (isDisabled && widget.showOverlay)
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.wifi_off,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bouton qui se grise automatiquement hors ligne
class OfflineAwareButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? offlineMessage;
  final ButtonStyle? style;

  const OfflineAwareButton({
    super.key,
    required this.child,
    this.onPressed,
    this.offlineMessage,
    this.style,
  });

  @override
  State<OfflineAwareButton> createState() => _OfflineAwareButtonState();
}

class _OfflineAwareButtonState extends State<OfflineAwareButton> {
  final UnifiedConnectivityService _connectivityService = UnifiedConnectivityService();
  late bool _isOnline;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _isOnline = _connectivityService.isOnline;
    _subscription = _connectivityService.connectionChange.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _showOfflineSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.offlineMessage ?? 'Cette fonctionnalité nécessite une connexion Internet',
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.warningOrange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isOnline ? widget.onPressed : _showOfflineSnackbar,
      style: _isOnline
          ? widget.style
          : ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade400,
              foregroundColor: Colors.grey.shade600,
            ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.child,
          if (!_isOnline) ...[
            const SizedBox(width: 8),
            const Icon(Icons.wifi_off, size: 16),
          ],
        ],
      ),
    );
  }
}

/// ListTile qui se grise automatiquement hors ligne
class OfflineAwareListTile extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? offlineMessage;
  final EdgeInsetsGeometry? contentPadding;

  const OfflineAwareListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.offlineMessage,
    this.contentPadding,
  });

  @override
  State<OfflineAwareListTile> createState() => _OfflineAwareListTileState();
}

class _OfflineAwareListTileState extends State<OfflineAwareListTile> {
  final UnifiedConnectivityService _connectivityService = UnifiedConnectivityService();
  late bool _isOnline;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _isOnline = _connectivityService.isOnline;
    _subscription = _connectivityService.connectionChange.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _showOfflineSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.offlineMessage ?? 'Cette fonctionnalité nécessite une connexion Internet',
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.warningOrange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isOnline ? 1.0 : 0.4,
      child: ListTile(
        leading: widget.leading,
        title: widget.title,
        subtitle: widget.subtitle,
        trailing: _isOnline
            ? widget.trailing
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 16, color: Colors.grey),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 8),
                    widget.trailing!,
                  ],
                ],
              ),
        onTap: _isOnline ? widget.onTap : _showOfflineSnackbar,
        contentPadding: widget.contentPadding,
      ),
    );
  }
}
