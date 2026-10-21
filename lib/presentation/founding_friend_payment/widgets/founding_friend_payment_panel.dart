import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_checkout_bloc.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_payment_status_bloc.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_action_button.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Checkout preparation content shown only after confirmed registration.
final class FoundingFriendCheckoutPanel extends StatelessWidget {
  /// Creates the panel.
  const FoundingFriendCheckoutPanel({
    this.cancelled = false,
    super.key,
  });

  /// Whether the initial presentation explains a cancelled Checkout.
  final bool cancelled;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FoundingFriendCheckoutBloc, FoundingFriendCheckoutState>(
        builder: (context, state) {
          final l10n = context.l10n;
          final (:title, :body, :showRetry, :busy) = switch (state.phase) {
            FoundingFriendCheckoutPhase.idle when cancelled => (
              title: l10n.foundingFriendPaymentCancelledTitle,
              body: l10n.foundingFriendPaymentCancelledBody,
              showRetry: true,
              busy: false,
            ),
            FoundingFriendCheckoutPhase.idle ||
            FoundingFriendCheckoutPhase.preparing => (
              title: l10n.foundingFriendPaymentPreparingTitle,
              body: l10n.foundingFriendPaymentPreparingBody,
              showRetry: false,
              busy: true,
            ),
            FoundingFriendCheckoutPhase.ready ||
            FoundingFriendCheckoutPhase.redirecting => (
              title: l10n.foundingFriendPaymentRedirectingTitle,
              body: l10n.foundingFriendPaymentRedirectingBody,
              showRetry: false,
              busy: true,
            ),
            FoundingFriendCheckoutPhase.failed => (
              title: l10n.foundingFriendPaymentPreparationFailedTitle,
              body: l10n.foundingFriendPaymentPreparationFailedBody,
              showRetry: true,
              busy: false,
            ),
            FoundingFriendCheckoutPhase.recoveryUnavailable => (
              title: l10n.foundingFriendPaymentUnableTitle,
              body: l10n.foundingFriendPaymentRecoveryUnavailableBody,
              showRetry: false,
              busy: false,
            ),
          };

          return _PaymentPanelLayout(
            key: const Key('foundingFriendCheckoutPanel'),
            title: title,
            body: body,
            busy: busy,
            footer: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showRetry)
                  BrandedFormActionButton(
                    buttonKey: const Key('foundingFriendCheckoutRetry'),
                    arrowKey: const Key('foundingFriendCheckoutRetryArrow'),
                    label: l10n.foundingFriendPaymentRetryCheckout,
                    onPressed: () =>
                        context.read<FoundingFriendCheckoutBloc>().add(
                          const FoundingFriendCheckoutRetryRequested(),
                        ),
                  ),
                if (showRetry) const SizedBox(height: 20),
                Text(
                  l10n.foundingFriendPaymentSameEmailReminder,
                  key: const Key('foundingFriendPaymentSameEmailReminder'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyFontStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 24 / 16,
                    color: AppColors.bodyGray,
                  ),
                ),
              ],
            ),
          );
        },
      );
}

/// Read-only return-page payment status content.
final class FoundingFriendPaymentStatusPanel extends StatelessWidget {
  /// Creates the panel.
  const FoundingFriendPaymentStatusPanel({
    required this.sessionId,
    this.onExpiredCheckoutRetry,
    super.key,
  });

  /// Opaque session identifier used for explicit verification retries.
  final String sessionId;

