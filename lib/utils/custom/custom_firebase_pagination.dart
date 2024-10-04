// Flutter Packages
import 'package:flutter/material.dart';

// Dart Packages
import 'dart:async';

// Firebase Packages
import 'package:cloud_firestore/cloud_firestore.dart';


/// A [StreamBuilder] that automatically loads more data when the user scrolls
/// to the bottom.
///
/// Optimized for [FirebaseFirestore] with fields like `createdAt` and
/// `timestamp` to sort the data.
///
/// Supports live updates and realtime updates to loaded data.
///
/// Data can be represented in a [ListView], [GridView] or scollable [Wrap].
class CustomFirestorePagination extends StatefulWidget {
  /// Creates a [StreamBuilder] widget that automatically loads more data when
  /// the user scrolls to the bottom.
  ///
  /// Optimized for [FirebaseFirestore] with fields like `createdAt` and
  /// `timestamp` to sort the data.
  ///
  /// Supports live updates and realtime updates to loaded data.
  ///
  /// Data can be represented in a [ListView], [GridView] or scollable [Wrap].
  const CustomFirestorePagination({
    required this.query,
    required this.itemBuilder,
    super.key,
    this.separatorBuilder,
    this.limit = 10,
    this.viewType = ViewType.list,
    this.isLive = false,
    this.gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
    ),
    this.wrapOptions = const WrapOptions(),
    this.onEmpty = const EmptyScreen(),
    this.bottomLoader = const BottomLoader(),
    this.initialLoader = const InitialLoader(),
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.controller,
  });

  /// The query to use to fetch data from Firestore.
  ///
  /// ### Note:
  /// - The query must **NOT** contain a `limit` itself.
  /// - The `limit` must be set using the [limit] property of this widget.
  final Query query;

  /// The builder to use to build the items in the list.
  ///
  /// The builder is passed the build context, snapshot of the document and
  /// index of the item in the list.
  final Widget Function(BuildContext, DocumentSnapshot, int) itemBuilder;

  /// The builder to use to render the separator.
  ///
  /// Only used if [viewType] is [ViewType.list].
  ///
  /// Default [Widget] is [SizedBox.shrink].
  final Widget Function(BuildContext, int)? separatorBuilder;

  /// The number of items to fetch from Firestore at once.
  ///
  /// Defaults to `10`.
  final int limit;

  /// The type of view to use for the list.
  ///
  /// Defaults to [ViewType.list].
  final ViewType viewType;

  /// Whether to fetch newly added items as they are added to Firestore.
  ///
  /// Defaults to `false`.
  final bool isLive;

  /// The delegate to use for the [GridView].
  ///
  /// Defaults to [SliverGridDelegateWithFixedCrossAxisCount].
  final SliverGridDelegate gridDelegate;

  /// The [Wrap] widget properties to use.
  ///
  /// Defaults to [WrapOptions].
  final WrapOptions wrapOptions;

  /// The widget to use when data is empty.
  ///
  /// Defaults to [EmptyScreen].
  final Widget onEmpty;

  /// The widget to use when more data is loading.
  ///
  /// Defaults to [BottomLoader].
  final Widget bottomLoader;

  /// The widget to use when data is loading initially.
  ///
  /// Defaults to [InitialLoader].
  final Widget initialLoader;

  /// The scrolling direction of the [ScrollView].
  final Axis scrollDirection;

  /// Whether the [ScrollView] scrolls in the reading direction.
  final bool reverse;

  /// Should the [ScrollView] be shrink-wrapped.
  final bool shrinkWrap;

  /// The scroll behavior to use for the [ScrollView].
  final ScrollPhysics? physics;

  /// The padding to use for the [ScrollView].
  final EdgeInsetsGeometry? padding;

  /// The scroll controller to use for the [ScrollView].
  ///
  /// Defaults to [ScrollController].
  final ScrollController? controller;

  @override
  State<CustomFirestorePagination> createState() => _FirestorePaginationState();
}

/// The state of the [FirestorePagination] widget.
class _FirestorePaginationState extends State<CustomFirestorePagination> {
  /// All the data that has been loaded from Firestore.
  final List<DocumentSnapshot> _docs = [];

  /// Snapshot subscription for the query.
  ///
  /// Also handles updates to loaded data.
  StreamSubscription<QuerySnapshot>? _streamSub;

  /// Snapshot subscription for the query to handle newly added data.
  StreamSubscription<QuerySnapshot>? _liveStreamSub;

  /// [ScrollController] to listen to scroll end and load more data.
  late final ScrollController _controller =
      widget.controller ?? ScrollController();

  /// Whether initial data is loading.
  bool _isInitialLoading = true;

  /// Whether more data is loading.
  bool _isFetching = false;

  /// Whether the end for given query has been reached.
  ///
  /// This is used to determine if more data should be loaded when the user
  /// scrolls to the bottom.
  bool _isEnded = false;

