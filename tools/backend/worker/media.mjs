// Server-side media processing (runs in the worker, not in Edge Functions: CPU-bound and needs a
// native image library). Untrusted bytes in, safe bytes out, or a typed failure.
import sharp from 'sharp';

export class MediaRejected extends Error {
  constructor(reason) {
    super(reason);
    this.reason = reason;
    this.retryable = false;
  }
}

const MAX_INPUT_PIXELS = 40_000_000; // decoder bomb guard
const MAX_EDGE = 1600;

/**
 * Validates and re-encodes a photo: real format check from the bytes (not the declared MIME),
 * decoder pixel limit, EXIF orientation applied, every metadata block dropped (EXIF/GPS, XMP,
 * ICC), long side capped at 1600 px, output JPEG.
 */
export async function processImage(input, { minEdge = 200 } = {}) {
  if (!input || input.length < 64) throw new MediaRejected('empty_or_truncated');
  let meta;
  try {
    meta = await sharp(input, { limitInputPixels: MAX_INPUT_PIXELS, failOn: 'error' }).metadata();
  } catch {
    throw new MediaRejected('not_an_image');
  }
  if (!['jpeg', 'png', 'webp'].includes(meta.format)) throw new MediaRejected('type_not_allowed');
  if (!meta.width || !meta.height) throw new MediaRejected('not_an_image');
  if (Math.min(meta.width, meta.height) < minEdge) throw new MediaRejected('too_small');
  if (meta.pages && meta.pages > 1) throw new MediaRejected('animated_not_allowed');
  try {
    const { data, info } = await sharp(input, { limitInputPixels: MAX_INPUT_PIXELS, failOn: 'error' })
      .rotate() // applies EXIF orientation, then the orientation tag is gone with the metadata
      .resize({ width: MAX_EDGE, height: MAX_EDGE, fit: 'inside', withoutEnlargement: true })
      .jpeg({ quality: 85, mozjpeg: true })
      .toBuffer({ resolveWithObject: true });
    return { buffer: data, width: info.width, height: info.height, mime: 'image/jpeg' };
  } catch {
    throw new MediaRejected('decode_failed');
  }
}

/**
 * Voice notes: the container is checked from its first bytes (MP4/M4A "ftyp", Ogg "OggS",
 * MP3 frame sync or ID3, AAC ADTS). Audio is not transcoded; container tags may remain
 * (PROVIDER_STATUS records this limitation).
 */
export function validateVoice(input, declaredMime) {
  if (!input || input.length < 16) throw new MediaRejected('empty_or_truncated');
  const head = input.subarray(0, 12);
  const ascii = (a, b) => head.subarray(a, b).toString('latin1');
  const kind = ascii(4, 8) === 'ftyp' ? 'mp4'
    : ascii(0, 4) === 'OggS' ? 'ogg'
    : ascii(0, 3) === 'ID3' || (head[0] === 0xff && (head[1] & 0xe0) === 0xe0 && (head[1] & 0x06) !== 0) ? 'mp3'
    : head[0] === 0xff && (head[1] & 0xf6) === 0xf0 ? 'aac'
    : null;
  if (!kind) throw new MediaRejected('not_audio');
  const expected = { mp4: ['audio/mp4', 'audio/x-m4a'], ogg: ['audio/ogg'], mp3: ['audio/mpeg'], aac: ['audio/aac'] }[kind];
  if (!expected.includes(declaredMime)) throw new MediaRejected('type_mismatch');
  return { kind, mime: declaredMime };
}
