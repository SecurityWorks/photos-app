import "package:flutter/cupertino.dart";
import 'package:logging/logging.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/data/holidays.dart';
import 'package:photos/data/months.dart';
import 'package:photos/data/years.dart';
import 'package:photos/db/files_db.dart';
import 'package:photos/events/local_photos_updated_event.dart';
import 'package:photos/models/collection/collection.dart';
import 'package:photos/models/collection/collection_items.dart';
import 'package:photos/models/file/file.dart';
import 'package:photos/models/file/file_type.dart';
import "package:photos/models/local_entity_data.dart";
import "package:photos/models/location_tag/location_tag.dart";
import 'package:photos/models/search/album_search_result.dart';
import 'package:photos/models/search/generic_search_result.dart';
import 'package:photos/models/search/search_result.dart';
import 'package:photos/services/collections_service.dart';
import "package:photos/services/face_ml/face_search_service.dart";
import "package:photos/services/location_service.dart";
import "package:photos/states/location_screen_state.dart";
import "package:photos/ui/viewer/location/location_screen.dart";
import 'package:photos/utils/date_time_util.dart';
import "package:photos/utils/navigation_util.dart";
import 'package:tuple/tuple.dart';

class SearchService {
  Future<List<EnteFile>>? _cachedFilesFuture;
  final _logger = Logger((SearchService).toString());
  final _collectionService = CollectionsService.instance;
  static const _maximumResultsLimit = 20;

  SearchService._privateConstructor();

  static final SearchService instance = SearchService._privateConstructor();

  void init() {
    Bus.instance.on<LocalPhotosUpdatedEvent>().listen((event) {
      // only invalidate, let the load happen on demand
      _cachedFilesFuture = null;
    });
  }

  Set<int> ignoreCollections() {
    return CollectionsService.instance.getHiddenCollectionIds();
  }

  Future<List<EnteFile>> getAllFiles() async {
    if (_cachedFilesFuture != null) {
      return _cachedFilesFuture!;
    }
    _logger.fine("Reading all files from db");
    _cachedFilesFuture =
        FilesDB.instance.getAllFilesFromDB(ignoreCollections());
    return _cachedFilesFuture!;
  }

  void clearCache() {
    _cachedFilesFuture = null;
  }

  // getFilteredCollectionsWithThumbnail removes deleted or archived or
  // collections which don't have a file from search result
  Future<List<AlbumSearchResult>> getCollectionSearchResults(
    String query,
  ) async {
    final List<Collection> collections = _collectionService.getCollectionsForUI(
      includedShared: true,
    );

    final List<AlbumSearchResult> collectionSearchResults = [];

    for (var c in collections) {
      if (collectionSearchResults.length >= _maximumResultsLimit) {
        break;
      }

      if (!c.isHidden() &&
          c.type != CollectionType.uncategorized &&
          c.displayName.toLowerCase().contains(
                query.toLowerCase(),
              )) {
        final EnteFile? thumbnail = await _collectionService.getCover(c);
        collectionSearchResults
            .add(AlbumSearchResult(CollectionWithThumbnail(c, thumbnail)));
      }
    }

    return collectionSearchResults;
  }

  Future<List<GenericSearchResult>> getYearSearchResults(
    String yearFromQuery,
  ) async {
    final List<GenericSearchResult> searchResults = [];
    for (var yearData in YearsData.instance.yearsData) {
      if (yearData.year.startsWith(yearFromQuery)) {
        final List<EnteFile> filesInYear =
            await _getFilesInYear(yearData.duration);
        if (filesInYear.isNotEmpty) {
          searchResults.add(
            GenericSearchResult(
              ResultType.year,
              yearData.year,
              filesInYear,
            ),
          );
        }
      }
    }
    return searchResults;
  }

