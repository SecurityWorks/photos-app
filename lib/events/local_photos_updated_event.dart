import 'package:photos/events/files_updated_event.dart';

class LocalPhotosUpdatedEvent extends FilesUpdatedEvent {
  LocalPhotosUpdatedEvent(updatedFiles, {type, source})
      : super(
          updatedFiles,
          type: type ?? EventType.addedOrUpdated,
          source: source ?? "",
        );
}
