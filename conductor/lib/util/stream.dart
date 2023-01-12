class Streamer<T> {
  bool _firstDone = false;
  T? _last;
  List<Callback<T?>> _callbacks = [];

  Streamer();

  void next(T t) {
    // cache
    _firstDone = true;
    _last = t;

    // broadcast
    for (var c in _callbacks) {
      c(t);
    }
  }

  void subscribe(Callback<T?> c) {
    if (!_callbacks.contains(c)) {
      _callbacks.add(c);
    }

    // update with first value
    if (_firstDone) {
      c(_last);
    }
  }

  void unsubscribe(Callback<T?> c) {
    if (_callbacks.contains(c)) {
      _callbacks.remove(c);
    }
  }
}

typedef Callback<T> = void Function(T);
