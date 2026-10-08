import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'decorate_screen.dart';

const Color backgroundColor = Color(0xFFF8F9E5);
const Color primaryGreen = Color(0xFF496B31);
const Color lightGreen = Color(0xFFDDEBC8);
const Color greyCircleColor = Color(0xFFEBEBEB);

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isLoading = true;
  AttendanceSummaryResponse? _summary;
  List<AttendanceRewardItem> _rewards = [];
  bool _isGiftOpened = false;
  bool _isOpeningGift = false;
  String? _loadError;
  String? _rewardsError;
  bool _isLoadingRewards = false;

  bool get _hasReward => (_summary?.today.reward?.id ?? 0) > 0;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final summaryRes = await ApiService.getAttendanceSummary();
      if (!mounted) return;
      setState(() {
        _summary = summaryRes;
        _isGiftOpened = summaryRes.today.reward?.opened ?? false;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('출석 데이터 조회 실패: $e');
      setState(() {
        _isLoading = false;
        _loadError = '출석 요약을 불러오지 못했습니다.\n$e';
      });
      return;
    }
    await _loadRewards();
  }

  Future<void> _loadRewards() async {
    if (_isLoadingRewards || !mounted) return;
    setState(() {
      _isLoadingRewards = true;
      _rewardsError = null;
    });
    try {
      final rewards = await ApiService.getAttendanceRewards();
      if (!mounted) return;
      setState(
        () => _rewards = rewards.where((reward) => reward.opened).toList(),
      );
    } catch (e) {
      debugPrint('출석 보상 목록 조회 실패: $e');
      if (mounted) setState(() => _rewardsError = '받은 선물 목록을 불러오지 못했습니다.\n$e');
    } finally {
      if (mounted) setState(() => _isLoadingRewards = false);
    }
  }

  // 선물 열기 버튼 클릭 시 호출 (PATCH api/attendance/rewards/:reward_id/open/)
  Future<void> _openGift() async {
    if (_isOpeningGift || _isGiftOpened || _isLoading || _loadError != null)
      return;
    final rewardId = _summary?.today.reward?.id;
    if (rewardId == null || rewardId <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아직 열 수 있는 출석 보상이 없습니다.')));
      return;
    }
    setState(() => _isOpeningGift = true);

    try {
      final openedReward = await ApiService.openAttendanceReward(rewardId);

      if (!mounted) return;
      setState(() {
        _isGiftOpened = true;
        _rewards.removeWhere((reward) => reward.id == openedReward.id);
        _rewards.insert(0, openedReward);
      });

      final accessoryName = openedReward.accessory?.name ?? '하트 핀';

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('🎁 선물 도착!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StickerIconWidget(
                name: accessoryName,
                category: openedReward.accessory?.category,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                '축하합니다!\n랜덤 액세서리 "$accessoryName"을 획득했습니다!',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansKr(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToDecorateScreen(accessoryName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF86B453),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                '꾸미러 가기 >',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('보상 수령에 실패했습니다: $e')));
    } finally {
      if (mounted) setState(() => _isOpeningGift = false);
    }
  }

  // 달력 팝업창 띄우기 (GET api/attendance/calendar/?year=year&month=month 연동)
  void _showCalendarDialog([int? year, int? month]) {
    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => CalendarDialog(
        year: targetYear,
        month: targetMonth,
        todayDate: _summary?.today.date,
      ),
    );
  }

  void _navigateToDecorateScreen([String? accessoryName]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DecorationScreen(initialAccessoryName: accessoryName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '출석',
          style: GoogleFonts.notoSansKr(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_loadError!, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: _loadAttendanceData,
                      child: const Text('다시 불러오기'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                children: [
                  _buildGiftCard(),
                  const SizedBox(height: 16),
                  _buildWeeklyAttendance(),
                  const SizedBox(height: 16),
                  _buildReceivedGifts(),
                  const SizedBox(height: 110),
                ],
              ),
            ),
    );
  }

  // 1. 상단 선물 열기 카드
  Widget _buildGiftCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard,
              size: 50,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _hasReward ? '오늘의 선물이\n도착했어요' : '아직 열 수 있는\n선물이 없어요',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansKr(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _hasReward ? '산책을 마쳐서\n랜덤 액세서리를 받을 수 있어요' : '보상이 지급되면\n여기서 열 수 있어요',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black45,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: !_hasReward || _isGiftOpened || _isOpeningGift
                  ? null
                  : _openGift,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF496B31),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _isOpeningGift
                    ? '여는 중…'
                    : _isGiftOpened
                    ? '열기 완료'
                    : _hasReward
                    ? '열기'
                    : '보상 없음',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. 이번 주 출석도장 섹션 (열기 전: 흰색 원+초록 테두리 선물 아이콘, 열기 후: 초록 원+발바닥)
  Widget _buildWeeklyAttendance() {
    final daysOfWeek = ['월', '화', '수', '목', '금', '토', '일'];
    final weekItems = _summary?.week ?? [];

    int activeYear = DateTime.now().year;
    int activeMonth = DateTime.now().month;
    if (_summary != null && _summary!.today.date.isNotEmpty) {
      final dt = DateTime.tryParse(_summary!.today.date);
      if (dt != null) {
        activeYear = dt.year;
        activeMonth = dt.month;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '이번 주 출석도장',
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => _showCalendarDialog(activeYear, activeMonth),
                child: Text(
                  '${activeMonth}월 전체보기 >',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayLabel = daysOfWeek[index];
              final AttendanceDayItem? item = index < weekItems.length
                  ? weekItems[index]
                  : null;

              // 오늘 또는 선물 보상일 체크
              final bool isToday =
                  item != null && item.date == _summary?.today.date;
              final bool isAttended =
                  (item?.attended ?? false) || (isToday && _isGiftOpened);
              final bool isRewardDay = item?.isRewardDay ?? false;

              Widget iconWidget;
              BoxDecoration circleDecoration;

              if (isAttended) {
                // 출석/열기 완료: 초록색 원 배경 + 흰색 발바닥 아이콘
                circleDecoration = const BoxDecoration(
                  color: Color(0xFF86B453),
                  shape: BoxShape.circle,
                );
                iconWidget = const Icon(
                  Icons.pets,
                  color: Colors.white,
                  size: 20,
                );
              } else if (isRewardDay || isToday) {
                // 열기 전: 크림색 원 + 초록 테두리 링 + 초록 선물 아이콘 (1번 이미지 100% 일치)
                circleDecoration = BoxDecoration(
                  color: const Color(0xFFEFF5DA),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF86B453),
                    width: 2.0,
                  ),
                );
                iconWidget = const Icon(
                  Icons.card_giftcard,
                  color: Color(0xFF496B31),
                  size: 20,
                );
              } else {
                // 일반 회색 비출석 원
                circleDecoration = const BoxDecoration(
                  color: greyCircleColor,
                  shape: BoxShape.circle,
                );
                iconWidget = const SizedBox();
              }

              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: circleDecoration,
                    child: Center(child: iconWidget),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dayLabel,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // 3. 이번 주 받은 선물 섹션 (스티커 아이콘 스펙 반영 & 클릭 시 꾸미기 화면 전달)
  Widget _buildReceivedGifts() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '이번 주 받은 선물',
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToDecorateScreen(),
                child: Text(
                  '옷장 바로가기 >',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingRewards)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: primaryGreen),
            )
          else if (_rewardsError != null)
            Column(
              children: [
                Text(_rewardsError!, textAlign: TextAlign.center),
                TextButton(
                  onPressed: _loadRewards,
                  child: const Text('선물 목록 다시 불러오기'),
                ),
              ],
            )
          else if (_rewards.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  '아직 수령한 선물이 없습니다.',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 13,
                    color: Colors.black38,
                  ),
                ),
              ),
            )
          else
            ..._rewards.map((reward) {
              final name = reward.accessory?.name ?? '넥타이 케이프';
              final dayText = _formatDayText(reward.attendanceDate);

              return Column(
                children: [
                  InkWell(
                    onTap: () => _navigateToDecorateScreen(name),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          StickerIconWidget(
                            name: name,
                            category: reward.accessory?.category,
                            size: 52,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.notoSansKr(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            dayText,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 13,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (reward != _rewards.last)
                    const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                ],
              );
            }),
        ],
      ),
    );
  }

  String _formatDayText(String dateStr) {
    if (dateStr.isEmpty) return '수요일';
    try {
      final date = DateTime.parse(dateStr);
      final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
      return weekdays[date.weekday - 1];
    } catch (_) {
      return dateStr;
    }
  }
}