  /// Starts a new payment attempt without resubmitting registration.
  final VoidCallback? onExpiredCheckoutRetry;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<
        FoundingFriendPaymentStatusBloc,
        FoundingFriendPaymentStatusState
      >(
        builder: (context, state) {
          final l10n = context.l10n;
          final (:title, :body, :busy, :retry) = switch (state.phase) {
            FoundingFriendPaymentStatusPhase.initial ||
            FoundingFriendPaymentStatusPhase.verifying => (
              title: l10n.foundingFriendPaymentVerifyingTitle,
              body: l10n.foundingFriendPaymentVerifyingBody,
              busy: true,
              retry: false,
            ),
            FoundingFriendPaymentStatusPhase.confirmed => (
              title: l10n.foundingFriendPaymentConfirmedTitle,
              body: l10n.foundingFriendPaymentConfirmedBody,
              busy: false,
              retry: false,
            ),
            FoundingFriendPaymentStatusPhase.pending => (
              title: l10n.foundingFriendPaymentPendingTitle,
              body: l10n.foundingFriendPaymentPendingBody,
              busy: false,
              retry: true,
            ),
            FoundingFriendPaymentStatusPhase.expired => (
              title: l10n.foundingFriendPaymentExpiredTitle,
              body: l10n.foundingFriendPaymentExpiredBody,
              busy: false,
              retry: false,
            ),
            FoundingFriendPaymentStatusPhase.refunded => (
              title: l10n.foundingFriendPaymentRefundedTitle,
              body: l10n.foundingFriendPaymentRefundedBody,
              busy: false,
              retry: false,
            ),
            FoundingFriendPaymentStatusPhase.disputed => (
              title: l10n.foundingFriendPaymentDisputedTitle,
              body: l10n.foundingFriendPaymentDisputedBody,
              busy: false,
              retry: false,
            ),
            FoundingFriendPaymentStatusPhase.invalid => (
              title: l10n.foundingFriendPaymentInvalidTitle,
              body: l10n.foundingFriendPaymentInvalidBody,
              busy: false,
              retry: false,
            ),
            FoundingFriendPaymentStatusPhase.unableToVerify => (
              title: l10n.foundingFriendPaymentUnableTitle,
              body: l10n.foundingFriendPaymentUnableBody,
              busy: false,
              retry: true,
            ),
          };
          final reference = state.purchaseReference;

          return _PaymentPanelLayout(
            key: const Key('foundingFriendPaymentStatusPanel'),
            title: title,
            body: body,
            busy: busy,
            footer: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (reference != null) ...[
                  Semantics(
                    label:
                        '${l10n.foundingFriendPaymentReferenceLabel}: '
                        '$reference',
                    child: SelectableText(
                      reference,
                      key: const Key('foundingFriendPurchaseReference'),
                      textAlign: TextAlign.center,
                      style: LandingTextStyles.heroCta.copyWith(
                        color: AppColors.blueMain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    key: const Key('foundingFriendCopyPurchaseReference'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: reference));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.foundingFriendPaymentReferenceCopied,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.foundingFriendPaymentCopyReference),
                  ),
                  const SizedBox(height: 20),
                ],
                if (retry)
                  BrandedFormActionButton(
                    buttonKey: const Key('foundingFriendVerificationRetry'),
                    arrowKey: const Key('foundingFriendVerificationRetryArrow'),
                    label: l10n.foundingFriendPaymentRetryVerification,
                    onPressed: () =>
                        context.read<FoundingFriendPaymentStatusBloc>().add(
                          FoundingFriendPaymentVerificationRequested(sessionId),
                        ),
                  ),
                if (state.phase == FoundingFriendPaymentStatusPhase.expired &&
                    onExpiredCheckoutRetry != null)
                  BrandedFormActionButton(
                    buttonKey: const Key(
                      'foundingFriendExpiredCheckoutRetry',
                    ),
                    arrowKey: const Key(
                      'foundingFriendExpiredCheckoutRetryArrow',
                    ),
                    label: l10n.foundingFriendPaymentRetryCheckout,
                    onPressed: onExpiredCheckoutRetry,
                  ),
                if (reference != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    l10n.foundingFriendPaymentSameEmailReminder,
                    key: const Key('foundingFriendPaymentSameEmailReminder'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyFontStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 24 / 16,
                      color: AppColors.bodyGray,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
}

final class _PaymentPanelLayout extends StatefulWidget {
  const _PaymentPanelLayout({
    required this.title,
    required this.body,
    required this.busy,
    required this.footer,
    super.key,
  });

  final String title;
  final String body;
  final bool busy;
  final Widget footer;

  @override
  State<_PaymentPanelLayout> createState() => _PaymentPanelLayoutState();
}

final class _PaymentPanelLayoutState extends State<_PaymentPanelLayout> {
  final _headingFocusNode = FocusNode(
    debugLabel: 'foundingFriendPaymentHeading',
  );

  @override
  void initState() {
    super.initState();
    _focusHeading();
  }

  @override
  void didUpdateWidget(_PaymentPanelLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _focusHeading();
    }
  }

  void _focusHeading() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _headingFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _headingFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, minHeight: 360),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Focus(
              focusNode: _headingFocusNode,
              child: Semantics(
                header: true,
                liveRegion: true,
                focusable: true,
                child: Text(
                  widget.title,
                  key: const Key('foundingFriendPaymentHeading'),
                  textAlign: TextAlign.center,
                  style: LandingTextStyles.heroHeadline.copyWith(
                    fontSize: 42,
                    height: 52 / 42,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.body,
              key: const Key('foundingFriendPaymentBody'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyFontStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 26 / 18,
                color: AppColors.bodyGray,
              ),
            ),
            if (widget.busy) ...[
              const SizedBox(height: 28),
              const Center(
                child: CircularProgressIndicator(
                  key: Key('foundingFriendPaymentProgress'),
                ),
              ),
            ],
            const SizedBox(height: 28),
            widget.footer,
          ],
        ),
      ),
    ),
  );
}
