# Media roadmap: voice now, camera next

## Phase 1: voice (shipped)

Oratory exercises record the user's voice and analyze the delivery.

| Piece | Where |
|-------|-------|
| Microphone permission (iOS/Android/web) | `lib/data/media/media_permissions.dart`, `ios/Runner/Info.plist`, `ios/Podfile` (`PERMISSION_MICROPHONE=1`), `AndroidManifest.xml` |
| Recording + live level | `lib/data/media/speech_recorder.dart` (`record`, AAC mono 64 kbps, level every 100 ms) |
| On-device metrics (offline fallback) | `lib/domain/models/speech_metrics.dart`: duration, speaking time, pauses, longest pause |
| Speech AI | Backend `POST /api/v1/exercises/analyze-speech` (Whisper): transcript, words per minute, filler words, pauses, score; see the backend `docs/md/ANALYZER.md` |
| Scoring/feedback | `SessionResult.fromJson` (AI) or `SessionResultBuilder.fromSpeech` (on device) |
| UI | `lib/presentation/features/exercise/oratory/oratory_screen.dart` |

Notes:
- The web build analyzes on device only (the recording is a blob URL; uploading it is a TODO).
- The audio file stays in the app's temporary directory and is only sent to the Voxlab backend for analysis.

## Phase 2: camera (planned)

Goal: eye contact, gestures and posture while speaking.

Already in place:
- Camera usage strings (`NSCameraUsageDescription`, Android `CAMERA` as an optional feature) and `PERMISSION_CAMERA=1`.
- `MediaPermissions.requestCamera()`.

Proposed design:
1. **Capture**: add the `camera` package. Front camera preview in the oratory screen next to the level meter; record video together with the audio take (or audio from the same stream).
2. **On-device first pass**: Google ML Kit face detection (`google_mlkit_face_detection`) or MediaPipe on sampled frames (~5 fps):
   - *Eye contact*: head yaw/pitch and eye-open probability within a band = looking at the camera; report % of time.
   - *Movement*: face bounding-box displacement as a proxy for fidgeting.
3. **Server pass** (backend analyzer): pose estimation (MediaPipe Pose) on the uploaded video for gestures (hand activity, open vs closed posture, *ademanes*), merged into the same `score_breakdown` (`contacto_visual`, `gestos`, `postura`).
4. **Privacy**: explicit opt-in per take, never store video by default, delete after analysis.

Open questions for the product owner: video upload size/cost on the VPS, whether to keep takes for progress comparison, and minimum supported devices for on-device ML.