// -----------------------------------------------------------------------------
// [스티커 아이콘 위젯 (넥타이 케이프, 하트 핀, 왕관 벡터 스티커)]
// -----------------------------------------------------------------------------
class StickerIconWidget extends StatelessWidget {
  final String name;
  final String? category;
  final double size;

  const StickerIconWidget({
    super.key,
    required this.name,
    this.category,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F5ED),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.55,
          height: size * 0.55,
          child: _buildStickerGraphic(),
        ),
      ),
    );
  }

  Widget _buildStickerGraphic() {
    if (name.contains('넥타이') || name.contains('케이프') || category == 'CAPE') {
      return CustomPaint(painter: TieCapeStickerPainter());
    } else if (name.contains('하트') ||
        name.contains('핀') ||
        category == 'PIN' ||
        category == 'HAIR') {
      return CustomPaint(painter: HeartPinStickerPainter());
    } else if (name.contains('왕관') || category == 'CROWN') {
      return CustomPaint(painter: CrownStickerPainter());
    }
    return const Icon(Icons.star_rounded, color: Color(0xFFE5B537), size: 28);
  }
}

class TieCapeStickerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final collarPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final tiePaint = Paint()
      ..color = const Color(0xFF2B2B2B)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    final collarPath = Path();
    collarPath.moveTo(w * 0.1, h * 0.35);
    collarPath.quadraticBezierTo(w * 0.45, h * 0.15, w * 0.85, h * 0.25);
    collarPath.lineTo(w * 0.75, h * 0.6);
    collarPath.quadraticBezierTo(w * 0.45, h * 0.5, w * 0.2, h * 0.65);
    collarPath.close();

    canvas.drawPath(collarPath, collarPaint);
    canvas.drawPath(collarPath, outlinePaint);

    final tiePath = Path();
    tiePath.moveTo(w * 0.38, h * 0.45);
    tiePath.lineTo(w * 0.52, h * 0.48);
    tiePath.lineTo(w * 0.62, h * 0.82);
    tiePath.lineTo(w * 0.48, h * 0.95);
    tiePath.lineTo(w * 0.35, h * 0.78);
    tiePath.close();

    canvas.drawPath(tiePath, tiePaint);
    canvas.drawPath(tiePath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeartPinStickerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final heartPaint = Paint()
      ..color = const Color(0xFFC7432B)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    final path = Path();
    path.moveTo(w * 0.5, h * 0.85);
    path.cubicTo(w * 0.1, h * 0.55, 0, h * 0.25, w * 0.3, h * 0.15);
    path.cubicTo(w * 0.45, h * 0.1, w * 0.5, h * 0.3, w * 0.5, h * 0.3);
    path.cubicTo(w * 0.5, h * 0.3, w * 0.55, h * 0.1, w * 0.7, h * 0.15);
    path.cubicTo(w, h * 0.25, w * 0.9, h * 0.55, w * 0.5, h * 0.85);
    path.close();

    canvas.drawPath(path, heartPaint);
    canvas.drawPath(path, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CrownStickerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final crownPaint = Paint()
      ..color = const Color(0xFFE5B537)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    final path = Path();
    path.moveTo(w * 0.15, h * 0.8);
    path.lineTo(w * 0.05, h * 0.35);
    path.lineTo(w * 0.3, h * 0.52);
    path.lineTo(w * 0.5, h * 0.25);
    path.lineTo(w * 0.7, h * 0.52);
    path.lineTo(w * 0.95, h * 0.35);
    path.lineTo(w * 0.85, h * 0.8);
    path.close();

    canvas.drawPath(path, crownPaint);
    canvas.drawPath(path, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 4. 전체보기 모달 달력 위젯 (GET api/attendance/calendar/?year=year&month=month)
class CalendarDialog extends StatefulWidget {
  final int year;
  final int month;
  final String? todayDate;

  const CalendarDialog({
    super.key,
    required this.year,
    required this.month,
    this.todayDate,
  });

  @override
  State<CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<CalendarDialog> {
  bool _isLoading = true;
  AttendanceCalendarResponse? _calendarData;
  String? _calendarError;

  @override
  void initState() {
    super.initState();
    _fetchCalendarData();
  }

  Future<void> _fetchCalendarData() async {
    setState(() {
      _isLoading = true;
      _calendarError = null;
    });
    try {
      final res = await ApiService.getAttendanceCalendar(
        year: widget.year,
        month: widget.month,
      );
      if (!mounted) return;
      setState(() {
        _calendarData = res;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('출석 달력 조회 실패: $e');
      setState(() {
        _isLoading = false;
        _calendarError = '출석 달력을 불러오지 못했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 출석 요약의 서버 날짜를 우선 사용하고, 없으면 기기의 오늘 날짜 사용.
    final today = DateTime.tryParse(widget.todayDate ?? '') ?? DateTime.now();
    final int totalDays = DateTime(widget.year, widget.month + 1, 0).day;
    // 목록이 일부 날짜만 포함하거나 정렬되지 않아도 날짜별로 매칭한다.
    final daysByDate = <String, AttendanceDayItem>{};
    for (final item in _calendarData?.days ?? <AttendanceDayItem>[]) {
      final date = DateTime.tryParse(item.date);
      if (date != null &&
          date.year == widget.year &&
          date.month == widget.month) {
        daysByDate['${date.year}-${date.month}-${date.day}'] = item;
      }
    }
    final firstDayOfMonth = DateTime(widget.year, widget.month, 1);
    final int startingWeekdayOffset = (firstDayOfMonth.weekday - 1) % 7;
    final int itemCount = totalDays + startingWeekdayOffset;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
      backgroundColor: Colors.white,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.month}월',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black45,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['월', '화', '수', '목', '금', '토', '일'].map((day) {
                return SizedBox(
                  width: 32,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(color: primaryGreen),
                  )
                : _calendarError != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Text(_calendarError!, textAlign: TextAlign.center),
                        TextButton(
                          onPressed: _fetchCalendarData,
                          child: const Text('다시 불러오기'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (index < startingWeekdayOffset) {
                        return const SizedBox.shrink();
                      }

                      final int day = index - startingWeekdayOffset + 1;
                      final dayData =
                          daysByDate['${widget.year}-${widget.month}-$day'];
                      final bool isAttended = dayData?.attended ?? false;
                      final bool isToday =
                          today.year == widget.year &&
                          today.month == widget.month &&
                          today.day == day;

                      BoxDecoration decoration;
                      Color textColor;

                      if (isAttended) {
                        // 실제 출석 날짜만 초록색으로 표시한다.
                        decoration = BoxDecoration(
                          color: Color(0xFF86B453),
                          shape: BoxShape.circle,
                          border: isToday
                              ? Border.all(color: primaryGreen, width: 2)
                              : null,
                        );
                        textColor = Colors.white;
                      } else if (isToday) {
                        // 현재 월의 실제 오늘 날짜를 강조한다.
                        decoration = BoxDecoration(
                          color: const Color(0xFFFAF9E6),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF86B453),
                            width: 3.5,
                          ),
                        );
                        textColor = const Color(0xFF86B453);
                      } else {
                        // 일반 비출석 날짜: 회색 원
                        decoration = const BoxDecoration(
                          color: Color(0xFFEBEBEB),
                          shape: BoxShape.circle,
                        );
                        textColor = Colors.black45;
                      }

                      return Container(
                        decoration: decoration,
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
