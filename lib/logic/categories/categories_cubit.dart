import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/category.dart';
import '../../data/repositories/product_repository.dart';

enum CategoriesStatus { loading, success, failure }

class CategoriesState extends Equatable {
  final CategoriesStatus status;
  final List<Category> categories;
  final String? error;

  const CategoriesState({this.status = CategoriesStatus.loading, this.categories = const [], this.error});

  @override
  List<Object?> get props => [status, categories, error];
}

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._repo) : super(const CategoriesState());

  final ProductRepository _repo;

  Future<void> load() async {
    emit(const CategoriesState());
    try {
      final list = await _repo.getCategories();
      emit(CategoriesState(status: CategoriesStatus.success, categories: list));
    } catch (e) {
      emit(CategoriesState(status: CategoriesStatus.failure, error: e.toString()));
    }
  }
}
