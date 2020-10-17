import 'package:flutter/widgets.dart';

final List<Person> personList = List.generate(100, (index) {
  return Person(
    name: 'Name$index',
    surname: 'Surname$index',
  );
});

class Person {
  final String name;
  final String surname;

  const Person({
    @required this.name,
    @required this.surname,
  });
}
