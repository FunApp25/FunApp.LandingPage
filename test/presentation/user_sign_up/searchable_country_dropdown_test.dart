import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/searchable_country_dropdown.dart';

void main() {
  testWidgets(
    'filters localized labels case-insensitively and returns canonical value',
    (tester) async {
      String? selectedValue;
      await _pumpDropdown(
        tester,
        locale: const Locale('es'),
        onChanged: (value) => selectedValue = value,
      );
      final dropdown = tester.widget<DropdownMenu<String>>(_field);
      expect(dropdown.dropdownMenuEntries, hasLength(254));
      expect(
        dropdown.dropdownMenuEntries
            .singleWhere(
              (entry) => entry.value == 'United Kingdom',
            )
            .label,
        'Reino Unido',
      );

      await tester.tap(_field);
      await tester.pumpAndSettle();
      await tester.enterText(_editableText, 'REINO');
      await tester.pump();

      expect(find.text('Reino Unido').hitTestable(), findsOneWidget);
      expect(find.text('Estados Unidos').hitTestable(), findsNothing);

      await tester.tap(find.text('Reino Unido').hitTestable());
      await tester.pumpAndSettle();

      expect(selectedValue, 'United Kingdom');
      expect(
        tester.widget<EditableText>(_editableText).controller.text,
        'Reino Unido',
      );
    },
  );

  testWidgets('supports focus and keyboard selection', (tester) async {
    String? selectedValue;
    await _pumpDropdown(
      tester,
      onChanged: (value) => selectedValue = value,
    );

    await tester.tap(_field);
    await tester.pumpAndSettle();
    expect(
      tester.widget<EditableText>(_editableText).focusNode.hasFocus,
      isTrue,
    );

    await tester.enterText(_editableText, 'KING');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(
      tester.widget<EditableText>(_editableText).controller.text,
      'United Kingdom',
    );
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();

    expect(selectedValue, 'United Kingdom');
  });

  testWidgets('announces an empty localized result without selecting a value', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    String? selectedValue;
    await _pumpDropdown(
      tester,
      locale: const Locale('be'),
      onChanged: (value) => selectedValue = value,
    );

    expect(
      find.bySemanticsLabel(RegExp('Краіна.*абавязкова')),
      findsOneWidget,
    );
    await tester.tap(_field);
    await tester.pumpAndSettle();
    await tester.enterText(_editableText, 'zzzz');
    await tester.pump();

    expect(find.byKey(const Key('countrySearchNoResults')), findsOneWidget);
    expect(find.text('Краіны не знойдзены'), findsOneWidget);
    expect(selectedValue, isNull);
    semantics.dispose();
  });

  testWidgets('clears a selected canonical value when the search is edited', (
    tester,
  ) async {
    final changes = <String?>[];
    await _pumpDropdown(
      tester,
      value: 'United Kingdom',
      onChanged: changes.add,
    );

    await tester.tap(_field);
    await tester.pumpAndSettle();
    await tester.enterText(_editableText, 'United');
    await tester.pump();

    expect(changes, [null]);
  });

  testWidgets('preserves the available width on mobile and desktop', (
    tester,
  ) async {
    for (final width in const [326.0, 363.0]) {
      await _pumpDropdown(tester, width: width);
      expect(tester.getSize(_field).width, width);
    }
  });
}

const _fieldKey = Key('countryField');
final Finder _field = find.byKey(_fieldKey);
final Finder _editableText = find.descendant(
  of: _field,
  matching: find.byType(EditableText),
);

Future<void> _pumpDropdown(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  double width = 326,
  String? value,
  ValueChanged<String?>? onChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return SearchableCountryDropdown(
                  fieldKey: _fieldKey,
                  label: l10n.userSignUpCountryLabel,
                  semanticLabel: l10n.userSignUpRequiredFieldSemantics(
                    l10n.userSignUpCountryLabel,
                  ),
                  placeholder: l10n.userSignUpCountryPlaceholder,
                  noResultsLabel: l10n.userSignUpCountryNoResults,
                  value: value,
                  options: _countryOptions(
                    l10n.userSignUpCountryOptionsSource,
                  ),
                  onChanged: onChanged ?? (_) {},
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

List<UserSignUpOption> _countryOptions(String source) => [
  for (final entry in source.split('\n'))
    if (entry.split('\t') case [final value, final label])
      (value: value, label: label),
];
