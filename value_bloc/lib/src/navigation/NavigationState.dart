part of 'NavigationCubit.dart';

class NavigationCubitState<T> extends Equatable {
  final BuiltList<T> pages;
  final int currentIndexPage;

  T get currentPage => pages[currentIndexPage];

  NavigationCubitState({
    @required this.pages,
    @required this.currentIndexPage,
  })  : assert(pages != null && pages.isNotEmpty),
        assert(currentIndexPage < pages.length);

  NavigationCubitState copyWith({
    BuiltList<T> pages,
    int currentIndexPage,
  }) {
    return NavigationCubitState(
      pages: pages ?? this.pages,
      currentIndexPage: currentIndexPage,
    );
  }

  @override
  List<Object> get props => [pages, currentIndexPage];
}
