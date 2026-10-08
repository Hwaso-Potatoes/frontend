import 'decoration_model.dart';

// PDF percentage table, 2026-10-07. Keep raw zero sizes: scale resolves to 100%.
// 2026-10-08: cape y -0.5%, clothes y +1%; shoes share a bottom-aligned frame.
// Shoe placements are manually calibrated front-paw slots; not PDF measurements.
const dogAccessoryLayouts = <String, DogAccessoryLayout>{
  'husky': DogAccessoryLayout(
    hat: AccessoryPlacement(27.4, 3.4),
    pin: AccessoryPlacement(38.0, 10.9),
    cape: AccessoryPlacement(2.9, 40.9, sizePercent: 142.9),
    clothes: AccessoryPlacement(
      2.6,
      5.0,
      sizePercent: 142.9,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(18.5, 83.5, sizePercent: 118.75),
  ),
  'golden_retriever': DogAccessoryLayout(
    hat: AccessoryPlacement(27.4, 0.0),
    pin: AccessoryPlacement(38.0, 10.9),
    cape: AccessoryPlacement(0.0, 35.2, sizePercent: 142.9),
    clothes: AccessoryPlacement(
      0.0,
      1.0,
      sizePercent: 142.9,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(11.5, 82.5, sizePercent: 142.5),
  ),
  'samoyed': DogAccessoryLayout(
    hat: AccessoryPlacement(34.3, 3.1),
    pin: AccessoryPlacement(44.6, 12.0),
    cape: AccessoryPlacement(7.7, 38.6, sizePercent: 142.9),
    clothes: AccessoryPlacement(
      4.6,
      3.0,
      sizePercent: 142.9,
      rotationDegrees: 8.0,
    ),
    shoes: AccessoryPlacement(18.5, 82.5, sizePercent: 133.0),
  ),
  'doberman': DogAccessoryLayout(
    // Visual calibration: PDF y=22.9 puts the hat on the muzzle.
    hat: AccessoryPlacement(34.3, 0.0),
    pin: AccessoryPlacement(44.6, 15.1),
    cape: AccessoryPlacement(25.7, 40.6, sizePercent: 0.0),
    clothes: AccessoryPlacement(
      11.1,
      9.6,
      sizePercent: 0.0,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(24.5, 85.5, sizePercent: 99.75),
  ),
  'shiba': DogAccessoryLayout(
    hat: AccessoryPlacement(31.4, 17.1),
    pin: AccessoryPlacement(41.4, 25.4),
    cape: AccessoryPlacement(13.7, 45.5, sizePercent: 114.3),
    clothes: AccessoryPlacement(
      12.0,
      18.1,
      sizePercent: 114.3,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(23.5, 79.5, sizePercent: 118.75),
  ),
  'beagle': DogAccessoryLayout(
    hat: AccessoryPlacement(31.4, 18.9),
    pin: AccessoryPlacement(41.4, 29.7),
    cape: AccessoryPlacement(18.6, 52.9, sizePercent: 0.0),
    clothes: AccessoryPlacement(
      7.2,
      17.1,
      sizePercent: 0.0,
      rotationDegrees: -10.7,
    ),
    shoes: AccessoryPlacement(20.5, 79.5, sizePercent: 109.25),
  ),
  'french_bulldog': DogAccessoryLayout(
    hat: AccessoryPlacement(39.4, 19.7),
    pin: AccessoryPlacement(45.7, 27.1),
    cape: AccessoryPlacement(25.4, 56.1, sizePercent: 0.0),
    clothes: AccessoryPlacement(
      16.0,
      19.9,
      sizePercent: 0.0,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(23.5, 80.5, sizePercent: 109.25),
  ),
  'corgi': DogAccessoryLayout(
    hat: AccessoryPlacement(31.1, 20.3),
    pin: AccessoryPlacement(38.9, 28.0),
    cape: AccessoryPlacement(12.6, 51.2, sizePercent: 114.3),
    clothes: AccessoryPlacement(
      10.0,
      21.6,
      sizePercent: 114.3,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(18.5, 76.5, sizePercent: 123.5),
  ),
  'pug': DogAccessoryLayout(
    hat: AccessoryPlacement(37.7, 24.3),
    pin: AccessoryPlacement(43.7, 32.9),
    cape: AccessoryPlacement(21.1, 56.6, sizePercent: 0.0),
    clothes: AccessoryPlacement(
      16.9,
      25.9,
      sizePercent: 0.0,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(25.5, 81.5, sizePercent: 114.0),
  ),
  'schnauzer': DogAccessoryLayout(
    hat: AccessoryPlacement(34.3, 15.7),
    pin: AccessoryPlacement(39.4, 24.0),
    cape: AccessoryPlacement(20.9, 53.5, sizePercent: 0.0),
    clothes: AccessoryPlacement(
      15.4,
      23.3,
      sizePercent: 0.0,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(23.5, 78.5, sizePercent: 109.25),
  ),
  'bichon': DogAccessoryLayout(
    hat: AccessoryPlacement(41.4, 18.3),
    pin: AccessoryPlacement(50.0, 32.9),
    cape: AccessoryPlacement(25.4, 54.4, sizePercent: 0.0),
    clothes: AccessoryPlacement(
      18.0,
      21.9,
      sizePercent: 0.0,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(30.0, 76.5, sizePercent: 90.0),
  ),
  'shih_tzu': DogAccessoryLayout(
    hat: AccessoryPlacement(38.9, 30.9),
    pin: AccessoryPlacement(50.0, 41.4),
    cape: AccessoryPlacement(24.3, 61.5, sizePercent: 0.0),
    clothes: AccessoryPlacement(
      18.6,
      32.4,
      sizePercent: 0.0,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(25.5, 80.5, sizePercent: 104.5),
  ),
  'poodle': DogAccessoryLayout(
    hat: AccessoryPlacement(34.3, 18.9),
    pin: AccessoryPlacement(46.0, 35.7),
    cape: AccessoryPlacement(22.3, 52.1, sizePercent: 0.0),
    clothes: AccessoryPlacement(
      15.4,
      23.6,
      sizePercent: 0.0,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(23.5, 81.5, sizePercent: 109.25),
  ),
  'maltese': DogAccessoryLayout(
    hat: AccessoryPlacement(36.9, 30.6),
    pin: AccessoryPlacement(44.3, 39.4),
    cape: AccessoryPlacement(22.9, 57.2, sizePercent: 0.0),
    clothes: AccessoryPlacement(
      19.4,
      33.3,
      sizePercent: 0.0,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(26.5, 75.5, sizePercent: 90.25),
  ),
  'chihuahua': DogAccessoryLayout(
    hat: AccessoryPlacement(37.1, 38.3),
    pin: AccessoryPlacement(46.3, 46.0),
    cape: AccessoryPlacement(28.9, 63.8, sizePercent: 90.7),
    clothes: AccessoryPlacement(
      26.6,
      40.7,
      sizePercent: 90.7,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(29.5, 82.5, sizePercent: 85.5),
  ),
  'pomeranian': DogAccessoryLayout(
    hat: AccessoryPlacement(37.1, 26.3),
    pin: AccessoryPlacement(44.0, 32.9),
    cape: AccessoryPlacement(21.4, 55.2, sizePercent: 0.0),
    clothes: AccessoryPlacement(
      20.6,
      30.1,
      sizePercent: 0.0,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(26.5, 79.5, sizePercent: 99.75),
  ),
  'greyhound': DogAccessoryLayout(
    hat: AccessoryPlacement(30.9, 6.0),
    pin: AccessoryPlacement(38.6, 12.9),
    cape: AccessoryPlacement(28.6, 40.4, sizePercent: 62.1),
    clothes: AccessoryPlacement(
      18.9,
      11.6,
      sizePercent: 62.1,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(27.5, 83.5, sizePercent: 80.75),
  ),
  'dachshund': DogAccessoryLayout(
    hat: AccessoryPlacement(18.3, 31.4),
    pin: AccessoryPlacement(38.6, 12.9),
    cape: AccessoryPlacement(15.1, 61.2, sizePercent: 69.3),
    clothes: AccessoryPlacement(
      0.0,
      30.7,
      sizePercent: 69.3,
      rotationDegrees: 0.0,
    ),
    shoes: AccessoryPlacement(11.5, 80.5, sizePercent: 104.5),
  ),
};

// Garment silhouettes differ from the raincoat. Keep these adjustments local
// to Bichon and resolve them here so every character screen shares the fit.
const dogAccessoryPlacementOverrides = <String, Map<int, AccessoryPlacement>>{
  'bichon': {
    18: AccessoryPlacement(24.0, 30.0, sizePercent: 78.0),
    19: AccessoryPlacement(23.0, 30.0, sizePercent: 78.0),
  },
};
