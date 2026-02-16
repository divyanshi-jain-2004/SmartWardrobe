import 'package:get/get.dart';
import '../models/event_model.dart'; // Ensure your Event model is imported

class EventController extends GetxController {
  // .obs makes the list observable, so the UI updates automatically
  var events = <Event>[].obs;

  void addEvent(Event event) {
    events.insert(0, event);
  }
}