  /// Loads more data from Firestore and handles updates to loaded data.
  ///
  /// Setting [getMore] to `false` will only set listener for the currently
  /// loaded data.
  Future<void> _loadDocuments({bool getMore = true}) async {
    // To cancel previous updates listener when new one is set.
    final tempSub = _streamSub;

    if (getMore) setState(() => _isFetching = true);

    final docsLimit = _docs.length + (getMore ? widget.limit : 0);
    var docsQuery = widget.query.limit(docsLimit);
    if (_docs.isNotEmpty) {
      docsQuery = docsQuery.startAtDocument(_docs.first);
    }

    _streamSub = docsQuery.snapshots().listen((QuerySnapshot snapshot) async {
      await tempSub?.cancel();

      _docs
        ..clear()
        ..addAll(snapshot.docs);

      // To set new updates listener for the existing data
      // or to set new live listener if the first document is removed.
      final isDocRemoved = snapshot.docChanges.any(
            (DocumentChange change) => change.type == DocumentChangeType.removed,
      );

      _isFetching = false;
      if (!isDocRemoved) {
        _isEnded = snapshot.docs.length < docsLimit;
      }

      if (isDocRemoved || _isInitialLoading) {
        _isInitialLoading = false;
        // if (snapshot.docs.isNotEmpty) {
        //   // Set updates listener for the existing data starting from the first
        //   // document only.
        //   await _loadDocuments(getMore: false);
        // } else {
        //   _streamSub?.cancel();
        // }
        if (widget.isLive) _setLiveListener();
      }

      if (mounted) setState(() {});

      // Add data till the view is scrollable. This ensures that the user can
      // scroll to the bottom and load more data.
      // if (_isInitialLoading || _isFetching || _isEnded) return;
      // SchedulerBinding.instance.addPostFrameCallback((_) {
      //   if (_controller.position.maxScrollExtent <= 0) {
      //     _loadDocuments();
      //   }
      // });
    });

  }

  /// Sets the live listener for the query.
  ///
  /// Fires when new data is added to the query.
  Future<void> _setLiveListener() async {
    // To cancel previous live listener when new one is set.
    final tempSub = _liveStreamSub;

    var latestDocQuery = widget.query.limit(1);
    if (_docs.isNotEmpty) {
      latestDocQuery = latestDocQuery.endBeforeDocument(_docs.first);
    }

    _liveStreamSub =
        latestDocQuery.snapshots(includeMetadataChanges: true).listen(
              (QuerySnapshot snapshot) async {
            await tempSub?.cancel();
            if (snapshot.docs.isEmpty ||
                snapshot.docs.first.metadata.hasPendingWrites) return;

            _docs.insert(0, snapshot.docs.first);

            // To handle newly added data after this curently loaded data.
            //await _setLiveListener();

            // Set updates listener for the newly added data.
            //_loadDocuments(getMore: false);
          },
        );
  }

  /// To handle scroll end event and load more data.
  void _scrollListener() {
    if (_isInitialLoading || _isFetching || _isEnded) return;

    final position = _controller.position;
    if (position.pixels >= (position.maxScrollExtent - 50)) {
      _loadDocuments();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _liveStreamSub?.cancel();
    _controller
      ..removeListener(_scrollListener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialLoading
        ? widget.initialLoader
        : _docs.isEmpty
        ? widget.onEmpty
        : BuildPagination(
      items: _docs,
      itemBuilder: widget.itemBuilder,
      separatorBuilder: widget.separatorBuilder ?? separatorBuilder,
      isLoading: _isFetching,
      viewType: widget.viewType,
      bottomLoader: widget.bottomLoader,
      gridDelegate: widget.gridDelegate,
      wrapOptions: widget.wrapOptions,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: _controller,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: widget.padding,
    );
  }
}


enum ViewType {
  /// Loads the data as a [ListView].
  list,

  /// Loads the data as a [GridView].
  grid,

  /// Loads the data as a scrollable [Wrap].
  wrap,
}



/// The properties of the [Wrap] widget in the [ViewType.wrap] view.
class WrapOptions {
  /// Creates a object that contains the properties of the [Wrap] widget.
  const WrapOptions({
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.center,
    this.spacing = 5.0,
    this.runAlignment = WrapAlignment.start,
    this.runSpacing = 5.0,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.clipBehavior = Clip.none,
  });

  /// The direction to use as the main axis.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis direction;

  /// How the children within a run should be placed in the main axis.
  ///
  /// Defaults to [WrapAlignment.center].
  final WrapAlignment alignment;

  /// How much space to place between children in a run in the main axis.
  ///
  /// Defaults to 5.0.
  final double spacing;

  /// How the runs themselves should be placed in the cross axis.
  ///
  /// Defaults to [WrapAlignment.start].
  final WrapAlignment runAlignment;

  /// How much space to place between the runs themselves in the cross axis.
  ///
  /// Defaults to 5.0.
  final double runSpacing;

  /// How the children within a run should be aligned relative to each other in
  /// the cross axis.
  ///
  /// Defaults to [WrapCrossAlignment.start].
  final WrapCrossAlignment crossAxisAlignment;

  /// Determines the order to lay children out horizontally and how to interpret
  /// `start` and `end` in the horizontal direction.
  final TextDirection? textDirection;

  /// Determines the order to lay children out vertically and how to interpret
  /// `start` and `end` in the vertical direction.
  ///
  /// Defaults to [VerticalDirection.down].
  final VerticalDirection verticalDirection;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;
}


class BottomLoader extends StatelessWidget {
  /// Creates a circular progress indicator that spins when the [Stream] is
  /// loading.
  ///
  /// Used at the bottom of a [ScrollView] to indicate that more data is
  /// loading.
  const BottomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 25,
        height: 25,
        margin: const EdgeInsets.all(10),
        child: const CircularProgressIndicator.adaptive(
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}


class EmptyScreen extends StatelessWidget {
  /// Creates a [Widget] to show when there is no data to display.
  const EmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Nothing found here...'),
    );
  }
}

class InitialLoader extends StatelessWidget {
  /// Creates a circular progress indicator that spins when the [Stream] is
  /// loading.
  ///
  /// Used when the [Stream] is loading the first time.
  const InitialLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}


class BuildPagination<T> extends StatelessWidget {
  /// Creates a [ScrollView] to use for the provided [items].
  ///
  /// The [items] are rendered in the [ScrollView] using the [itemBuilder].
  ///
  /// The [viewType] determines the type of [ScrollView] to use.
  const BuildPagination({
    required this.items,
    required this.itemBuilder,
    required this.separatorBuilder,
    required this.isLoading,
    required this.viewType,
    required this.bottomLoader,
    required this.gridDelegate,
    required this.wrapOptions,
    required this.scrollDirection,
    required this.reverse,
    required this.controller,
    required this.shrinkWrap,
    super.key,
    this.physics,
    this.padding,
  });

