import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'preview_data.dart' show PreviewData;
import 'util.dart';

/// All possible message types.
enum MessageType { file, image, text, audio, video }

/// All possible statuses message can have.
enum Status { delivered, error, read, sending }

/// An abstract class that contains all variables and methods
/// every message will have.
@immutable
abstract class Message extends Equatable {
  const Message(
    this.authorId,
    this.id,
    this.metadata,
    this.status,
    this.timestamp,
    this.type,
  );

  /// Creates a particular message from a map (decoded JSON).
  /// Type is determined by the `type` field.
  factory Message.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    switch (type) {
      case 'file':
        return FileMessage.fromJson(json);
      case 'image':
        return ImageMessage.fromJson(json);
      case 'text':
        return TextMessage.fromJson(json);
      case 'audio':
        return AudioMessage.fromJson(json);
      case 'video':
        return VideoMessage.fromJson(json);
      default:
        throw ArgumentError('Unexpected value for message type');
    }
  }

  /// Creates a copy of the message with an updated data
  /// [metadata] with null value will nullify existing metadata, otherwise
  /// both metadatas will be merged into one Map, where keys from a passed
  /// metadata will overwite keys from the previous one.
  /// [previewData] will be only set for the text message type.
  /// [status] with null value will be overwritten by the previous status.
  Message copyWith({
    Map<String, dynamic>? metadata,
    PreviewData? previewData,
    Status? status,
  });

  /// Converts a particular message to the map representation, encodable to JSON.
  Map<String, dynamic> toJson();

  /// ID of the user who sent this message
  final String authorId;

  /// Unique ID of the message
  final String id;

  /// Additional custom metadata or attributes related to the message
  final Map<String, dynamic>? metadata;

  /// Message [Status]
  final Status? status;

  /// Timestamp in seconds
  final int? timestamp;

  /// [MessageType]
  final MessageType type;
}

/// A class that represents partial file message.
@immutable
class PartialFile {
  /// Creates a partial file message with all variables file can have.
  /// Use [FileMessage] to create a full message.
  /// You can use [FileMessage.fromPartial] constructor to create a full
  /// message from a partial one.
  const PartialFile({
    required this.fileName,
    this.mimeType,
    required this.size,
    required this.uri,
  });

  /// Creates a partial file message from a map (decoded JSON).
  PartialFile.fromJson(Map<String, dynamic> json)
      : fileName = json['fileName'] as String,
        mimeType = json['mimeType'] as String?,
        size = json['size'].round() as int,
        uri = json['uri'] as String;

  /// Converts a partial file message to the map representation, encodable to JSON.
  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'mimeType': mimeType,
        'size': size,
        'uri': uri,
      };

  /// The name of the file
  final String fileName;

  /// Media type
  final String? mimeType;

  /// Size of the file in bytes
  final int size;

  /// The file source (either a remote URL or a local resource)
  final String uri;
}

/// A class that represents file message.
@immutable
class FileMessage extends Message {
  /// Creates a file message.
  const FileMessage({
    required String authorId,
    required this.fileName,
    required String id,
    Map<String, dynamic>? metadata,
    this.mimeType,
    required this.size,
    Status? status,
    int? timestamp,
    required this.uri,
  }) : super(authorId, id, metadata, status, timestamp, MessageType.file);

  /// Creates a full file message from a partial one.
  FileMessage.fromPartial({
    required String authorId,
    required String id,
    Map<String, dynamic>? metadata,
    required PartialFile partialFile,
    Status? status,
    int? timestamp,
  })  : fileName = partialFile.fileName,
        mimeType = partialFile.mimeType,
        size = partialFile.size,
        uri = partialFile.uri,
        super(authorId, id, metadata, status, timestamp, MessageType.file);

  /// Creates a file message from a map (decoded JSON).
  FileMessage.fromJson(Map<String, dynamic> json)
      : fileName = json['fileName'] as String,
        mimeType = json['mimeType'] as String?,
        size = json['size'].round() as int,
        uri = json['uri'] as String,
        super(
          json['authorId'] as String,
          json['id'] as String,
          json['metadata'] as Map<String, dynamic>?,
          getStatusFromString(json['status'] as String?),
          json['timestamp'] as int?,
          MessageType.file,
        );

