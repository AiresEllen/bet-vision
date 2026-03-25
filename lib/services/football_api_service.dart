import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/football_match.dart';
import 'mock_data_service.dart';

class FootballApiService {
  Future<List<FootballMatch>> fetchTodayMatches() async {
    try {
      return await _fetchFromApi();
    } catch (_) {
      // Fallback to mock data when API is unavailable or not configured
      return MockDataService().getMatches();
    }
  }

  Future<List<FootballMatch>> _fetchFromApi() async {
    final now = DateTime.now();

    final dates = List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      return '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    });

    final allItems = <Map<String, dynamic>>[];
    final seenFixtureIds = <String>{};

    for (final date in dates) {
      final uri = Uri.base.resolve('/.netlify/functions/matches?date=$date');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        continue; // skip bad dates, don't throw
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        continue;
      }

      // Check for API error in the response body
      if (decoded.containsKey('error')) {
        throw Exception(decoded['error']);
      }

      final responseList = decoded['response'];
      if (responseList is! List) {
        continue;
      }

      for (final item in responseList) {
        if (item is! Map<String, dynamic>) continue;

        final fixture = item['fixture'];
        if (fixture is! Map<String, dynamic>) continue;

        final fixtureId = fixture['id']?.toString();
        if (fixtureId == null || seenFixtureIds.contains(fixtureId)) continue;

        seenFixtureIds.add(fixtureId);
        allItems.add(item);
      }
    }

    if (allItems.isEmpty) {
      throw Exception('Nenhuma partida retornada pela API.');
    }

    allItems.sort((a, b) {
      final aDate = DateTime.tryParse(
            (a['fixture']?['date'] ?? '').toString(),
          ) ??
          DateTime.now();
      final bDate = DateTime.tryParse(
            (b['fixture']?['date'] ?? '').toString(),
          ) ??
          DateTime.now();

      return aDate.compareTo(bDate);
    });

    return allItems.map((item) => FootballMatch.fromJson(item)).toList();
  }
}