  Future<List<GenericSearchResult>> getFacesResult(String query) async {
    final List<GenericSearchResult> searchResults = [];
    final List<int> personOrClusterID =
        await FaceSearchService.instance.getAllPeople();
    for (var person in personOrClusterID) {
      final List<EnteFile> filesForPerson =
          await FaceSearchService.instance.getFilesForPerson(person);
      if (filesForPerson.isNotEmpty) {
        searchResults.add(
          GenericSearchResult(
            ResultType.people,
            'Person $person',
            filesForPerson,
            params: {'personID': person},
          ),
        );
      }
    }
    return searchResults;
  }

  Future<List<GenericSearchResult>> getHolidaySearchResults(
    BuildContext context,
    String query,
  ) async {
    final List<GenericSearchResult> searchResults = [];
    if (query.isEmpty) {
      return searchResults;
    }
    final holidays = getHolidays(context);

    for (var holiday in holidays) {
      if (holiday.name.toLowerCase().contains(query.toLowerCase())) {
        final matchedFiles =
            await FilesDB.instance.getFilesCreatedWithinDurations(
          _getDurationsForCalendarDateInEveryYear(holiday.day, holiday.month),
          ignoreCollections(),
          order: 'DESC',
        );
        if (matchedFiles.isNotEmpty) {
          searchResults.add(
            GenericSearchResult(ResultType.event, holiday.name, matchedFiles),
          );
        }
      }
    }
    return searchResults;
  }

  Future<List<GenericSearchResult>> getFileTypeResults(
    String query,
  ) async {
    final List<GenericSearchResult> searchResults = [];
    final List<EnteFile> allFiles = await getAllFiles();
    for (var fileType in FileType.values) {
      final String fileTypeString = getHumanReadableString(fileType);
      if (fileTypeString.toLowerCase().startsWith(query.toLowerCase())) {
        final matchedFiles =
            allFiles.where((e) => e.fileType == fileType).toList();
        if (matchedFiles.isNotEmpty) {
          searchResults.add(
            GenericSearchResult(
              ResultType.fileType,
              fileTypeString,
              matchedFiles,
            ),
          );
        }
      }
    }
    return searchResults;
  }

  Future<List<GenericSearchResult>> getCaptionAndNameResults(
    String query,
  ) async {
    final List<GenericSearchResult> searchResults = [];
    if (query.isEmpty) {
      return searchResults;
    }
    final RegExp pattern = RegExp(query, caseSensitive: false);
    final List<EnteFile> allFiles = await getAllFiles();
    final List<EnteFile> captionMatch = <EnteFile>[];
    final List<EnteFile> displayNameMatch = <EnteFile>[];
    for (EnteFile eachFile in allFiles) {
      if (eachFile.caption != null && pattern.hasMatch(eachFile.caption!)) {
        captionMatch.add(eachFile);
      }
      if (pattern.hasMatch(eachFile.displayName)) {
        displayNameMatch.add(eachFile);
      }
    }
    if (captionMatch.isNotEmpty) {
      searchResults.add(
        GenericSearchResult(
          ResultType.fileCaption,
          query,
          captionMatch,
        ),
      );
    }
    if (displayNameMatch.isNotEmpty) {
      searchResults.add(
        GenericSearchResult(
          ResultType.file,
          query,
          displayNameMatch,
        ),
      );
    }
    return searchResults;
  }

  Future<List<GenericSearchResult>> getFileExtensionResults(
    String query,
  ) async {
    final List<GenericSearchResult> searchResults = [];
    if (!query.startsWith(".")) {
      return searchResults;
    }

    final List<EnteFile> allFiles = await getAllFiles();
    final Map<String, List<EnteFile>> resultMap = <String, List<EnteFile>>{};

    for (EnteFile eachFile in allFiles) {
      final String fileName = eachFile.displayName;
      if (fileName.contains(query)) {
        final String exnType = fileName.split(".").last.toUpperCase();
        if (!resultMap.containsKey(exnType)) {
          resultMap[exnType] = <EnteFile>[];
        }
        resultMap[exnType]!.add(eachFile);
      }
    }
    for (MapEntry<String, List<EnteFile>> entry in resultMap.entries) {
      searchResults.add(
        GenericSearchResult(
          ResultType.fileExtension,
          entry.key.toUpperCase(),
          entry.value,
        ),
      );
    }
    return searchResults;
  }

