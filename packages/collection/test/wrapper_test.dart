// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Tests wrapper utilities.

import "dart:collection";
import "package:collection/collection.dart";
import "package:test/test.dart";

// Test that any member access/call on the wrapper object is equal to
// an expected access on the wrapped object.
// This is implemented by capturing accesses using noSuchMethod and comparing
// them to expected accesses captured previously.

// Compare two Invocations for having equal type and arguments.
void testInvocations(Invocation i1, Invocation i2) {
  String name = "${i1.memberName}";
  expect(i1.isGetter, equals(i2.isGetter), reason: name);
  expect(i1.isSetter, equals(i2.isSetter), reason: name);
  expect(i1.memberName, equals(i2.memberName), reason: name);
  expect(i1.positionalArguments, equals(i2.positionalArguments), reason: name);
  expect(i1.namedArguments, equals(i2.namedArguments), reason: name);
}

/// Utility class to record a member access and a member access on a wrapped
/// object, and compare them for equality.
///
/// Use as `(expector..someAccess()).equals.someAccess();`.
/// Alle the intercepted member accesses returns `null`.
abstract class Expector {
  wrappedChecker(Invocation i);
  // After calling any member on the Expector, equals is an object that expects
  // the *same* invocation on the wrapped object.
  var equals;

  noSuchMethod(Invocation i) {
    equals = wrappedChecker(i);
    return null;
  }

  toString() {
    // Cannot return an _Equals object since toString must return a String.
    // Just set equals and return a string.
    equals = wrappedChecker(toStringInvocation);
    return "";
  }
}

// Parameterization of noSuchMethod. Calls [_action] on every
// member invocation.
class InvocationChecker {
  Invocation _expected;
  InvocationChecker(this._expected);
  noSuchMethod(Invocation actual) {
    testInvocations(_expected, actual);
    return null;
  }

  toString() {
    testInvocations(_expected, toStringInvocation);
    return "";
  }
  // Could also handle runtimeType, hashCode and == the same way as
  // toString, but we are not testing them since collections generally
  // don't override those and so the wrappers don't forward those.
}