  /// Converts a file message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => {
        'authorId': authorId,
        'fileName': fileName,
        'id': id,
        'metadata': metadata,
        'mimeType': mimeType,
        'size': size,
        'status': status,
        'timestamp': timestamp,
        'type': 'file',
        'uri': uri,
      };

  /// Creates a copy of the file message with an updated data.
  /// [metadata] with null value will nullify existing metadata, otherwise
  /// both metadatas will be merged into one Map, where keys from a passed
  /// metadata will overwite keys from the previous one.
  /// [previewData] is ignored for this message type.
  /// [status] with null value will be overwritten by the previous status.
  @override
  Message copyWith({
    Map<String, dynamic>? metadata,
    PreviewData? previewData,
    Status? status,
  }) {
    return FileMessage(
      authorId: authorId,
      fileName: fileName,
      id: id,
      metadata: metadata == null
          ? null
          : {
              ...this.metadata ?? {},
              ...metadata,
            },
      mimeType: mimeType,
      size: size,
      status: status ?? this.status,
      timestamp: timestamp,
      uri: uri,
    );
  }

  /// Equatable props
  @override
  List<Object?> get props => [
        authorId,
        fileName,
        id,
        metadata,
        mimeType,
        size,
        status,
        timestamp,
        uri,
      ];

  /// The name of the file
  final String fileName;

  /// Media type
  final String? mimeType;

  /// Size of the file in bytes
  final int size;

  /// The file source (either a remote URL or a local resource)
  final String uri;
}

/// A class that represents partial image message.
@immutable
class PartialImage {
  /// Creates a partial image message with all variables image can have.
  /// Use [ImageMessage] to create a full message.
  /// You can use [ImageMessage.fromPartial] constructor to create a full
  /// message from a partial one.
  const PartialImage({
    this.height,
    required this.imageName,
    required this.size,
    required this.uri,
    this.width,
  });

  /// Creates a partial image message from a map (decoded JSON).
  PartialImage.fromJson(Map<String, dynamic> json)
      : height = json['height']?.toDouble() as double?,
        imageName = json['imageName'] as String,
        size = json['size'].round() as int,
        uri = json['uri'] as String,
        width = json['width']?.toDouble() as double?;

  /// Converts a partial image message to the map representation, encodable to JSON.
  Map<String, dynamic> toJson() => {
        'height': height,
        'imageName': imageName,
        'size': size,
        'uri': uri,
        'width': width,
      };

  /// Image height in pixels
  final double? height;

  /// The name of the image
  final String imageName;

  /// Size of the image in bytes
  final int size;

  /// The image source (either a remote URL or a local resource)
  final String uri;

  /// Image width in pixels
  final double? width;
}

/// A class that represents image message.
@immutable
class ImageMessage extends Message {
  /// Creates an image message.
  const ImageMessage({
    required String authorId,
    this.height,
    required String id,
    required this.imageName,
    Map<String, dynamic>? metadata,
    required this.size,
    Status? status,
    int? timestamp,
    required this.uri,
    this.width,
  }) : super(authorId, id, metadata, status, timestamp, MessageType.image);

  /// Creates a full image message from a partial one.
  ImageMessage.fromPartial({
    required String authorId,
    required String id,
    Map<String, dynamic>? metadata,
    required PartialImage partialImage,
    Status? status,
    int? timestamp,
  })  : height = partialImage.height,
        imageName = partialImage.imageName,
        size = partialImage.size,
        uri = partialImage.uri,
        width = partialImage.width,
        super(authorId, id, metadata, status, timestamp, MessageType.image);

  /// Creates an image message from a map (decoded JSON).
  ImageMessage.fromJson(Map<String, dynamic> json)
      : height = json['height']?.toDouble() as double?,
        imageName = json['imageName'] as String,
        size = json['size'].round() as int,
        uri = json['uri'] as String,
        width = json['width']?.toDouble() as double?,
        super(
          json['authorId'] as String,
          json['id'] as String,
          json['metadata'] as Map<String, dynamic>?,
          getStatusFromString(json['status'] as String?),
          json['timestamp'] as int?,
          MessageType.image,
        );

