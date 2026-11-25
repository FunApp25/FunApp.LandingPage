@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';

import 'searchable_country_dropdown_test.dart' as interactions;

// Run the locale-order, search, selection and narrow keyboard cases in Chrome.
void main() => interactions.main();
