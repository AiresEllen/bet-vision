import '../models/football_match.dart';
import '../services/football_api_service.dart';

class MatchRepository {
  MatchRepository({
    FootballApiService? footballApiService,
  }) : _footballApiService = footballApiService ?? FootballApiService();

  final FootballApiService _footballApiService;

  bool get usesLiveApi => true;

  Future<List<FootballMatch>> getTodayMatches() async {
    final matches = await _footballApiService.fetchTodayMatches();
    return matches;
  }
}
