@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/core/config/venue_booking_url.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/development_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/venue_lead_repository.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_checkbox.dart';
import 'package:web/web.dart' as web;

import '../landing/landing_test_helpers.dart';

void main() {
  const malformedDestination = 'https://[v1.foo:bar]:8443/team';

  test('uses the browser URL parser for HTTPS hosts', () {
    expect(() => web.URL(malformedDestination), throwsA(anything));
    expect(parseVenueBookingUrl(malformedDestination), isNull);
    expect(parseVenueBookingUrl('https://[2001:db8::1]:8443/team'), isNotNull);
  });

  testWidgets('booking opens only the configured URL with opener disabled', (
    tester,
  ) async {
    const configured = String.fromEnvironment('FUN_APP_VENUE_BOOKING_URL');
    const unavailable = [
      '',
      'javascript:alert(1)',
      'https://booking.example.test:+443',
      malformedDestination,
    ];

    final opened = <(String, String, String)>[];
    final originalOpen = globalContext['open']! as JSFunction;
    globalContext['open'] =
        ((JSString url, JSString target, JSString features) {
          opened.add((url.toDart, target.toDart, features.toDart));
          if (configured == malformedDestination) {
            originalOpen.callAsFunction(globalContext, url, target, features);
          }
        }).toJS;
    addTearDown(() => globalContext['open'] = originalOpen);
    final bloc = VenueLeadFormBloc(
      const VenueLeadRepository(DevelopmentVenueLeadDataSource()),
    );
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/venues';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
    setTestSurface(tester, const Size(1440, 1800));
    await tester.pumpWidget(
      FunAppLandingPageApp(createVenueLeadFormBloc: () => bloc),
    );
    await tester.pumpAndSettle();

    final draft = find.byKey(const Key('venueLeadVenueNameField'));
    final checkbox = find.byKey(
      const Key('venuePrivacyAcknowledgementCheckbox'),
    );
    final checkboxWidget = find.byType(BrandedFormCheckbox);
    final booking = find.byKey(const Key('venueLeadBookingButton'));
    await tester.enterText(draft, 'Private unsaved draft');
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();
    expect(tester.widget<BrandedFormCheckbox>(checkboxWidget).value, isTrue);
    await tester.ensureVisible(booking);
    await tester.pumpAndSettle();
    await tester.tap(booking);
    await tester.pumpAndSettle();
    const feedback =
        'Call booking is unavailable right now. Please try again later.';
    if (!unavailable.contains(configured)) {
      expect(opened, [(configured, '_blank', 'noopener,noreferrer')]);
      expect(find.text(feedback), findsNothing);
      Focus.of(
        tester.element(find.text('Book a call with the Fun App team')),
      ).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(
        opened,
        List.filled(2, (configured, '_blank', 'noopener,noreferrer')),
      );
      globalContext['open'] =
          ((JSString _, JSString target, JSString features) {
            originalOpen.callAsFunction(
              globalContext,
              malformedDestination.toJS,
              target,
              features,
            );
          }).toJS;
      await tester.tap(booking);
      await tester.pumpAndSettle();
    } else {
      expect(opened, isEmpty);
    }
    expect(tester.takeException(), isNull);
    expect(find.text(feedback), findsOneWidget);
    expect(
      find.semantics
          .byLabel(feedback)
          .evaluate()
          .single
          .getSemanticsData()
          .flagsCollection
          .isLiveRegion,
      isTrue,
    );
    expect(bloc.state.hasAttemptedSubmit, isFalse);
    expect(bloc.state.isSubmitting, isFalse);
    expect(tester.widget<BrandedFormCheckbox>(checkboxWidget).value, isTrue);
    expect(
      tester.widget<TextField>(draft).controller?.text,
      'Private unsaved draft',
    );
  });
}
