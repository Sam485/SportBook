import 'package:sportbook/feature/Banner/model/banner_model.dart';
import 'package:sportbook/feature/Banner/repository/banner_repository.dart';
import 'package:sportbook/feature/Banner/service/banner_service.dart';

class BannerRepositoryImp implements BannerRepository {
  BannerService bannerService;
  BannerRepositoryImp(this.bannerService);
  @override
  Future<List<BannerModel>> getAllActiveBanner() async {
    try {
      return await bannerService.getAllActiveBanner();
    } catch (e) {
      throw Exception('Failed to retrieve data: $e');
    }
  }
}
