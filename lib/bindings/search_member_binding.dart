
import 'package:azanto/controllers/search_member_controller.dart';
import 'package:get/get.dart';

class SearchMemberBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchMemberController>(() => SearchMemberController());
  }
}
