import 'dart:io';
import 'dart:math';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/now_playing.dart';
import 'package:musicplayer/util/lastplay.dart';
import 'package:flutter/cupertino.dart';
import 'package:musicplayer/util/utility.dart';

class ListSongs extends StatefulWidget {
  DatabaseClient db;
  int mode;
  Orientation orientation;
  // mode =1=>recent, 2=>top, 3=>fav
  ListSongs(this.db, this.mode, this.orientation);
  @override
  State<StatefulWidget> createState() {
    return new _listSong();
  }
}

class _listSong extends State<ListSongs> {
  List<Song> songs;
  bool isLoading = true;
  dynamic getImage(Song song) {
    return song.albumArt == null
        ? null
        : new File.fromUri(Uri.parse(song.albumArt));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSongs();
  }

  void initSongs() async {
    switch (widget.mode) {
      case 1:
        songs = await widget.db.fetchRecentSong();
        break;
      case 2:
        songs = await widget.db.fetchTopSong();
        break;
      case 3:
        songs = await widget.db.fetchFavSong();
        break;
      default:
        break;
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget getTitle(int mode) {
    switch (mode) {
      case 1:
        return new Text("Recently played",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontFamily: "Quicksand",
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0));
        break;
      case 2:
        return new Text("Top tracks",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontFamily: "Quicksand",
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0));
        break;
      case 3:
        return new Text("Favourites",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontFamily: "Quicksand",
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0));
        break;
      default:
        return null;
    }
  }

  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    initSongs();
    return new Scaffold(
        appBar: widget.orientation == Orientation.portrait
            ? new AppBar(
                title: getTitle(widget.mode),
                backgroundColor: Colors.blueGrey[600],
                elevation: 8.0,
              )
            : null,
        body: new Container(
          child: isLoading
              ? new Center(
                  child: new CircularProgressIndicator(),
                )
              : new ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, i) => new Column(
                        children: <Widget>[
                          new ListTile(
                            leading: Hero(
                              tag: songs[i].id,
                              child: Image.file(
                                getImage(songs[i]),
                                width: 55.0,
                                height: 55.0,
                              ),
                            ),
                            title: new Text(songs[i].title,
                                maxLines: 1,
                                style: new TextStyle(
                                    fontSize: 16.0, color: Colors.black)),
                            subtitle: new Text(
                              songs[i].artist,
                              maxLines: 1,
                              style: new TextStyle(
                                  fontSize: 12.0, color: Colors.grey),
                            ),
                            trailing: widget.mode == 2
                                ? new Text(
                                    (i + 1).toString(),
                                    style: new TextStyle(
                                        fontSize: 12.0, color: Colors.grey),
                                  )
                                : new Text(
                                    new Duration(
                                            milliseconds: songs[i].duration)
                                        .toString()
                                        .split('.')
                                        .first
                                        .substring(3, 7),
                                    style: new TextStyle(
                                        fontSize: 12.0, color: Colors.grey)),
                            onTap: () {
                              MyQueue.songs = songs;
                              Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (context) => new NowPlaying(
                                      widget.db, MyQueue.songs, i, 0)));
                            },
                          ),
                        ],
                      ),
                ),
        ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            MyQueue.songs = songs;
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (context) =>
                new NowPlaying(widget.db, MyQueue.songs, new Random().nextInt(songs.length), 0)));
      },
      backgroundColor: Colors.white,
      foregroundColor: Colors.blueGrey,
      child: Icon(CupertinoIcons.shuffle_thick),),
    );
  }
}
