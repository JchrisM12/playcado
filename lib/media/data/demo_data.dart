import 'package:playcado/media/models/media_item.dart';

// 1. Config Object: Eliminates the untyped List<dynamic> ['Name', '2024', 2, 2]
class _SeriesBlueprint {
  final String id;
  final String name;
  final String year;
  final int seasonCount;
  final int episodesPerSeason;

  const _SeriesBlueprint({
    required this.id,
    required this.name,
    required this.year,
    required this.seasonCount,
    required this.episodesPerSeason,
  });
}

class DemoData {
  // --- Configuration ---

  static const List<_SeriesBlueprint> _seriesConfig = [
    _SeriesBlueprint(
      id: 'series_1',
      name: 'Cinematic Wonders',
      year: '2024',
      seasonCount: 2,
      episodesPerSeason: 2,
    ),
    _SeriesBlueprint(
      id: 'series_2',
      name: 'The Secret the Stars',
      year: '2023',
      seasonCount: 3,
      episodesPerSeason: 6,
    ),
    _SeriesBlueprint(
      id: 'series_3',
      name: 'Path of Earth',
      year: '2024',
      seasonCount: 3,
      episodesPerSeason: 8,
    ),
    _SeriesBlueprint(
      id: 'series_4',
      name: 'Chronicles of the Stars',
      year: '2022',
      seasonCount: 3,
      episodesPerSeason: 10,
    ),
    _SeriesBlueprint(
      id: 'series_5',
      name: 'Inside Shadows',
      year: '2019',
      seasonCount: 4,
      episodesPerSeason: 7,
    ),
    _SeriesBlueprint(
      id: 'series_6',
      name: 'Rise of Justice',
      year: '2022',
      seasonCount: 5,
      episodesPerSeason: 9,
    ),
    _SeriesBlueprint(
      id: 'series_7',
      name: 'Tales of Justice',
      year: '2022',
      seasonCount: 2,
      episodesPerSeason: 9,
    ),
    _SeriesBlueprint(
      id: 'series_8',
      name: 'Path of Earth',
      year: '2019',
      seasonCount: 5,
      episodesPerSeason: 10,
    ),
    _SeriesBlueprint(
      id: 'series_9',
      name: 'Rise of Shadows',
      year: '2021',
      seasonCount: 5,
      episodesPerSeason: 10,
    ),
    _SeriesBlueprint(
      id: 'series_10',
      name: 'Tales of Shadows',
      year: '2022',
      seasonCount: 4,
      episodesPerSeason: 9,
    ),
    _SeriesBlueprint(
      id: 'series_11',
      name: 'Chronicles of the Stars',
      year: '2023',
      seasonCount: 2,
      episodesPerSeason: 10,
    ),
  ];

  static const _movieTitles = [
    'Bright Legacy',
    'Infinite Code',
    'Ancient Kingdom',
    'Golden Sun',
    'Cyber Empire',
    'Eternal Night',
    'Digital Ghost',
    'Final Legacy',
    'Final Ghost',
    'Dark Reality',
  ];

  // --- Public Accessors ---

  static List<MediaItem> get movies => [
    ..._handpickedMovies,
    ..._generateProceduralMovies(startId: 16, endId: 65),
  ];

  static List<MediaItem> get series => _seriesConfig
      .map(
        (config) => MediaItem(
          id: config.id,
          name: config.name,
          type: MediaItemType.series,
          productionYear: config.year,
          childCount: config.seasonCount,
          officialRating: 'TV-14',
          overview: 'An epic series exploring ${config.name}.',
        ),
      )
      .toList();

  // Using .expand to flatten nested loops into a single list
  static List<MediaItem> get seasons => _seriesConfig.expand((series) {
    return List.generate(series.seasonCount, (index) {
      final sNum = index + 1;
      return MediaItem(
        id: '${series.id}_s$sNum', // Standardized ID: series_1_s1
        name: 'Season $sNum',
        type: MediaItemType.season,
        seriesId: series.id,
        indexNumber: sNum,
      );
    });
  }).toList();

