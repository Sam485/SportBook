import 'package:sportbook/feature/Banner/model/banner_model.dart';

abstract class BannerService {
  Future<List<BannerModel>> getAllActiveBanner();
}
