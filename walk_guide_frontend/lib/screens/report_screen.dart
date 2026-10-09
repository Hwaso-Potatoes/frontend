import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/pet_walk_report.dart';
import '../services/api_service.dart';
import '../services/active_pet_store.dart';
import '../widgets/report_period_tabs.dart';
import '../widgets/report_comparison_chart.dart';
import '../widgets/report_streak_banner.dart';
import '../widgets/walk_distance_chart_card.dart';

const Color backgroundColor = Color(0xFFF8F9E5);

class ReportScreen extends StatefulWidget {
  final ActivePetStore? store;
  final PetRequest? request;
  const ReportScreen({super.key, this.store, this.request});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with WidgetsBindingObserver {
  ReportPeriod _selectedPeriod = ReportPeriod.day;
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  ReportComparisonData? _data;
  Map<String, dynamic>? _summary;
  String? _error, _summaryError;
  bool _loading = true;
  int _request = 0, _summaryRequest = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    await Future.wait([_load(), _loadSummary()]);
  }

  Future<void> _loadSummary() async {
    final request = ++_summaryRequest;
    try {
      final summary = Map<String, dynamic>.from(
        await (widget.request ?? ApiService.requestData)(
              'GET',
              '/api/attendance/summary/',
            )
            as Map,
      );
      if (summary['current_streak'] is! num || summary['best_streak'] is! num) {
        throw const FormatException('연속 기록 누락');
      }
      if (mounted && request == _summaryRequest) {
        setState(() {
          _summary = summary;
          _summaryError = null;
        });
      }
    } catch (e) {
      if (mounted && request == _summaryRequest) {
        setState(() {
          _summary = null;
          _summaryError = e is ApiException
              ? e.message
              : '연속 산책 기록을 조회하지 못했습니다.';
        });
      }
    }
  }

  Future<void> _load() async {
    final request = ++_request;
    final period = switch (_selectedPeriod) {
      ReportPeriod.day => 'DAY',
      ReportPeriod.month => 'MONTH',
      _ => 'YEAR',
    };
    final date =
        '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';
    setState(() {
      _loading = true;
      _error = null;
      _data = null;
    });
    try {
      final state = widget.store ?? ActivePetStore.instance;
      await state.ensureLoaded();
      final id = state.pet?.id;
      if (id == null) throw StateError('대표 반려견 조회 필요');
      final raw = await (widget.request ?? ApiService.requestData)(
        'GET',
        '/api/pets/$id/reports/?period=$period&date=$date',
      );
      final data = parsePetWalkReport(Map<String, dynamic>.from(raw as Map));
      if (mounted && request == _request) setState(() => _data = data);
    } catch (e) {
      if (mounted && request == _request) {
        setState(
          () => _error = e is ApiException
              ? e.message
              : '리포트를 조회하지 못했습니다. 다시 시도해주세요.',
        );
      }
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  DateTime _move(int direction) => switch (_selectedPeriod) {
    ReportPeriod.day => DateTime(
      _date.year,
      _date.month,
      _date.day + direction,
    ),
    ReportPeriod.month => DateTime(_date.year, _date.month + direction),
    _ => DateTime(_date.year + direction),
  };
  bool get _canGoNext {
    final now = DateTime.now();
    return switch (_selectedPeriod) {
      ReportPeriod.day => _date.isBefore(DateUtils.dateOnly(now)),
      ReportPeriod.month => DateTime(
        _date.year,
        _date.month,
      ).isBefore(DateTime(now.year, now.month)),
      _ => _date.year < now.year,
    };
  }

  void _navigate(int direction) {
    setState(() => _date = _move(direction));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 64, 28, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '산책 리포트',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ReportPeriodTabs(
                        selected: _selectedPeriod,
                        onChanged: (period) {
                          setState(() {
                            _selectedPeriod = period;
                            _date = DateUtils.dateOnly(DateTime.now());
                          });
                          _load();
                        },
                      ),
                    ],
                  ),
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(64),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        TextButton(
                          onPressed: _load,
                          child: const Text('다시 조회'),
                        ),
                      ],
                    ),
                  )
                else if (data != null) ...[
                  ReportComparisonChart(
                    data: data,
                    onPrevious: () => _navigate(-1),
                    onNext: _canGoNext ? () => _navigate(1) : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
                    child: Column(
                      children: [
                        if (_summary != null)
                          ReportStreakBanner(
                            dogName:
                                (widget.store ?? ActivePetStore.instance)
                                    .pet
                                    ?.name ??
                                '반려견',
                            days: (_summary!['current_streak'] as num).toInt(),
                            recordDays: (_summary!['best_streak'] as num)
                                .toInt(),
                          )
                        else if (_summaryError != null)
                          Column(
                            children: [
                              Text(_summaryError!, textAlign: TextAlign.center),
                              TextButton(
                                onPressed: _loadSummary,
                                child: const Text('연속 기록 다시 조회'),
                              ),
                            ],
                          ),
                        const SizedBox(height: 22),
                        if (data.bars.isEmpty ||
                            data.bars.every((b) => b.value == 0))
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('이 기간에는 산책 기록이 없습니다.'),
                          )
                        else
                          WalkDistanceChartCard(
                            title: data.chartContext,
                            totalLabel: data.peakDistance,
                            bars: data.bars,
                            peakLabel: data.peakLabel,
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
