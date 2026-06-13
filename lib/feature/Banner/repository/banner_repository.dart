import 'package:sportbook/feature/Banner/model/banner_model.dart';

abstract class BannerRepository {
  Future<List<BannerModel>> getAllActiveBanner();
}
