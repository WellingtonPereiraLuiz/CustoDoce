import 'package:custo_doce/data/local/datasources/local_ingredient_datasource.dart';
import 'package:custo_doce/data/local/models/ingredient_model.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:custo_doce/domain/repositories/ingredient_repository.dart';

class IngredientRepositoryImpl implements IngredientRepository {
  final LocalIngredientDataSource _localDataSource;

  IngredientRepositoryImpl(this._localDataSource);

  @override
  Future<List<IngredientEntity>> getAllIngredients() async {
    final models = await _localDataSource.getAllIngredients();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<IngredientEntity?> getIngredientById(String id) async {
    final model = await _localDataSource.getIngredientById(id);
    return model?.toEntity();
  }

  @override
  Future<void> saveIngredient(IngredientEntity ingredient) async {
    final model = IngredientModel.fromEntity(ingredient);
    await _localDataSource.saveIngredient(model);
  }

  @override
  Future<void> updateIngredient(IngredientEntity ingredient) async {
    final model = IngredientModel.fromEntity(ingredient);
    await _localDataSource.updateIngredient(model);
  }

  @override
  Future<void> deleteIngredient(String id) async {
    await _localDataSource.deleteIngredient(id);
  }
}
