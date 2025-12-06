import 'package:get/get.dart';
import '../../data/services/api_client.dart';
import '../../data/services/salon_service.dart';
import '../../data/services/employee_service.dart';
import '../../data/services/service_service.dart';
import '../../data/services/appointment_service.dart';

/// Initial bindings for dependency injection
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // API Client - must be registered first
    Get.put(ApiClient(), permanent: true);

    // Services
    Get.lazyPut(() => SalonService(), fenix: true);
    Get.lazyPut(() => EmployeeService(), fenix: true);
    Get.lazyPut(() => ServiceService(), fenix: true);
    Get.lazyPut(() => AppointmentService(), fenix: true);
  }
}
