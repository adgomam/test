import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:audioplayers/audioplayers.dart';

enum Type { movie, audio, threeD, image }

class VideoData {
  final String url;
  final Type type;

  VideoData(this.url, this.type);
}

class VideoList extends StatelessWidget {
  final List<VideoData> data = [
    VideoData(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        Type.movie),
    VideoData(
        'https://assets.mixkit.co/music/preview/mixkit-tech-house-vibes-130.mp3',
        Type.audio),
    VideoData(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        Type.movie),
    VideoData(
        'https://assets.mixkit.co/music/preview/mixkit-tech-house-vibes-130.mp3',
        Type.audio),
    VideoData(
        'https://assets.mixkit.co/music/preview/mixkit-tech-house-vibes-130.mp3',
        Type.audio),
    VideoData(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        Type.movie),
    VideoData(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        Type.movie),
    VideoData(
        'https://assets.mixkit.co/music/preview/mixkit-tech-house-vibes-130.mp3',
        Type.audio),
  ];

  VideoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test")),
      body: InViewNotifierList(
        scrollDirection: Axis.vertical,
        initialInViewIds: const ['0'],
        isInViewPortCondition:
            (double deltaTop, double deltaBottom, double viewPortDimension) {
          return deltaTop < (0.5 * viewPortDimension) &&
              deltaBottom > (0.5 * viewPortDimension);
        },
        itemCount: data.length,
        builder: (BuildContext context, int index) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return InViewNotifierWidget(
                id: '$index',
                builder: (BuildContext context, bool isInView, Widget? child) {
                  if (data[index].type == Type.movie) {
                    return videoPlayer(context, isInView, index);
                  } else {
                    return AudioWidget(
                      play: isInView,
                      url: data[index].url,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget videoPlayer(BuildContext context, bool isInView, int index) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      color: Colors.black45,
      child: VideoWidget(
        play: isInView,
        url: data[index].url,
      ),
    );
  }
}

class VideoWidget extends StatefulWidget {
  final String url;
  final bool play;

  const VideoWidget({Key? key, required this.url, required this.play})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });

    if (widget.play) {
      _controller.play();
      _controller.setLooping(true);
    }
  }

  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        _controller.play();
        _controller.setLooping(true);
      } else {
        _controller.pause();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return FittedBox(
            fit: BoxFit.fitWidth,
            child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller)),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class AudioWidget extends StatefulWidget {
  final String url;
  final bool play;

  const AudioWidget({Key? key, required this.url, required this.play})
      : super(key: key);

  @override
  _AudioWidgetState createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  late AudioPlayer _controller;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = AudioPlayer();
    if (widget.play) {
      _controller.play(UrlSource(widget.url));
      _controller.setReleaseMode(ReleaseMode.loop);
    }
    _controller.onDurationChanged.listen((event) {
      setState(() {
        _duration = event;
      });
    });
    _controller.onPositionChanged.listen((event) {
      setState(() {
        _position = event;
      });
    });
  }

  @override
  void didUpdateWidget(AudioWidget oldWidget) {
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        _position > Duration.zero
            ? _controller.resume()
            : _controller.play(UrlSource(widget.url));
        _controller.setReleaseMode(ReleaseMode.loop);
      } else {
        _controller.pause();
      }
    }
    _controller.onDurationChanged.listen((event) {
      setState(() {
        _duration = event;
      });
    });
    _controller.onPositionChanged.listen((event) {
      setState(() {
        _position = event;
      });
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      color: Colors.orange,
      child: Column(
        children: [
          Slider(
            min: 0,
            max: _duration.inSeconds.toDouble(),
            value: _position.inSeconds.toDouble(),
            onChanged: (value) async {
              final position = Duration(seconds: value.toInt());
              await _controller.seek(position);
              await _controller.resume();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatTime(_position)),
                Text(formatTime(_duration - _position)),
              ],
            ),
          )
        ],
      ),
    );
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }
}
