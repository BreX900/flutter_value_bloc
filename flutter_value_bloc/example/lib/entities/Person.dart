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
    required this.name,
    required this.surname,
  });

  @override
  String toString() {
    return 'Person{name: $name, surname: $surname}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          surname == other.surname;

  @override
  int get hashCode => name.hashCode ^ surname.hashCode;
}