final toStringInvocation = new Invocation.method(#toString, const []);

// InvocationCheckers with types Queue, Set, List or Iterable to allow them as
// argument to DelegatingIterable/Set/List/Queue.
class IterableInvocationChecker<T> extends InvocationChecker
    implements Iterable<T> {
  IterableInvocationChecker(Invocation expected) : super(expected);
}

class ListInvocationChecker<T> extends InvocationChecker implements List<T> {
  ListInvocationChecker(Invocation expected) : super(expected);
}

class SetInvocationChecker<T> extends InvocationChecker implements Set<T> {
  SetInvocationChecker(Invocation expected) : super(expected);
}

class QueueInvocationChecker<T> extends InvocationChecker implements Queue<T> {
  QueueInvocationChecker(Invocation expected) : super(expected);
}

class MapInvocationChecker<K, V> extends InvocationChecker
    implements Map<K, V> {
  MapInvocationChecker(Invocation expected) : super(expected);
}

// Expector that wraps in DelegatingIterable.
class IterableExpector<T> extends Expector implements Iterable<T> {
  wrappedChecker(Invocation i) =>
      new DelegatingIterable<T>(new IterableInvocationChecker<T>(i));
}

// Expector that wraps in DelegatingList.
class ListExpector<T> extends Expector implements List<T> {
  wrappedChecker(Invocation i) =>
      new DelegatingList<T>(new ListInvocationChecker<T>(i));
}

// Expector that wraps in DelegatingSet.
class SetExpector<T> extends Expector implements Set<T> {
  wrappedChecker(Invocation i) =>
      new DelegatingSet<T>(new SetInvocationChecker<T>(i));
}

// Expector that wraps in DelegatingSet.
class QueueExpector<T> extends Expector implements Queue<T> {
  wrappedChecker(Invocation i) =>
      new DelegatingQueue<T>(new QueueInvocationChecker<T>(i));
}

// Expector that wraps in DelegatingMap.
class MapExpector<K, V> extends Expector implements Map<K, V> {
  wrappedChecker(Invocation i) =>
      new DelegatingMap<K, V>(new MapInvocationChecker<K, V>(i));
}

// Utility values to use as arguments in calls.
Null func0() => null;
Null func1(Object x) => null;
Null func2(Object x, Object y) => null;
var val = new Object();

void main() {
  testIterable(var expect) {
    (expect..any(func1)).equals.any(func1);
    (expect..contains(val)).equals.contains(val);
    (expect..elementAt(0)).equals.elementAt(0);
    (expect..every(func1)).equals.every(func1);
    (expect..expand(func1)).equals.expand(func1);
    (expect..first).equals.first;
    // Default values of the Iterable interface will be added in the
    // second call to firstWhere, so we must record them in our
    // expectation (which doesn't have the interface implemented or
    // its default values).
    (expect..firstWhere(func1, orElse: null)).equals.firstWhere(func1);
    (expect..firstWhere(func1, orElse: func0))
        .equals
        .firstWhere(func1, orElse: func0);
    (expect..fold(null, func2)).equals.fold(null, func2);
    (expect..forEach(func1)).equals.forEach(func1);
    (expect..isEmpty).equals.isEmpty;
    (expect..isNotEmpty).equals.isNotEmpty;
    (expect..iterator).equals.iterator;
    (expect..join('')).equals.join();
    (expect..join("X")).equals.join("X");
    (expect..last).equals.last;
    (expect..lastWhere(func1, orElse: null)).equals.lastWhere(func1);
    (expect..lastWhere(func1, orElse: func0))
        .equals
        .lastWhere(func1, orElse: func0);
    (expect..length).equals.length;
    (expect..map(func1)).equals.map(func1);
    (expect..reduce(func2)).equals.reduce(func2);
    (expect..single).equals.single;
    (expect..singleWhere(func1, orElse: null)).equals.singleWhere(func1);
    (expect..skip(5)).equals.skip(5);
    (expect..skipWhile(func1)).equals.skipWhile(func1);
    (expect..take(5)).equals.take(5);
    (expect..takeWhile(func1)).equals.takeWhile(func1);
    (expect..toList(growable: true)).equals.toList();
    (expect..toList(growable: true)).equals.toList(growable: true);
    (expect..toList(growable: false)).equals.toList(growable: false);
    (expect..toSet()).equals.toSet();
    (expect..toString()).equals.toString();
    (expect..where(func1)).equals.where(func1);
  }

  void testList(var expect) {
    testIterable(expect);

    (expect..[4]).equals[4];
    (expect..[4] = 5).equals[4] = 5;

    (expect..add(val)).equals.add(val);
    (expect..addAll([val])).equals.addAll([val]);
    (expect..asMap()).equals.asMap();
    (expect..clear()).equals.clear();
    (expect..fillRange(4, 5, null)).equals.fillRange(4, 5);
    (expect..fillRange(4, 5, val)).equals.fillRange(4, 5, val);
    (expect..getRange(4, 5)).equals.getRange(4, 5);
    (expect..indexOf(val, 0)).equals.indexOf(val);
    (expect..indexOf(val, 4)).equals.indexOf(val, 4);
    (expect..insert(4, val)).equals.insert(4, val);
    (expect..insertAll(4, [val])).equals.insertAll(4, [val]);
    (expect..lastIndexOf(val, null)).equals.lastIndexOf(val);
    (expect..lastIndexOf(val, 4)).equals.lastIndexOf(val, 4);
    (expect..length = 4).equals.length = 4;
    (expect..remove(val)).equals.remove(val);
    (expect..removeAt(4)).equals.removeAt(4);
    (expect..removeLast()).equals.removeLast();
    (expect..removeRange(4, 5)).equals.removeRange(4, 5);
    (expect..removeWhere(func1)).equals.removeWhere(func1);
    (expect..replaceRange(4, 5, [val])).equals.replaceRange(4, 5, [val]);
    (expect..retainWhere(func1)).equals.retainWhere(func1);
    (expect..reversed).equals.reversed;
    (expect..setAll(4, [val])).equals.setAll(4, [val]);
    (expect..setRange(4, 5, [val], 0)).equals.setRange(4, 5, [val]);
    (expect..setRange(4, 5, [val], 3)).equals.setRange(4, 5, [val], 3);
    (expect..sort(null)).equals.sort();
    (expect..sort(func2)).equals.sort(func2);
    (expect..sublist(4, null)).equals.sublist(4);
    (expect..sublist(4, 5)).equals.sublist(4, 5);
  }

  void testSet(var expect) {
    testIterable(expect);
    Set set = new Set();
    (expect..add(val)).equals.add(val);
    (expect..addAll([val])).equals.addAll([val]);
    (expect..clear()).equals.clear();
    (expect..containsAll([val])).equals.containsAll([val]);
    (expect..difference(set)).equals.difference(set);
    (expect..intersection(set)).equals.intersection(set);
    (expect..remove(val)).equals.remove(val);
    (expect..removeAll([val])).equals.removeAll([val]);
    (expect..removeWhere(func1)).equals.removeWhere(func1);
    (expect..retainAll([val])).equals.retainAll([val]);
    (expect..retainWhere(func1)).equals.retainWhere(func1);
    (expect..union(set)).equals.union(set);
  }

  void testQueue(var expect) {
    testIterable(expect);
    (expect..add(val)).equals.add(val);
    (expect..addAll([val])).equals.addAll([val]);
    (expect..addFirst(val)).equals.addFirst(val);
    (expect..addLast(val)).equals.addLast(val);
    (expect..clear()).equals.clear();
    (expect..remove(val)).equals.remove(val);
    (expect..removeFirst()).equals.removeFirst();
    (expect..removeLast()).equals.removeLast();
  }

  void testMap(var expect) {
    Map map = new Map();
    (expect..[val]).equals[val];
    (expect..[val] = val).equals[val] = val;
    (expect..addAll(map)).equals.addAll(map);
    (expect..clear()).equals.clear();
    (expect..containsKey(val)).equals.containsKey(val);
    (expect..containsValue(val)).equals.containsValue(val);
    (expect..forEach(func2)).equals.forEach(func2);
    (expect..isEmpty).equals.isEmpty;
    (expect..isNotEmpty).equals.isNotEmpty;
    (expect..keys).equals.keys;
    (expect..length).equals.length;
    (expect..putIfAbsent(val, func0)).equals.putIfAbsent(val, func0);
    (expect..remove(val)).equals.remove(val);
    (expect..values).equals.values;
    (expect..toString()).equals.toString();
  }

  // Runs tests of Set behavior.
  //
  // [setUpSet] should return a set with two elements: "foo" and "bar".
  void testTwoElementSet(Set<String> setUpSet()) {
    group("with two elements", () {
      Set<String> set;
      setUp(() => set = setUpSet());

      test(".any", () {
        expect(set.any((element) => element == "foo"), isTrue);
        expect(set.any((element) => element == "baz"), isFalse);
      });

      test(".elementAt", () {
        expect(set.elementAt(0), equals("foo"));
        expect(set.elementAt(1), equals("bar"));
        expect(() => set.elementAt(2), throwsRangeError);
      });

      test(".every", () {
        expect(set.every((element) => element == "foo"), isFalse);
        expect(set.every((element) => element is String), isTrue);
      });

      test(".expand", () {
        expect(set.expand((element) {
          return [element.substring(0, 1), element.substring(1)];
        }), equals(["f", "oo", "b", "ar"]));
      });

      test(".first", () {
        expect(set.first, equals("foo"));
      });

      test(".firstWhere", () {
        expect(set.firstWhere((element) => element is String), equals("foo"));
        expect(set.firstWhere((element) => element.startsWith("b")),
            equals("bar"));
        expect(() => set.firstWhere((element) => element is int),
            throwsStateError);
        expect(set.firstWhere((element) => element is int, orElse: () => "baz"),
            equals("baz"));
      });

      test(".fold", () {
        expect(set.fold("start", (previous, element) => previous + element),
            equals("startfoobar"));
      });

      test(".forEach", () {
        var values = [];
        set.forEach(values.add);
        expect(values, equals(["foo", "bar"]));
      });

      test(".iterator", () {
        var values = [];
        for (var element in set) {
          values.add(element);
        }
        expect(values, equals(["foo", "bar"]));
      });

      test(".join", () {
        expect(set.join(", "), equals("foo, bar"));
      });

      test(".last", () {
        expect(set.last, equals("bar"));
      });

      test(".lastWhere", () {
        expect(set.lastWhere((element) => element is String), equals("bar"));
        expect(
            set.lastWhere((element) => element.startsWith("f")), equals("foo"));
        expect(
            () => set.lastWhere((element) => element is int), throwsStateError);
        expect(set.lastWhere((element) => element is int, orElse: () => "baz"),
            equals("baz"));
      });

      test(".map", () {
        expect(
            set.map((element) => element.substring(1)), equals(["oo", "ar"]));
      });

      test(".reduce", () {
        expect(set.reduce((previous, element) => previous + element),
            equals("foobar"));
      });

      test(".singleWhere", () {
        expect(() => set.singleWhere((element) => element == "baz"),
            throwsStateError);
        expect(set.singleWhere((element) => element == "foo"), "foo");
        expect(() => set.singleWhere((element) => element is String),
            throwsStateError);
      });

      test(".skip", () {
        expect(set.skip(0), equals(["foo", "bar"]));
        expect(set.skip(1), equals(["bar"]));
        expect(set.skip(2), equals([]));
      });

      test(".skipWhile", () {
        expect(set.skipWhile((element) => element.startsWith("f")),
            equals(["bar"]));
        expect(set.skipWhile((element) => element.startsWith("z")),
            equals(["foo", "bar"]));
        expect(set.skipWhile((element) => element is String), equals([]));
      });

      test(".take", () {
        expect(set.take(0), equals([]));
        expect(set.take(1), equals(["foo"]));
        expect(set.take(2), equals(["foo", "bar"]));
      });

      test(".takeWhile", () {
        expect(set.takeWhile((element) => element.startsWith("f")),
            equals(["foo"]));
        expect(set.takeWhile((element) => element.startsWith("z")), equals([]));
        expect(set.takeWhile((element) => element is String),
            equals(["foo", "bar"]));
      });

      test(".toList", () {
        expect(set.toList(), equals(["foo", "bar"]));
        expect(() => set.toList(growable: false).add("baz"),
            throwsUnsupportedError);
        expect(set.toList()..add("baz"), equals(["foo", "bar", "baz"]));
      });

      test(".toSet", () {
        expect(set.toSet(), equals(new Set.from(["foo", "bar"])));
      });

      test(".where", () {
        expect(
            set.where((element) => element.startsWith("f")), equals(["foo"]));
        expect(set.where((element) => element.startsWith("z")), equals([]));
        expect(
            set.where((element) => element is String), equals(["foo", "bar"]));
      });

      test(".containsAll", () {
        expect(set.containsAll(["foo", "bar"]), isTrue);
        expect(set.containsAll(["foo"]), isTrue);
        expect(set.containsAll(["foo", "bar", "qux"]), isFalse);
      });

      test(".difference", () {
        expect(set.difference(new Set.from(["foo", "baz"])),
            equals(new Set.from(["bar"])));
      });

      test(".intersection", () {
        expect(set.intersection(new Set.from(["foo", "baz"])),
            equals(new Set.from(["foo"])));
      });

      test(".union", () {
        expect(set.union(new Set.from(["foo", "baz"])),
            equals(new Set.from(["foo", "bar", "baz"])));
      });
    });
  }

  test("Iterable", () {
    testIterable(new IterableExpector());
  });

  test("List", () {
    testList(new ListExpector());
  });

  test("Set", () {
    testSet(new SetExpector());
  });

  test("Queue", () {
    testQueue(new QueueExpector());
  });

  test("Map", () {
    testMap(new MapExpector());
  });

  group("MapKeySet", () {
    Map<String, dynamic> map;
    Set<String> set;

    setUp(() {
      map = new Map<String, int>();
      set = new MapKeySet<String>(map);
    });

    testTwoElementSet(() {
      map["foo"] = 1;
      map["bar"] = 2;
      return set;
    });

    test(".single", () {
      expect(() => set.single, throwsStateError);
      map["foo"] = 1;
      expect(set.single, equals("foo"));
      map["bar"] = 1;
      expect(() => set.single, throwsStateError);
    });

    test(".toString", () {
      expect(set.toString(), equals("{}"));
      map["foo"] = 1;
      map["bar"] = 2;
      expect(set.toString(), equals("{foo, bar}"));
    });

    test(".contains", () {
      expect(set.contains("foo"), isFalse);
      map["foo"] = 1;
      expect(set.contains("foo"), isTrue);
    });

    test(".isEmpty", () {
      expect(set.isEmpty, isTrue);
      map["foo"] = 1;
      expect(set.isEmpty, isFalse);
    });

    test(".isNotEmpty", () {
      expect(set.isNotEmpty, isFalse);
      map["foo"] = 1;
      expect(set.isNotEmpty, isTrue);
    });

    test(".length", () {
      expect(set, hasLength(0));
      map["foo"] = 1;
      expect(set, hasLength(1));
      map["bar"] = 2;
      expect(set, hasLength(2));
    });

    test("is unmodifiable", () {
      expect(() => set.add("baz"), throwsUnsupportedError);
      expect(() => set.addAll(["baz", "bang"]), throwsUnsupportedError);
      expect(() => set.remove("foo"), throwsUnsupportedError);
      expect(() => set.removeAll(["baz", "bang"]), throwsUnsupportedError);
      expect(() => set.retainAll(["foo"]), throwsUnsupportedError);
      expect(() => set.removeWhere((_) => true), throwsUnsupportedError);
      expect(() => set.retainWhere((_) => true), throwsUnsupportedError);
      expect(() => set.clear(), throwsUnsupportedError);
    });
  });

  group("MapValueSet", () {
    Map<String, String> map;
    Set<String> set;

    setUp(() {
      map = new Map<String, String>();
      set = new MapValueSet<String, String>(
          map, (string) => string.substring(0, 1));
    });

    testTwoElementSet(() {
      map["f"] = "foo";
      map["b"] = "bar";
      return set;
    });

    test(".single", () {
      expect(() => set.single, throwsStateError);
      map["f"] = "foo";
      expect(set.single, equals("foo"));
      map["b"] = "bar";
      expect(() => set.single, throwsStateError);
    });

    test(".toString", () {
      expect(set.toString(), equals("{}"));
      map["f"] = "foo";
      map["b"] = "bar";
      expect(set.toString(), equals("{foo, bar}"));
    });

    test(".contains", () {
      expect(set.contains("foo"), isFalse);
      map["f"] = "foo";
      expect(set.contains("foo"), isTrue);
      expect(set.contains("fblthp"), isTrue);
    });

    test(".isEmpty", () {
      expect(set.isEmpty, isTrue);
      map["f"] = "foo";
      expect(set.isEmpty, isFalse);
    });

    test(".isNotEmpty", () {
      expect(set.isNotEmpty, isFalse);
      map["f"] = "foo";
      expect(set.isNotEmpty, isTrue);
    });

    test(".length", () {
      expect(set, hasLength(0));
      map["f"] = "foo";
      expect(set, hasLength(1));
      map["b"] = "bar";
      expect(set, hasLength(2));
    });

    test(".lookup", () {
      map["f"] = "foo";
      expect(set.lookup("fblthp"), equals("foo"));
      expect(set.lookup("bar"), isNull);
    });

    test(".add", () {
      set.add("foo");
      set.add("bar");
      expect(map, equals({"f": "foo", "b": "bar"}));
    });

    test(".addAll", () {
      set.addAll(["foo", "bar"]);
      expect(map, equals({"f": "foo", "b": "bar"}));
    });

    test(".clear", () {
      map["f"] = "foo";
      map["b"] = "bar";
      set.clear();
      expect(map, isEmpty);
    });

    test(".remove", () {
      map["f"] = "foo";
      map["b"] = "bar";
      set.remove("fblthp");
      expect(map, equals({"b": "bar"}));
    });

    test(".removeAll", () {
      map["f"] = "foo";
      map["b"] = "bar";
      map["q"] = "qux";
      set.removeAll(["fblthp", "qux"]);
      expect(map, equals({"b": "bar"}));
    });

    test(".removeWhere", () {
      map["f"] = "foo";
      map["b"] = "bar";
      map["q"] = "qoo";
      set.removeWhere((element) => element.endsWith("o"));
      expect(map, equals({"b": "bar"}));
    });

    test(".retainAll", () {
      map["f"] = "foo";
      map["b"] = "bar";
      map["q"] = "qux";
      set.retainAll(["fblthp", "qux"]);
      expect(map, equals({"f": "foo", "q": "qux"}));
    });

    test(".retainAll respects an unusual notion of equality", () {
      map = new HashMap<String, String>(
          equals: (value1, value2) =>
              value1.toLowerCase() == value2.toLowerCase(),
          hashCode: (value) => value.toLowerCase().hashCode);
      set = new MapValueSet<String, String>(
          map, (string) => string.substring(0, 1));

      map["f"] = "foo";
      map["B"] = "bar";
      map["Q"] = "qux";
      set.retainAll(["fblthp", "qux"]);
      expect(map, equals({"f": "foo", "Q": "qux"}));
    });

    test(".retainWhere", () {
      map["f"] = "foo";
      map["b"] = "bar";
      map["q"] = "qoo";
      set.retainWhere((element) => element.endsWith("o"));
      expect(map, equals({"f": "foo", "q": "qoo"}));
    });
  });
}
