import '../../data/model/amenity_model.dart';
import '../../domain/repo/i_amenity_repository.dart';

class GetAmenitiesUseCase {
  final IAmenityRepository repository;

  GetAmenitiesUseCase(this.repository);

  Future<List<AmenityModel>> execute() async {
    return await repository.getAmenities();
  }
}
