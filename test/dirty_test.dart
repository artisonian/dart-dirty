import 'package:unittest/unittest.dart';
import 'package:dart_dirty/dirty.dart';

import 'dart:io';

test_create() {
  group("new DBs", () {

    setUp(removeFixtures);
    tearDown(removeFixtures);

    test("creates a new DB", () {
      var db = new Dirty('test/test.db');
      expect(
        new File('test/test.db').existsSync(),
        equals(true)
      );
    });

  });
}

test_write() {
  group("writing", () {

    setUp(removeFixtures);
    tearDown(removeFixtures);

    test("can write a record to the DB", () {
      var db = new Dirty('test/test.db');
      db['everything'] =  {'answer': 42};
      db.close(expectAsync0(() {
        expect(
          new File('test/test.db').lengthSync(),
          greaterThan(0)
        );
      }));

    });

  });
}

test_read() {
  group("reading", () {

    setUp(removeFixtures);
    tearDown(removeFixtures);

    test("can read a record from the DB", () {
      var db = new Dirty('test/test.db');
      db['everything'] =  {'answer': 42};
      expect(
        db['everything'],
        equals({'answer': 42})
      );
    });

    test("can read a record from the DB stored on the filesystem", () {
      var db = new Dirty('test/test.db');
      db['everything'] = {'answer': 42};

      db.close(expectAsync0(() {
        var db2 = new Dirty(
          'test/test.db',
          expectAsync1((db3) {
            expect(
              db3['everything'],
              equals({'answer': 42})
            );
          })
        );
      }));

    });

  });
}

test_remove() {
  group("removing", () {

    setUp(removeFixtures);
    tearDown(removeFixtures);

    test("can remove a record from the DB", () {
      var db = new Dirty('test/test.db');

      db['everything'] =  {'answer': 42};
      db.remove('everything');

      expect(
        db['everything'],
        isNull
      );
    });

    test("can remove keys from the DB", () {
      var db = new Dirty('test/test.db');

      db['everything'] =  {'answer': 42};
      db.remove('everything');

      expect(
        db.keys,
        isEmpty
      );
    });


    test("can remove a record from the filesystem store", () {
      expectKeyIsGone() {
        var db = new Dirty('test/test.db');
        expect(
          db['everything'],
          isNull
        );
      }

      removeKey() {
        var db = new Dirty('test/test.db');
        db.remove('everything');
        db.close(expectAsync0(
          expectKeyIsGone
        ));
      }

      addKey() {
        var db = new Dirty('test/test.db');
        db['everything'] = {'answer': 42};
        db.close(expectAsync0(
          removeKey
        ));
      }

      addKey();
    });

  });
}

main() {
  test_create();
  test_write();
  test_read();
  test_remove();
}

removeFixtures() {
  var db = new File('test/test.db');
  if (!db.existsSync()) return;
  db.deleteSync();
}
