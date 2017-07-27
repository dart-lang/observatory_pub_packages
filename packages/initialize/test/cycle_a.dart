// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library initialize.test.cycle_a;

import 'package:initialize/src/initialize_tracker.dart';
import 'cycle_b.dart' as cycle_b;

/// Uses [cycle_b].
@initializeTracker
class CycleA {}