  Future<List<GenericSearchResult>> getLocationResults(
    String query,
  ) async {
    final locationTagEntities =
        (await LocationService.instance.getLocationTags());
    final Map<LocalEntity<LocationTag>, List<EnteFile>> result = {};
    final bool showNoLocationTag = query.length > 2 &&
        "No Location Tag".toLowerCase().startsWith(query.toLowerCase());

    final List<GenericSearchResult> searchResults = [];

    for (LocalEntity<LocationTag> tag in locationTagEntities) {
      if (tag.item.name.toLowerCase().contains(query.toLowerCase())) {
        result[tag] = [];
      }
    }
    if (result.isEmpty && !showNoLocationTag) {
      return searchResults;
    }
    final allFiles = await getAllFiles();
    for (EnteFile file in allFiles) {
      if (file.hasLocation) {
        for (LocalEntity<LocationTag> tag in result.keys) {
          if (LocationService.instance.isFileInsideLocationTag(
            tag.item.centerPoint,
            file.location!,
            tag.item.radius,
          )) {
            result[tag]!.add(file);
          }
        }
      }
    }
    if (showNoLocationTag) {
      _logger.fine("finding photos with no location");
      // find files that have location but the file's location is not inside
      // any location tag
      final noLocationTagFiles = allFiles.where((file) {
        if (!file.hasLocation) {
          return false;
        }
        for (LocalEntity<LocationTag> tag in locationTagEntities) {
          if (LocationService.instance.isFileInsideLocationTag(
            tag.item.centerPoint,
            file.location!,
            tag.item.radius,
          )) {
            return false;
          }
        }
        return true;
      }).toList();
      if (noLocationTagFiles.isNotEmpty) {
        searchResults.add(
          GenericSearchResult(
            ResultType.fileType,
            "No Location Tag",
            noLocationTagFiles,
          ),
        );
      }
    }
    for (MapEntry<LocalEntity<LocationTag>, List<EnteFile>> entry
        in result.entries) {
      if (entry.value.isNotEmpty) {
        searchResults.add(
          GenericSearchResult(
            ResultType.location,
            entry.key.item.name,
            entry.value,
            onResultTap: (ctx) {
              routeToPage(
                ctx,
                LocationScreenStateProvider(
                  entry.key,
                  const LocationScreen(),
                ),
              );
            },
          ),
        );
      }
    }
    return searchResults;
  }

  Future<List<GenericSearchResult>> getMonthSearchResults(
    BuildContext context,
    String query,
  ) async {
    final List<GenericSearchResult> searchResults = [];
    for (var month in _getMatchingMonths(context, query)) {
      final matchedFiles =
          await FilesDB.instance.getFilesCreatedWithinDurations(
        _getDurationsOfMonthInEveryYear(month.monthNumber),
        ignoreCollections(),
        order: 'DESC',
      );
      if (matchedFiles.isNotEmpty) {
        searchResults.add(
          GenericSearchResult(
            ResultType.month,
            month.name,
            matchedFiles,
          ),
        );
      }
    }
    return searchResults;
  }

