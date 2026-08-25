import 'package:flutter/material.dart';

/// 실제 API/더미 데이터의 breed 값(한글) -> 내부 에셋 키(영문) 변환
/// 견종 18종 목록 기준 (schnauzer ~ shih_tzu)
const Map<String, String> _koreanBreedToKey = {
  '슈나우저': 'schnauzer',
  '그레이하운드': 'greyhound',
  '시바견': 'shiba',
  '시바': 'shiba',
  '비글': 'beagle',
  '웰시코기': 'corgi',
  '코기': 'corgi',
  '비숑프리제': 'bichon',
  '비숑': 'bichon',
  '사모예드': 'samoyed',
  '푸들': 'poodle',
  '골든리트리버': 'golden_retriever',
  '포메라니안': 'pomeranian',
  '프렌치불독': 'french_bulldog',
  '치와와': 'chihuahua',
  '퍼그': 'pug',
  '말티즈': 'maltese',
  '닥스훈트': 'dachshund',
  '시베리안허스키': 'husky',
  '허스키': 'husky',
  '도베르만': 'doberman',
  '시츄': 'shih_tzu',
};

/// 백엔드의 breed 값(key) → 로컬 에셋 경로(value) 매핑
/// 전부 png (svg가 사실 래스터 이미지를 감싼 것들이라 png로 교체함)
final Map<String, String> dogAssetMap = {
  'schnauzer': 'assets/dogs/schnauzer.png',
  'greyhound': 'assets/dogs/greyhound.png',
  'shiba': 'assets/dogs/shiba.png',
  'beagle': 'assets/dogs/beagle.png',
  'corgi': 'assets/dogs/corgi.png',
  'bichon': 'assets/dogs/bichon.png',
  'samoyed': 'assets/dogs/samoyed.png',
  'poodle': 'assets/dogs/poodle.png',
  'golden_retriever': 'assets/dogs/golden_retriever.png',
  'pomeranian': 'assets/dogs/pomeranian.png',
  'french_bulldog': 'assets/dogs/french_bulldog.png',
  'chihuahua': 'assets/dogs/chihuahua.png',
  'pug': 'assets/dogs/pug.png',
  'maltese': 'assets/dogs/maltese.png',
  'dachshund': 'assets/dogs/dachshund.png',
  'husky': 'assets/dogs/husky.png',
  'doberman': 'assets/dogs/doberman.png',
  'shih_tzu': 'assets/dogs/shih_tzu.png',
};

/// breed 문자열(한글이든 영문이든)을 넣으면 알맞은 견종 아이콘을 보여주는 위젯
class DogIcon extends StatelessWidget {
  final String breed;
  final double size;

  const DogIcon({
    super.key,
    required this.breed,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final String key = _koreanBreedToKey[breed] ?? breed.toLowerCase();
    final assetPath = dogAssetMap[key];

    if (assetPath == null) {
      return Icon(Icons.pets, size: size, color: Colors.grey);
    }

    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.pets, size: size, color: Colors.grey);
      },
    );
  }
}