import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

part 'NavigationState.dart';

class NavigationCubit<T> extends Cubit<NavigationCubitState<T?>> {
  NavigationCubit({
    required Iterable<T> pages,
    T? initialPage,
  }) : super(NavigationCubitState(
          pages: pages.toBuiltList(),
          currentIndexPage: initialPage != null ? pages.toList().indexOf(initialPage) : 0,
        ));

  static NavigationCubit<int> from({required int pagesCount, int? initialPage}) {
    return NavigationCubit(
      pages: List.generate(pagesCount, (index) => index),
      initialPage: initialPage,
    );
  }

  void goToPage(T page) {
    emit(state.copyWith(currentIndexPage: state.pages.indexOf(page)));
  }

  void goToIndexPage(int indexPage) {
    emit(state.copyWith(currentIndexPage: indexPage));
  }

  void updatePages(Iterable<T> pages, [T? page]) {
    final newPages = pages.toBuiltList();
    emit(state.copyWith(
      pages: newPages,
      currentIndexPage: page != null ? newPages.indexOf(page) : 0,
    ));
  }
}
