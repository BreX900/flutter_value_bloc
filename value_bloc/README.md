# value_bloc

ValueBloc and PagesBloc

## Getting Started

ValueBloc and ListBloc allow you to retrieve data from a repository / database and display it on the screen
Both blocs allow you to pre-load before showing the data on the screen
They also allow you to update data based on a filter and reload data

### ValueBloc
ValueBloc allows you to display a value

```dart
class NameValueBloc extends ValueBloc<String, Object> {
  NameValueBloc() : super(initialLoadStatus: LoadStatus.loading);

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
  // ValueBlocState -> loading...
  // ValueBlocState -> loaded
  // ValueBlocState -> fetching...
  // ValueBlocState -> "Mario"
}
```

### ListBloc
ListBloc allows you to view a set of recoverable values from a sql, 
graph or document database, regardless of the database used it will work



```dart
class NamesListBloc extends ListBloc<String, Object> {
  NamesListBloc() : super(initialFetchStatus: FetchStatus.idle);

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

  print(valueBloc.state); // idle...

  valueBloc.load(); 
  print(await valueBloc.first); // loading ...
  print(await valueBloc.first); // loaded

  valueBloc.fetch(); 
  print(await valueBloc.first); // fetching ...
  print(await valueBloc.first); // fetched: ['Mario', 'Luigi']
}
```