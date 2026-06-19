import 'package:sportbook/feature/Banner/model/banner_model.dart';
import 'package:sportbook/feature/Banner/repositories/banner_repository.dart';
import 'package:sportbook/feature/Banner/service/banner_service.dart';

class BannerServiceImp implements BannerService {
  BannerRepository bannerRepository;
  BannerServiceImp(this.bannerRepository);
  @override
  Future<List<BannerModel>> getAllActiveBanner() async {
    try {
      return await bannerRepository.getAllActiveBanner();
    } catch (e) {
      throw Exception('Failed to retrieve data: $e');
    }
  }
}