  static List<MediaItem> get episodes => _seriesConfig.expand((series) {
    return List.generate(series.seasonCount, (sIndex) {
      final sNum = sIndex + 1;
      final seasonId = '${series.id}_s$sNum';

      return List.generate(series.episodesPerSeason, (eIndex) {
        final eNum = eIndex + 1;
        return MediaItem(
          id: '${seasonId}_e$eNum', // Standardized ID: series_1_s1_e1
          name: 'Episode $eNum',
          type: MediaItemType.episode,
          indexNumber: eNum,
          parentIndexNumber: sNum,
          seriesId: series.id,
          seriesName: series.name,
          seasonId: seasonId,
          overview: 'Episode $eNum of Season $sNum of ${series.name}.',
        );
      });
    }).expand((i) => i); // Flatten the seasons
  }).toList();

  // --- Private Generators ---

  static List<MediaItem> get _handpickedMovies => [
    _createMovie(
      'movie_1',
      'Interstellar Reach',
      '2024',
      6100000000,
      'A deep space mission to the edge of the galaxy goes wrong.',
    ),
    _createMovie(
      'movie_2',
      'Forest of Whispers',
      '2023',
      4440000000,
      'A poetic journey through a magical woodland.',
    ),
    _createMovie(
      'movie_3',
      'The Neon City',
      '2024',
      7340000000,
      'A private investigator hunts down a rogue AI.',
    ),
    _createMovie(
      'movie_4',
      'Arctic Silence',
      '2022',
      8880000000,
      'A survival story set in the harshest winter on Earth.',
    ),
    _createMovie(
      'movie_5',
      'Desert Mirage',
      '2023',
      5960000000,
      'Explorers find a lost city buried under the sands.',
    ),
    _createMovie(
      'movie_6',
      'The Peak',
      '2021',
      1800000000,
      'High-stakes climbing thriller.',
    ),
    _createMovie(
      'movie_7',
      'Ocean Depths',
      '2024',
      2300000000,
      'Submersible crew in the Mariana Trench.',
    ),
    _createMovie(
      'movie_8',
      'The Last Ronin',
      '2022',
      6300000000,
      'Action film about a wandering swordsman.',
    ),
    _createMovie(
      'movie_9',
      'Mechanical Heart',
      '2024',
      2100000000,
      'Intersection of technology and emotion.',
    ),
    _createMovie(
      'movie_10',
      'Golden Hour',
      '2023',
      1500000000,
      'Romantic drama in the Mediterranean.',
    ),
    _createMovie(
      'movie_11',
      'The Alchemist',
      '2021',
      4200000000,
      'An apprentice discovers gold alchemy.',
    ),
    _createMovie(
      'movie_12',
      'Circuit Run',
      '2024',
      1900000000,
      'Cyber-thriller where data is currency.',
    ),
    _createMovie(
      'movie_13',
      'Midnight Paris',
      '2022',
      5200000000,
      'Noir mystery in 1950s France.',
    ),
    _createMovie(
      'movie_14',
      'The Great Plains',
      '2023',
      3100000000,
      'Epic western about first pioneers.',
    ),
    _createMovie(
      'movie_15',
      'Abstract Reality',
      '2024',
      1200000000,
      'Experimental film about the human mind.',
    ),
  ];

  static List<MediaItem> _generateProceduralMovies({
    required int startId,
    required int endId,
  }) {
    return List.generate(endId - startId + 1, (i) {
      final id = startId + i;
      final title = _movieTitles[i % _movieTitles.length];
      return _createMovie(
        'movie_$id',
        title,
        '2024',
        5000000000,
        'A thrilling tale of ${title.toLowerCase()}.',
      );
    });
  }

  static MediaItem _createMovie(
    String id,
    String name,
    String year,
    int ticks,
    String overview,
  ) {
    return MediaItem(
      id: id,
      name: name,
      type: MediaItemType.movie,
      productionYear: year,
      runTimeTicks: ticks,
      officialRating: 'PG-13',
      overview: overview,
    );
  }
}
