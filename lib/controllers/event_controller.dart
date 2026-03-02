import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/event_model.dart';

class EventController extends GetxController {
  var events = <Event>[].obs;
  final storage = GetStorage(); // Create a storage instance

  @override
  void onInit() {
    super.onInit();
    _loadEventsFromStorage(); // Load data the moment the controller is created
  }

  void addEvent(Event event) {
    events.insert(0, event);
    _saveEventsToStorage(); // Save immediately after adding
  }

  void _saveEventsToStorage() {
    // Convert our list of Events to a list of Maps (JSON)
    List<Map<String, dynamic>> dataToSave = events.map((e) => e.toJson()).toList();
    storage.write('my_stored_events', dataToSave);
  }

  void _loadEventsFromStorage() {
    List<dynamic>? storedData = storage.read('my_stored_events');

    if (storedData != null) {
      // Convert the stored Maps back into Event objects
      var loadedEvents = storedData.map((e) => Event.fromJson(e)).toList();
      events.assignAll(loadedEvents);
    }
  }

  // Optional: Add a delete function to clean up storage too
  void deleteEvent(int index) {
    events.removeAt(index);
    _saveEventsToStorage();
  }
}