  /// Converts an image message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => {
        'authorId': authorId,
        'height': height,
        'id': id,
        'imageName': imageName,
        'metadata': metadata,
        'size': size,
        'status': status,
        'timestamp': timestamp,
        'type': 'image',
        'uri': uri,
        'width': width,
      };

  /// Creates a copy of the image message with an updated data
  /// [metadata] with null value will nullify existing metadata, otherwise
  /// both metadatas will be merged into one Map, where keys from a passed
  /// metadata will overwite keys from the previous one.
  /// [previewData] is ignored for this message type.
  /// [status] with null value will be overwritten by the previous status.
  @override
  Message copyWith({
    Map<String, dynamic>? metadata,
    PreviewData? previewData,
    Status? status,
  }) {
    return ImageMessage(
      authorId: authorId,
      height: height,
      id: id,
      imageName: imageName,
      metadata: metadata == null
          ? null
          : {
              ...this.metadata ?? {},
              ...metadata,
            },
      size: size,
      status: status ?? this.status,
      timestamp: timestamp,
      uri: uri,
      width: width,
    );
  }

  /// Equatable props
  @override
  List<Object?> get props => [
        authorId,
        height,
        id,
        imageName,
        metadata,
        size,
        status,
        timestamp,
        uri,
        width,
      ];

  /// Image height in pixels
  final double? height;

  /// The name of the image
  final String imageName;

  /// Size of the image in bytes
  final int size;

  /// The image source (either a remote URL or a local resource)
  final String uri;

  /// Image width in pixels
  final double? width;
}

/// A class that represents partial text message.
@immutable
class PartialText {
  /// Creates a partial text message with all variables text can have.
  /// Use [TextMessage] to create a full message.
  /// You can use [TextMessage.fromPartial] constructor to create a full
  /// message from a partial one.
  const PartialText({
    required this.text,
  });

  /// Creates a partial text message from a map (decoded JSON).
  PartialText.fromJson(Map<String, dynamic> json)
      : text = json['text'] as String;

  /// Converts a partial text message to the map representation, encodable to JSON.
  Map<String, dynamic> toJson() => {
        'text': text,
      };

  /// User's message
  final String text;
}

/// A class that represents text message.
@immutable
class TextMessage extends Message {
  /// Creates a text message.
  const TextMessage({
    required String authorId,
    required String id,
    Map<String, dynamic>? metadata,
    this.previewData,
    Status? status,
    required this.text,
    int? timestamp,
  }) : super(authorId, id, metadata, status, timestamp, MessageType.text);

  /// Creates a full text message from a partial one.
  TextMessage.fromPartial({
    required String authorId,
    required String id,
    Map<String, dynamic>? metadata,
    required PartialText partialText,
    Status? status,
    int? timestamp,
  })  : previewData = null,
        text = partialText.text,
        super(authorId, id, metadata, status, timestamp, MessageType.text);

  /// Creates a text message from a map (decoded JSON).
  TextMessage.fromJson(Map<String, dynamic> json)
      : previewData = json['previewData'] == null
            ? null
            : PreviewData.fromJson(json['previewData'] as Map<String, dynamic>),
        text = json['text'] as String,
        super(
          json['authorId'] as String,
          json['id'] as String,
          json['metadata'] as Map<String, dynamic>?,
          getStatusFromString(json['status'] as String?),
          json['timestamp'] as int?,
          MessageType.text,
        );

