# value_bloc

| GitHub | pub.dev |
| --- | --- |
| [value_bloc](https://github.com/BreX900/flutter_value_bloc/tree/master/value_bloc) | [value_bloc](https://pub.dev/packages/value_bloc) |
| [flutter_value_bloc](https://github.com/BreX900/flutter_value_bloc/tree/master/flutter_value_bloc) | [flutter_value_bloc](https://pub.dev/packages/flutter_value_bloc) |



## Getting Started
ValueBloc and ListBloc allow you to retrieve data from a repository / database and display it on the screen
Both blocs allow you to pre-load before showing the data on the screen
They also allow you to update data based on a filter and reload data



### ValueBloc
ValueBloc allows you to display a value
```dart
class NameValueBloc extends SingleValueBloc<String, Object> {
  // Required loading
  NameValueBloc() : super(isLoading: true);

  void onLoading() {
    // write your code for initializing bloc
    emitLoading();
  }

  void onFetching() {
    // write your code for fetching value
    emitFetched('Mario');
  }
}

void main() {
  final valueBloc = NameBloc();

  valueBloc.listen(print);
  // LoadingSingleValueState
  // LoadedSingleValueState
  // FetchingValueState
  // FetchedValueState(value:'Mario')
}
```



### ListBloc
ListBloc allows you to view a set of recoverable values from a sql, 
graph or document database, regardless of the database used it will work

```dart
class NamesListBloc extends ListValueCubit<String, Object> {
  NamesListBloc() : super(isFetching: false);

  void onLoading() {
    // write your code for initializing bloc
    emitLoading();
  }

  void onFetching(int offset, [int limit]) {
    // write your code for fetching value
    emitFetchedCount(offset, limit, ['Mario', 'Luigi'], 2);
  }
}

void main() async {
  final valueBloc = NameBloc();

  print(valueBloc.state); // IdleListValueState

  valueBloc.load(); 
  print(await valueBloc.first); // LoadingListValueState
  print(await valueBloc.first); // LoadedListValueState

  valueBloc.fetch(); 
  print(await valueBloc.first); // FetchingListValueState
  print(await valueBloc.first); // FetchedListValueState(values:['Mario','Luigi'])
}
```