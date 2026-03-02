import 'dart:convert';

/// DTO конфигурации сервера.
/// Зона ответственности: передача данных конфигурации сервера (порты, аудио настройки).
class ServerConfigDto {
  final String messageId;
  final int voipPort;
  final int videoPort;
  final int audioSampleRate;
  final int audioFrameSize;

  ServerConfigDto({
    required this.messageId,
    required this.voipPort,
    required this.videoPort,
    required this.audioSampleRate,
    required this.audioFrameSize,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ServerConfigKeys.messageId.key: messageId,
      ServerConfigKeys.voipPort.key: voipPort,
      ServerConfigKeys.videoPort.key: videoPort,
      ServerConfigKeys.audioSampleRate.key: audioSampleRate,
      ServerConfigKeys.audioFrameSize.key: audioFrameSize,
    };
  }

  factory ServerConfigDto.fromMap(Map<String, dynamic> map) {
    return ServerConfigDto(
      messageId: map[ServerConfigKeys.messageId.key] as String,
      voipPort: map[ServerConfigKeys.voipPort.key] as int,
      videoPort: map[ServerConfigKeys.videoPort.key] as int,
      audioSampleRate: map[ServerConfigKeys.audioSampleRate.key] as int,
      audioFrameSize: map[ServerConfigKeys.audioFrameSize.key] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ServerConfigDto.fromJson(String source) =>
      ServerConfigDto.fromMap(json.decode(source) as Map<String, dynamic>);
}

/// Ключи API для ServerConfigDto.
enum ServerConfigKeys {
  messageId('MessageID'),
  voipPort('VoipPort'),
  videoPort('VideoPort'),
  audioSampleRate('AudioSampleRate'),
  audioFrameSize('AudioFrameSize');

  final String key;
  const ServerConfigKeys(this.key);

  static ServerConfigKeys parse(String key) {
    switch (key) {
      case 'MessageID':
        return ServerConfigKeys.messageId;
      case 'VoipPort':
        return ServerConfigKeys.voipPort;
      case 'VideoPort':
        return ServerConfigKeys.videoPort;
      case 'AudioSampleRate':
        return ServerConfigKeys.audioSampleRate;
      case 'AudioFrameSize':
        return ServerConfigKeys.audioFrameSize;
      default:
        throw ArgumentError('Invalid ServerConfigKeys: $key');
    }
  }
}
