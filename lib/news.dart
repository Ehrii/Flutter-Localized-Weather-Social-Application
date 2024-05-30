import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:proj/colors.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webfeed/webfeed.dart';

class News extends StatefulWidget {
  News() : super();

  final String title = 'RSS Feed Demo';

  @override
  RSSDemoState createState() => RSSDemoState();
}

class RSSDemoState extends State<News> {
  late RssFeed _feed;
  late String _title;
  late String selectedNews = 'Weather News';
  static const String loadingFeedMsg = 'Loading Feed...';
  static const String feedLoadErrorMsg = 'Error Loading Feed.';
  static const String feedOpenErrorMsg = 'Error Opening Feed.';
  static const String placeholderImg = 'assets/placeholder.png';
  late GlobalKey<RefreshIndicatorState> _refreshKey;
  bool _isLoading = true; // Add a loading state

  String _selectedFilter = 'Weather News'; // Default filter value
  final List<String> _filters = [
    'Weather News',
    'No Classes',
    'Earth Shaker',
  ]; // List of filter options

  updateTitle(title) {
    setState(() {
      _title = title;
    });
  }

  updateFeed(feed) {
    setState(() {
      _feed = feed;
      _isLoading = false; // Set loading state to false when feed is loaded
    });
  }

  Future<void> openFeed(String url) async {
    final Uri uri = Uri.parse(url); // Parse the full URL
    if (selectedNews == 'Earth Shaker') {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw "Can not launch url";
      }
    } else {
      if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
        throw "Can not launch url";
      }
    }
  }

  load() async {
    updateTitle(loadingFeedMsg);
    if (selectedNews == 'Weather News') {
      loadWeatherNews().then((result) {
        if (null == result || result.toString().isEmpty) {
          updateTitle(feedLoadErrorMsg);
          return;
        }
        updateFeed(result!);
        updateTitle('Weather News');
      });
    } else if (selectedNews == 'No Classes') {
      loadNoClasses().then((result) {
        if (null == result || result.toString().isEmpty) {
          updateTitle(feedLoadErrorMsg);
          return;
        }
        updateFeed(result!);
        updateTitle('No Classes');
      });
    } else if (selectedNews == 'Earth Shaker') {
      loadEarthShaker().then((result) {
        if (null == result || result.toString().isEmpty) {
          updateTitle(feedLoadErrorMsg);
          return;
        }
        updateFeed(result!);
        updateTitle('Earth Shaker FB');
      });
    }
  }

  Future<RssFeed?> loadWeatherNews() async {
    const String FEED_URL =
        'https://data.gmanetwork.com/gno/rss/scitech/weather/feed.xml';
    try {
      final client = http.Client();
      final response = await client.get(Uri.parse(FEED_URL));
      return RssFeed.parse(response.body);
    } catch (e) {
      //
    }
    return null;
  }

  Future<RssFeed?> loadNoClasses() async {
    const String FEED_URL =
        'https://data.gmanetwork.com/gno/rss/serbisyopubliko/walangpasok/feed.xml';
    try {
      final client = http.Client();
      final response = await client.get(Uri.parse(FEED_URL));
      return RssFeed.parse(response.body);
    } catch (e) {
      //
    }
    return null;
  }

  Future<RssFeed?> loadEarthShaker() async {
    const String FEED_URL = 'https://rss.app/feeds/jy9lyCEG1u78xYU4.xml';
    try {
      final client = http.Client();
      final response = await client.get(Uri.parse(FEED_URL));
      return RssFeed.parse(response.body);
    } catch (e) {
      //
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _refreshKey = GlobalKey<RefreshIndicatorState>();
    updateTitle(widget.title);
    load();
  }

  title(title) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Text(
      title,
      style:
          TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w500),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  subtitle(subTitle) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Text(
      subTitle,
      style:
          TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w100),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  thumbnail(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(8), // Adjust the border radius as needed
          child: AspectRatio(
            aspectRatio: 7 / 5, // Adjust the aspect ratio as needed
            child: CachedNetworkImage(
              placeholder: (context, url) => const CircularProgressIndicator(),
              imageUrl: imageUrl,
              alignment: Alignment.center,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      // Replace the placeholder with an existing picture
      return Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 7 / 5,
            child: Image.asset(
              'assets/placeholderimg.jpg', // Replace with the path to your existing picture
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
  }

  rightIcon() {
    return const Icon(
      Icons.keyboard_arrow_right,
      color: ColorPalette.darkblue,
      size: 30.0,
    );
  }

  String? extractImageUrlFromDescription(description) {
    RegExp regExp = RegExp('<img[^>]*src="([^"]*)"', multiLine: true);
    Match? match = regExp.firstMatch(description);
    return match != null ? match.group(1) : null;
  }

  list() {
    return ListView.builder(
      itemCount: _feed.items?.length ?? 0, // Check for null
      itemBuilder: (BuildContext context, int index) {
        final item = _feed.items![index];
        final imageUrl = extractImageUrlFromDescription(item.description);
        return ListTile(
          title: title(item.title ?? ''), // Provide default value if null
          subtitle: subtitle(item.pubDate != null
              ? DateFormat.yMMMd().format(item.pubDate!)
              : ''), // Format DateTime to String
          leading: thumbnail(imageUrl),
          trailing: rightIcon(),
          contentPadding: const EdgeInsets.all(5.0),
          onTap: () =>
              openFeed(item.link ?? ''), // Provide default value if null
        );
      },
    );
  }

  isFeedEmpty() {
    return null == _feed || null == _feed.items;
  }

  body() {
    double screenWidth = MediaQuery.of(context).size.width;

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
            key: _refreshKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_feed.items!.length} Articles Found',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                      DropdownButton<String>(
                        value: _selectedFilter,
                        items: _filters.map((String filter) {
                          return DropdownMenuItem<String>(
                            value: filter,
                            child: Text(
                              filter,
                              style: TextStyle(fontSize: screenWidth * 0.04),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFilter = newValue!;
                            _isLoading = true; // Set loading flag to true
                            showDialog(
                              context: context,
                              barrierDismissible:
                                  false, // Prevent dismissing the dialog with a tap on the outside
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Loading'), // Dialog title
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Lottie.asset(
                                        'assets/loader.json', // Replace 'assets/loader.json' with the path to your Lottie animation file
                                        width: 100,
                                        height: 100,
                                      ),
                                      LinearProgressIndicator(
                                        // Linear progress indicator
                                        backgroundColor: Colors
                                            .grey[300], // Background color
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Colors.blue), // Progress color
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            if (newValue == 'Weather News') {
                              loadWeatherNews().then((feed) {
                                Navigator.pop(
                                    context); // Close the dialog when loading is complete
                                setState(() {
                                  selectedNews = newValue;
                                  _feed = feed!;
                                  updateTitle('Weather News');
                                  _isLoading =
                                      false; // Set loading flag to false after loading is done
                                });
                              });
                            } else if (newValue == 'No Classes') {
                              loadNoClasses().then((feed) {
                                Navigator.pop(
                                    context); // Close the dialog when loading is complete
                                setState(() {
                                  selectedNews = newValue;
                                  _feed = feed!;
                                  updateTitle('No Classes');
                                  _isLoading =
                                      false; // Set loading flag to false after loading is done
                                });
                              });
                            } else if (newValue == 'Earth Shaker') {
                              selectedNews = "Earth Shaker";
                              loadEarthShaker().then((feed) {
                                Navigator.pop(
                                    context); // Close the dialog when loading is complete
                                setState(() {
                                  selectedNews = newValue;
                                  _feed = feed!;
                                  updateTitle('Earth Shaker FB');
                                  _isLoading =
                                      false; // Set loading flag to false after loading is done
                                });
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: list(),
                ),
              ],
            ),
            onRefresh: () => load(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: ColorPalette.darkblue,
        foregroundColor: Colors.white,
      ),
      body: body(),
    );
  }
}