  /// Converts a text message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => {
        'authorId': authorId,
        'id': id,
        'metadata': metadata,
        'previewData': previewData?.toJson(),
        'status': status,
        'text': text,
        'timestamp': timestamp,
        'type': 'text',
      };

  /// Creates a copy of the text message with an updated data
  /// [metadata] with null value will nullify existing metadata, otherwise
  /// both metadatas will be merged into one Map, where keys from a passed
  /// metadata will overwite keys from the previous one.
  /// [status] with null value will be overwritten by the previous status.
  @override
  Message copyWith({
    Map<String, dynamic>? metadata,
    PreviewData? previewData,
    Status? status,
  }) {
    return TextMessage(
      authorId: authorId,
      id: id,
      metadata: metadata == null
          ? null
          : {
              ...this.metadata ?? {},
              ...metadata,
            },
      previewData: previewData,
      status: status ?? this.status,
      text: text,
      timestamp: timestamp,
    );
  }

  /// Equatable props
  @override
  List<Object?> get props =>
      [authorId, id, metadata, previewData, status, text, timestamp];

  /// See [PreviewData]
  final PreviewData? previewData;

  /// User's message
  final String text;
}

@immutable
class PartialAudio {
  /// Creates a partial audio message with all variables audio can have.
  /// Use [AudioMessage] to create a full message.
  /// You can use [AudioMessage.fromPartial] constructor to create a full
  /// message from a partial one.
  const PartialAudio({
    required this.length,
    this.mimeType,
    this.waveForm,
    required this.uri,
  });

  /// Creates a partial audio message from a map (decoded JSON).
  PartialAudio.fromJson(Map<String, dynamic> json)
      : length = Duration(milliseconds: json['length'] as int),
        mimeType = json['mimeType'] as String?,
        waveForm = json['waveForm'] as List<double>,
        uri = json['uri'] as String;

  /// Converts a partial audio message to the map representation, encodable to JSON.
  Map<String, dynamic> toJson() => {
        'length': length,
        'mimeType': mimeType,
        'waveForm': waveForm,
        'uri': uri,
      };

  /// The length of the audio
  final Duration length;

  /// Media type
  final String? mimeType;

  /// Wave form represented as a list of decibel level, each comprised between 0 and 120
  final List<double>? waveForm;

  /// The audio file source (either a remote URL or a local resource)
  final String uri;
}

/// A class that represents file message.
@immutable
class AudioMessage extends Message {
  /// Creates an audio message.
  const AudioMessage({
    required String authorId,
    required this.length,
    required String id,
    Map<String, dynamic>? metadata,
    this.mimeType,
    this.waveForm,
    Status? status,
    int? timestamp,
    required this.uri,
  }) : super(authorId, id, metadata, status, timestamp, MessageType.audio);

  /// Creates a full audio message from a partial one.
  AudioMessage.fromPartial({
    required String authorId,
    required String id,
    Map<String, dynamic>? metadata,
    required PartialAudio partialAudio,
    Status? status,
    int? timestamp,
  })  : length = partialAudio.length,
        mimeType = partialAudio.mimeType,
        waveForm = partialAudio.waveForm,
        uri = partialAudio.uri,
        super(authorId, id, metadata, status, timestamp, MessageType.audio);

  /// Creates an audio message from a map (decoded JSON).
  AudioMessage.fromJson(Map<String, dynamic> json)
      : length = Duration(milliseconds: json['length'] as int),
        mimeType = json['mimeType'] as String?,
        waveForm = json['waveForm'] as List<double>,
        uri = json['uri'] as String,
        super(
          json['authorId'] as String,
          json['id'] as String,
          json['metadata'] as Map<String, dynamic>?,
          getStatusFromString(json['status'] as String?),
          json['timestamp'] as int?,
          MessageType.audio,
        );

