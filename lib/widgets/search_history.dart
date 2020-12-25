import 'package:douban/model/search_history.dart';
import 'package:flutter/material.dart';

enum SearchHistoryEvent { insert, delete, clear, search }

typedef OnSearchHistoryEventCallback = void Function(
    SearchHistoryEvent event, SearchHistory history);

class SearchHistoryWidget extends StatefulWidget {
  var historyWords = List<SearchHistory>();
  var searchKeyWord;

  OnSearchHistoryEventCallback eventCallback;

  SearchHistoryWidget(this.historyWords,
      {this.searchKeyWord, this.eventCallback});

  @override
  State<StatefulWidget> createState() => _SearchHistoryWidgetState();
}

class _SearchHistoryWidgetState extends State<SearchHistoryWidget> {
  var _historyWords = List<SearchHistory>();

  @override
  void initState() => _refreshSearchHistory();

  void _refreshSearchHistory() {
    _historyWords = widget.historyWords.toList();
    if (widget.searchKeyWord != null && widget.historyWords.isNotEmpty)
      _historyWords.retainWhere((test) => test.keyword
          .toLowerCase()
          .contains(widget.searchKeyWord?.toString().toLowerCase()));
  }

  void _sendEvent(SearchHistoryEvent event, SearchHistory history) {
    if (widget.eventCallback != null) widget.eventCallback(event, history);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: _historyWords.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildHistoryItem(index);
                })),
        Center(
          child: FlatButton(
            child: new Text('清空历史记录', style: TextStyle(color: Colors.blue)),
            onPressed: () => _sendEvent(SearchHistoryEvent.clear, null),
            splashColor: Colors.transparent, // 去掉点击阴影效果
            highlightColor: Colors.transparent, // 去掉点击阴影效果
          ),
        )
      ],
    );
  }

  @override
  void didUpdateWidget(SearchHistoryWidget oldWidget) =>
      _refreshSearchHistory();

  Widget _buildHistoryItem(int index) {
    return InkWell(
      child: Container(
        alignment: Alignment.center,
        child: ListTile(
          leading: Icon(Icons.history),
          title: Text(_historyWords[index].keyword),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () =>
                _sendEvent(SearchHistoryEvent.delete, _historyWords[index]),
          ),
        ),
      ),
      onTap: () => _sendEvent(SearchHistoryEvent.search, _historyWords[index]),
    );
  }
}
