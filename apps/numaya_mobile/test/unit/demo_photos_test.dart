import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/core/media/demo_photos.dart';
import 'package:numaya_mobile/core/media/local_image.dart';
import 'package:numaya_mobile/features/dating/domain/sample_people.dart';

/// The local demo photo set (assets/demo/photos/README.md). The real photos are git-ignored, so
/// these tests use a fake manifest of the same shape.
void main() {
  final fake = DemoPhotoLibrary.fromJson({
    'photos': [
      for (var i = 1; i <= 3; i++)
        {
          'photo': 'photo_0$i.jpg',
          'role': 'portrait',
          'focus': [0.5, 0.25],
          'face': 'face_0$i.jpg',
        },
      for (var i = 4; i <= 7; i++)
        {
          'photo': 'photo_0$i.jpg',
          'role': 'scene',
          'focus': [0.4, 0.5],
        },
    ],
  });

  tearDown(() => DemoPhotoLibrary.instance = DemoPhotoLibrary(const []));

  test('no installed set: sample people keep their placeholders', () {
    DemoPhotoLibrary.instance = DemoPhotoLibrary(const []);
    final p = kSamplePeople.first;
    expect(p.photoAt(1), isNull);
    expect(p.avatarPhoto, isNull);
  });

  test('main photos are portraits; galleries are fixed per person', () {
    DemoPhotoLibrary.instance = fake;
    for (final p in [...kSamplePeople, ...kExtraPeople, ...kSeedMatchPeople]) {
      final main = p.photoAt(1)!;
      expect(fake.photos.firstWhere((d) => d.source == main).portrait, isTrue);
      // The same person gets the same photos every time (every screen asks the same way).
      final gallery = [for (var i = 1; i <= p.photoCount; i++) p.photoAt(i)];
      expect(gallery, [for (var i = 1; i <= p.photoCount; i++) p.photoAt(i)]);
      expect(gallery.toSet().length, gallery.length, reason: p.id);
      expect(p.photoAt(p.photoCount + 1), isNull);
      // Avatars use the main photo's face crop, which is centred.
      expect(p.avatarPhoto, startsWith('asset:assets/demo/photos/face_'));
      expect(localImageFocus(p.avatarPhoto!), Alignment.center);
    }
    // Neighbouring people get different main photos.
    expect(kSamplePeople[0].photoAt(1), isNot(kSamplePeople[1].photoAt(1)));
  });

  test('cover crops anchor on the recorded face', () {
    DemoPhotoLibrary.instance = fake;
    expect(
      localImageFocus('asset:assets/demo/photos/photo_01.jpg'),
      const Alignment(0, -0.5),
    );
    expect(localImageFocus('/data/user/0/picked.jpg'), Alignment.center);
  });

  test('a member’s own photos are never replaced', () {
    DemoPhotoLibrary.instance = fake;
    const own = SamplePerson(
      id: 'me',
      name: 'Alex',
      age: 30,
      distanceKm: 0,
      photoCount: 2,
      photoSources: ['/data/user/0/a.jpg', null],
    );
    expect(own.photoAt(1), '/data/user/0/a.jpg');
    expect(own.photoAt(2), isNull);
  });
}
