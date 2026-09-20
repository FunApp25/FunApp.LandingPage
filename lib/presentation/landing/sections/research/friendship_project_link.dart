import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher.dart';

/// Keyboard-accessible attribution link to the cited project.
final class FriendshipProjectLink extends StatefulWidget {
  /// Creates the inline research link.
  const FriendshipProjectLink({required this.style, this.onOpen, super.key});

  /// Inherited attribution typography.
  final TextStyle style;

  /// Optional launcher override for widget tests.
  final ValueChanged<Uri>? onOpen;

  /// Exact approved public destination.
  static final Uri destination = Uri.parse('https://friendship-project.co.uk/');

  @override
  State<FriendshipProjectLink> createState() => _FriendshipProjectLinkState();
}

final class _FriendshipProjectLinkState extends State<FriendshipProjectLink> {
  var _focused = false;

  void _open() => (widget.onOpen ?? launchExternalLinkInNewTab)(
    FriendshipProjectLink.destination,
  );

  @override
  Widget build(BuildContext context) => Semantics(
    key: const Key('friendshipProjectLink'),
    label: 'The Great Friendship Project',
    link: true,
    onTap: _open,
    child: ExcludeSemantics(
      child: InkWell(
        onTap: _open,
        onFocusChange: (focused) => setState(() => _focused = focused),
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: _focused ? AppColors.energeticPlum : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'The Great Friendship Project',
            style: widget.style.copyWith(
              color: AppColors.energeticPlum,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    ),
  );
}