  /// The items to display in the [ScrollView].
  final List<T> items;

  /// The builder to use to render the items.
  final Widget Function(BuildContext, T, int) itemBuilder;

  /// The builder to use to render the separator.
  ///
  /// Only used if [viewType] is [ViewType.list].
  final Widget Function(BuildContext, int) separatorBuilder;

  /// Whether more [items] are being loaded.
  final bool isLoading;

  /// The type of [ScrollView] to use.
  final ViewType viewType;

  /// A [Widget] to show when more [items] are being loaded.
  final Widget bottomLoader;

  /// The delegate to use for the [GridView].
  final SliverGridDelegate gridDelegate;

  /// The options to use for the [Wrap].
  final WrapOptions wrapOptions;

  /// The scrolling direction of the [ScrollView].
  final Axis scrollDirection;

  /// Whether the [ScrollView] scrolls in the reading direction.
  final bool reverse;

  /// The scroll controller to handle the scroll events.
  final ScrollController controller;

  /// Should the [ScrollView] be shrink-wrapped.
  final bool shrinkWrap;

  /// The scroll behavior to use for the [ScrollView].
  final ScrollPhysics? physics;

  /// The padding to use for the [ScrollView].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    switch (viewType) {
      case ViewType.list:
        return ListView.separated(
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          cacheExtent: 100000,
          itemCount: items.length + 1 + (isLoading ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (index - 1 >= items.length) return bottomLoader;
            if (index == 0) {
              return itemBuilder(context, items[index], index);
            } else {
              return itemBuilder(context, items[index - 1], index);
            }
          },
          separatorBuilder: separatorBuilder,
        );

      case ViewType.grid:
        return GridView.builder(
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          itemCount: items.length + (isLoading ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (index >= items.length) return bottomLoader;

            return itemBuilder(context, items[index], index);
          },
          gridDelegate: gridDelegate,
        );

      case ViewType.wrap:
        return SingleChildScrollView(
          scrollDirection: scrollDirection,
          reverse: reverse,
          padding: padding,
          physics: physics,
          controller: controller,
          child: Wrap(
            direction: wrapOptions.direction,
            alignment: wrapOptions.alignment,
            spacing: wrapOptions.spacing,
            runAlignment: wrapOptions.runAlignment,
            runSpacing: wrapOptions.runSpacing,
            crossAxisAlignment: wrapOptions.crossAxisAlignment,
            textDirection: wrapOptions.textDirection,
            verticalDirection: wrapOptions.verticalDirection,
            clipBehavior: wrapOptions.clipBehavior,
            children: List.generate(
              items.length + (isLoading ? 1 : 0),
                  (int index) {
                if (index >= items.length) return bottomLoader;

                return itemBuilder(context, items[index], index);
              },
            ),
          ),
        );
    }
  }
}

Widget separatorBuilder(BuildContext context, int index) {
  return const SizedBox.shrink();
}