  /// Converts an audio message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => {
        'authorId': authorId,
        'length': length.inMilliseconds,
        'id': id,
        'metadata': metadata,
        'mimeType': mimeType,
        'waveForm': waveForm,
        'status': status,
        'timestamp': timestamp,
        'type': 'audio',
        'uri': uri,
      };

  /// Creates a copy of the audio message with an updated data
  @override
  Message copyWith({
    Map<String, dynamic>? metadata,
    PreviewData? previewData,
    Status? status,
  }) {
    return AudioMessage(
      authorId: authorId,
      length: length,
      id: id,
      metadata: metadata == null
          ? null
          : {
              ...this.metadata ?? {},
              ...metadata,
            },
      mimeType: mimeType,
      waveForm: waveForm,
      status: status ?? this.status,
      timestamp: timestamp,
      uri: uri,
    );
  }

  /// Equatable props
  @override
  List<Object?> get props => [
        authorId,
        length,
        id,
        metadata,
        mimeType,
        status,
        timestamp,
        uri,
      ];

  /// The length of the audio
  final Duration length;

  /// Media type
  final String? mimeType;

  /// Wave form represented as a list of decibel level, each comprised between 0 and 120
  final List<double>? waveForm;

  /// The audio source (either a remote URL or a local resource)
  final String uri;
}

@immutable
class PartialVideo {
  /// Creates a partial video message with all variables video can have.
  /// Use [VideoMessage] to create a full message.
  /// You can use [VideoMessage.fromPartial] constructor to create a full
  /// message from a partial one.
  const PartialVideo({
    required this.length,
    this.mimeType,
    required this.uri,
  });

  /// Creates a partial video message from a map (decoded JSON).
  PartialVideo.fromJson(Map<String, dynamic> json)
      : length = Duration(milliseconds: json['length'] as int),
        mimeType = json['mimeType'] as String?,
        uri = json['uri'] as String;

  /// Converts a partial video message to the map representation, encodable to JSON.
  Map<String, dynamic> toJson() => {
        'length': length,
        'mimeType': mimeType,
        'uri': uri,
      };

  /// The length of the video
  final Duration length;

  /// Media type
  final String? mimeType;

  /// The video file source (either a remote URL or a local resource)
  final String uri;
}

/// A class that represents video message.
@immutable
class VideoMessage extends Message {
  /// Creates an video message.
  const VideoMessage({
    required String authorId,
    required this.length,
    required String id,
    Map<String, dynamic>? metadata,
    this.mimeType,
    Status? status,
    int? timestamp,
    required this.uri,
  }) : super(authorId, id, metadata, status, timestamp, MessageType.video);

  /// Creates a full video message from a partial one.
  VideoMessage.fromPartial({
    required String authorId,
    required String id,
    Map<String, dynamic>? metadata,
    required PartialVideo partialVideo,
    Status? status,
    int? timestamp,
  })  : length = partialVideo.length,
        mimeType = partialVideo.mimeType,
        uri = partialVideo.uri,
        super(authorId, id, metadata, status, timestamp, MessageType.video);

  /// Creates an video message from a map (decoded JSON).
  VideoMessage.fromJson(Map<String, dynamic> json)
      : length = Duration(milliseconds: json['length'] as int),
        mimeType = json['mimeType'] as String?,
        uri = json['uri'] as String,
        super(
          json['authorId'] as String,
          json['id'] as String,
          json['metadata'] as Map<String, dynamic>?,
          getStatusFromString(json['status'] as String?),
          json['timestamp'] as int?,
          MessageType.video,
        );

  /// Converts an video message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => {
        'authorId': authorId,
        'length': length.inMilliseconds,
        'id': id,
        'metadata': metadata,
        'mimeType': mimeType,
        'status': status,
        'timestamp': timestamp,
        'type': 'video',
        'uri': uri,
      };

  /// Creates a copy of the video message with an updated data
  @override
  Message copyWith({
    Map<String, dynamic>? metadata,
    PreviewData? previewData,
    Status? status,
  }) {
    return VideoMessage(
      authorId: authorId,
      length: length,
      id: id,
      metadata: metadata == null
          ? null
          : {
              ...this.metadata ?? {},
              ...metadata,
            },
      mimeType: mimeType,
      status: status ?? this.status,
      timestamp: timestamp,
      uri: uri,
    );
  }

  /// Equatable props
  @override
  List<Object?> get props => [
        authorId,
        length,
        id,
        metadata,
        mimeType,
        status,
        timestamp,
        uri,
      ];

  /// The length of the video
  final Duration length;

  /// Media type
  final String? mimeType;

  /// The video source (either a remote URL or a local resource)
  final String uri;
}
