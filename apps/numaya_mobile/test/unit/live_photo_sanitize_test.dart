import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:numaya_mobile/data/live/live_profile_repository.dart';

/// Backend V1: photos are re-encoded on the device before upload so no EXIF (GPS included)
/// leaves the phone; the long side is capped at 1600 px.
void main() {
  test('strips EXIF metadata, including GPS, and caps the long side', () {
    final source = img.Image(width: 3000, height: 2000);
    source.exif.imageIfd['Make'] = 'TestCam';
    source.exif.gpsIfd['GPSLatitudeRef'] = 'N';
    final withExif = img.encodeJpg(source);
    expect(img.decodeJpgExif(withExif)?.isEmpty, isFalse, reason: 'fixture has EXIF');

    final clean = sanitizePhoto(withExif)!;
    final exif = img.decodeJpgExif(clean);
    expect(exif == null || exif.isEmpty, isTrue);
    final out = img.decodeJpg(clean)!;
    expect(out.width, 1600);
    expect(out.height, closeTo(1067, 1));
  });

  test('refuses bytes that are not an image', () {
    expect(sanitizePhoto(img.Image(width: 1, height: 1).toUint8List().sublist(0, 2)), isNull);
  });
}