  Future<List<GenericSearchResult>> getDateResults(
    BuildContext context,
    String query,
  ) async {
    final List<GenericSearchResult> searchResults = [];
    final potentialDates = _getPossibleEventDate(context, query);

    for (var potentialDate in potentialDates) {
      final int day = potentialDate.item1;
      final int month = potentialDate.item2.monthNumber;
      final int? year = potentialDate.item3; // nullable
      final matchedFiles =
          await FilesDB.instance.getFilesCreatedWithinDurations(
        _getDurationsForCalendarDateInEveryYear(day, month, year: year),
        ignoreCollections(),
        order: 'DESC',
      );
      if (matchedFiles.isNotEmpty) {
        searchResults.add(
          GenericSearchResult(
            ResultType.event,
            '$day ${potentialDate.item2.name} ${year ?? ''}',
            matchedFiles,
          ),
        );
      }
    }
    return searchResults;
  }

  List<MonthData> _getMatchingMonths(BuildContext context, String query) {
    return getMonthData(context)
        .where(
          (monthData) =>
              monthData.name.toLowerCase().startsWith(query.toLowerCase()),
        )
        .toList();
  }

  Future<List<EnteFile>> _getFilesInYear(List<int> durationOfYear) async {
    return await FilesDB.instance.getFilesCreatedWithinDurations(
      [durationOfYear],
      ignoreCollections(),
      order: "DESC",
    );
  }

  List<List<int>> _getDurationsForCalendarDateInEveryYear(
    int day,
    int month, {
    int? year,
  }) {
    final List<List<int>> durationsOfHolidayInEveryYear = [];
    final int startYear = year ?? searchStartYear;
    final int endYear = year ?? currentYear;
    for (var yr = startYear; yr <= endYear; yr++) {
      if (isValidGregorianDate(day: day, month: month, year: yr)) {
        durationsOfHolidayInEveryYear.add([
          DateTime(yr, month, day).microsecondsSinceEpoch,
          DateTime(yr, month, day + 1).microsecondsSinceEpoch,
        ]);
      }
    }
    return durationsOfHolidayInEveryYear;
  }

  List<List<int>> _getDurationsOfMonthInEveryYear(int month) {
    final List<List<int>> durationsOfMonthInEveryYear = [];
    for (var year = searchStartYear; year <= currentYear; year++) {
      durationsOfMonthInEveryYear.add([
        DateTime.utc(year, month, 1).microsecondsSinceEpoch,
        month == 12
            ? DateTime(year + 1, 1, 1).microsecondsSinceEpoch
            : DateTime(year, month + 1, 1).microsecondsSinceEpoch,
      ]);
    }
    return durationsOfMonthInEveryYear;
  }

  List<Tuple3<int, MonthData, int?>> _getPossibleEventDate(
    BuildContext context,
    String query,
  ) {
    final List<Tuple3<int, MonthData, int?>> possibleEvents = [];
    if (query.trim().isEmpty) {
      return possibleEvents;
    }
    final result = query
        .trim()
        .split(RegExp('[ ,-/]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final resultCount = result.length;
    if (resultCount < 1 || resultCount > 4) {
      return possibleEvents;
    }

    final int? day = int.tryParse(result[0]);
    if (day == null || day < 1 || day > 31) {
      return possibleEvents;
    }
    final List<MonthData> potentialMonth = resultCount > 1
        ? _getMatchingMonths(context, result[1])
        : getMonthData(context);
    final int? parsedYear = resultCount >= 3 ? int.tryParse(result[2]) : null;
    final List<int> matchingYears = [];
    if (parsedYear != null) {
      bool foundMatch = false;
      for (int i = searchStartYear; i <= currentYear; i++) {
        if (i.toString().startsWith(parsedYear.toString())) {
          matchingYears.add(i);
          foundMatch = foundMatch || (i == parsedYear);
        }
      }
      if (!foundMatch && parsedYear > 1000 && parsedYear <= currentYear) {
        matchingYears.add(parsedYear);
      }
    }
    for (var element in potentialMonth) {
      if (matchingYears.isEmpty) {
        possibleEvents.add(Tuple3(day, element, null));
      } else {
        for (int yr in matchingYears) {
          possibleEvents.add(Tuple3(day, element, yr));
        }
      }
    }
    return possibleEvents;
  }
}
