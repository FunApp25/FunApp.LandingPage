import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_dropdown.dart';

void main() {
  for (final keyboard in [false, true]) {
    testWidgets(
      'preserves traversal after ${keyboard ? 'keyboard' : 'pointer'} '
      'and repeated selections',
      (tester) async {
        String? value;
        late StateSetter rebuild;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  rebuild = setState;
                  return Column(
                    children: [
                      const TextField(key: Key('before')),
                      _dropdown(
                        value: value,
                        onChanged: (selected) =>
                            rebuild(() => value = selected),
                      ),
                      const TextField(key: Key('after')),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        final state = tester.state(_field);
        for (final label in ['Second', 'First', 'Second']) {
          if (keyboard) {
            await tester.showKeyboard(find.byKey(const Key('before')));
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.pumpAndSettle();
            await tester.sendKeyEvent(LogicalKeyboardKey.enter);
            await tester.pumpAndSettle();
            if (value != label) {
              await tester.sendKeyEvent(
                label == 'Second'
                    ? LogicalKeyboardKey.arrowDown
                    : LogicalKeyboardKey.arrowUp,
              );
              await tester.pumpAndSettle();
            }
            await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          } else {
            await tester.tap(_field);
            await tester.pumpAndSettle();
            await tester.tap(find.text(label).last);
          }
          await tester.pumpAndSettle();
          expect(value, label);
          expect(tester.state(_field), same(state));
          final focus = FocusManager.instance.primaryFocus;
          rebuild(() {});
          await tester.pump();
          expect(FocusManager.instance.primaryFocus, same(focus));
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
          expect(_textFocus(tester, 'after').hasPrimaryFocus, isTrue);
          await _shiftTab(tester);
          await _shiftTab(tester);
          expect(_textFocus(tester, 'before').hasPrimaryFocus, isTrue);
        }
      },
    );
  }

  testWidgets('external values, clears and option changes keep field state', (
    tester,
  ) async {
    Future<void> pump(String? value, List<BrandedFormOption<String>> options) =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _dropdown(value: value, options: options),
            ),
          ),
        );
    await pump('First', _options);
    final state = tester.state<FormFieldState<String>>(_field);
    await tester.tap(_field);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    final focus = FocusManager.instance.primaryFocus;
    for (final value in ['Second', null, 'First']) {
      await pump(value, _options);
      expect(tester.state(_field), same(state));
      expect(state.value, value);
      expect(FocusManager.instance.primaryFocus, same(focus));
    }
    await pump('First', [(value: 'First', label: 'Renamed')]);
    expect(find.text('Renamed'), findsOneWidget);
    await pump('First', [(value: 'Second', label: 'Second')]);
    expect(state.value, isNull);
    expect(find.text('Choose'), findsOneWidget);
    await pump('Second', _options);
    expect(state.value, 'Second');
    await pump('Second', []);
    expect(state.value, isNull);
    expect(
      tester
          .widget<DropdownButton<String>>(
            find.byType(DropdownButton<String>),
          )
          .items,
      isEmpty,
    );
    final barriers = find.byType(ModalBarrier).evaluate().length;
    await tester.tap(_field);
    await tester.pumpAndSettle();
    expect(find.byType(ModalBarrier), findsNWidgets(barriers));
    expect(tester.takeException(), isNull);
  });

  testWidgets('retains form validation and external errors', (tester) async {
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: form,
            child: BrandedFormDropdown<String>(
              fieldKey: const Key('dropdown'),
              label: 'Label',
              semanticLabel: 'Label (required)',
              placeholder: 'Choose',
              value: null,
              options: _options,
              validator: (value) => value == null ? 'Required' : null,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(form.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsOneWidget);
    await tester.tap(_field);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Second').last);
    await tester.pumpAndSettle();
    expect(form.currentState!.validate(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsNothing);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _dropdown(value: 'First', errorText: 'External error'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('External error'), findsOneWidget);
  });
}

const List<BrandedFormOption<String>> _options = [
  (value: 'First', label: 'First'),
  (value: 'Second', label: 'Second'),
];
final Finder _field = find.byKey(const Key('dropdown'));

Widget _dropdown({
  required String? value,
  List<BrandedFormOption<String>> options = _options,
  ValueChanged<String?>? onChanged,
  String? errorText,
}) => BrandedFormDropdown<String>(
  fieldKey: const Key('dropdown'),
  label: 'Label',
  semanticLabel: 'Label',
  placeholder: 'Choose',
  value: value,
  options: options,
  errorText: errorText,
  onChanged: onChanged ?? (_) {},
);

FocusNode _textFocus(WidgetTester tester, String key) => tester
    .widget<EditableText>(
      find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(EditableText),
      ),
    )
    .focusNode;

Future<void> _shiftTab(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.pumpAndSettle();
}
