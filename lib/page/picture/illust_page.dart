import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/star_icon.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/picture/illust_about_grid.dart';
import 'package:pixez/page/picture/illust_detail_body.dart';
import 'package:pixez/page/picture/illust_detail_store.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/page/picture/ugoira_loader.dart';
import 'package:pixez/page/zoom/photo_viewer_page.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

class IllustPage extends StatefulWidget {
  final int id;
  final Illusts illusts;
  final String heroString;

  const IllustPage({Key key, @required this.id, this.illusts, this.heroString})
      : super(key: key);
  @override
  _IllustPageState createState() => _IllustPageState();
}

class _IllustPageState extends State<IllustPage> {
  IllustStore _illustStore;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  @override
  void initState() {
    _illustStore = IllustStore(widget.id, widget.illusts)..fetch();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String toShortTime(String dateString) {
    try {
      var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildNameAvatar(BuildContext context, Illusts illust) {
    IllustDetailStore illustDetailStore = IllustDetailStore(illust);
    return Observer(builder: (_) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
              child: GestureDetector(
                onLongPress: () {
                  illustDetailStore.followUser();
                },
                child: Container(
                  height: 70,
                  width: 70,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: SizedBox(
                          height: 70,
                          width: 70,
                          child: Container(
                            decoration: illust != null
                                ? BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: illustDetailStore.isFollow
                                        ? Colors.yellow
                                        : Theme.of(context).accentColor,
                                  )
                                : BoxDecoration(),
                          ),
                        ),
                      ),
                      Center(
                        child: PainterAvatar(
                          url: illust.user.profileImageUrls.medium,
                          id: illust.user.id,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              padding: EdgeInsets.all(8.0)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SelectableText(
                    illust.title,
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  Container(
                    height: 4.0,
                  ),
                  SelectableText(
                    illust.user.name,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  Text(
                    toShortTime(illust.createDate),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Future buildShowModalBottomSheet(BuildContext context, Illusts illusts) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        builder: (_) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0))),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _buildNameAvatar(context, illusts),
                      illusts.metaPages.isNotEmpty
                          ? ListTile(
                              title: Text(I18n.of(context).Muti_Choice_save),
                              leading: Icon(
                                Icons.save,
                              ),
                              onTap: () async {
                                Navigator.of(context).pop();
                                List<bool> indexs =
                                    List(illusts.metaPages.length);
                                for (int i = 0;
                                    i < illusts.metaPages.length;
                                    i++) {
                                  indexs[i] = false;
                                }
                                final result = await showDialog(
                                  context: context,
                                  child: StatefulBuilder(
                                      builder: (context, setDialogState) {
                                    return AlertDialog(
                                      title: Text("Select"),
                                      actions: <Widget>[
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.pop(context, "OK");
                                          },
                                          child: Text(I18n.of(context).OK),
                                        ),
                                        FlatButton(
                                          child: Text(I18n.of(context).Cancel),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                      content: Container(
                                        width: double.maxFinite,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title: Text(index.toString()),
                                              trailing: Checkbox(
                                                  value: indexs[index],
                                                  onChanged: (ischeck) {
                                                    setDialogState(() {
                                                      indexs[index] = ischeck;
                                                    });
                                                  }),
                                            );
                                          },
                                          itemCount: illusts.metaPages.length,
                                        ),
                                      ),
                                    );
                                  }),
                                );
                                switch (result) {
                                  case "OK":
                                    {
                                      saveStore.saveChoiceImage(
                                          illusts, indexs);
                                    }
                                }
                              },
                            )
                          : Container(),
                      ListTile(
                        title: Text(I18n.of(context).CopyMessage),
                        leading: Icon(
                          Icons.local_library,
                        ),
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(
                              text:
                                  'title:${illusts.title}\npainter:${illusts.user.name}\nillust id:${widget.id}'));
                          BotToast.showText(
                              text: I18n.of(context).Copied_To_Clipboard);
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        title: Text(I18n.of(context).Share),
                        leading: Icon(
                          Icons.share,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();

                          Share.share(
                              "https://www.pixiv.net/artworks/${widget.id}");
                        },
                      ),
                      ListTile(
                        title: Text(I18n.of(context).Ban),
                        leading: Icon(Icons.brightness_auto),
                        onTap: () {
                          muteStore.insertBanIllusts(BanIllustIdPersist()
                            ..illustId = widget.id.toString()
                            ..name = illusts.title);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text(I18n.of(context).report),
                        leading: Icon(Icons.report),
                        onTap: () async {
                          await showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: Text(I18n.of(context).report),
                                  content:
                                      Text(I18n.of(context).Report_Message),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      isDefaultAction: true,
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.of(context).pop("OK");
                                      },
                                    ),
                                    CupertinoDialogAction(
                                      child: Text("CANCEL"),
                                      onPressed: () {
                                        Navigator.of(context).pop("CANCEL");
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                      )
                    ],
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.cancel,
                    ),
                    title: Text(I18n.of(context).Cancel),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Container(
                    height: MediaQuery.of(context).padding.bottom,
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (_illustStore.illusts != null) {
        final data = _illustStore.illusts;
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.expand_less),
                    onPressed: () {
                      itemScrollController.scrollTo(
                          index: _illustStore.illusts.pageCount + 1,
                          duration: Duration(seconds: 1),
                          curve: Curves.easeInOutCubic);
                    }),
                IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      buildShowModalBottomSheet(context, _illustStore.illusts);
                    })
              ],
            ),
            extendBodyBehindAppBar: true,
            extendBody: true,
            floatingActionButton: FloatingActionButton(
              heroTag: widget.id,
              backgroundColor: Colors.white,
              onPressed: () => _illustStore.star(),
              child: StarIcon(_illustStore.isBookmark),
            ),
            body: _buildBody(context, data));
      } else {
        if (_illustStore.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(),
            body: Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(':(',
                        style: Theme.of(context).textTheme.headline4),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${_illustStore.errorMessage}'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      _illustStore.fetch();
                    },
                    child: Text('Refresh'),
                  )
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }
    });
  }

  Widget _buildBody(BuildContext context, Illusts data) {
    return ScrollablePositionedList.builder(
      itemCount: data.pageCount + 4,
      padding: EdgeInsets.all(0.0),
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Container(height: MediaQuery.of(context).padding.top - 56);
        }
        if (index <= data.pageCount) {
          if (data.type != "ugoira")
            return _inkWellPic(context, data, index);
          else
            return UgoiraLoader(
              id: widget.id,
              illusts: data,
            );
        }
        if (index == data.pageCount + 1) {
          return IllustDetailBody(
            illust: data,
          );
        }
        if (index == data.pageCount + 2) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(I18n.of(context).About_Picture),
          );
        }
        if (index == data.pageCount + 3) {
          return IllustAboutGrid(
            id: widget.id,
          );
        }
        return Container();
      },
    );
  }

  Widget _inkWellPic(BuildContext context, Illusts data, int index) {
    return InkWell(
      child: buildPictures(context, data, index),
      onLongPress: () {
        final illust = data;
        final isFileExist = saveStore.isIllustPartExist(data, index: index - 1);
        showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            builder: (c1) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Platform.isAndroid
                        ? ListTile(
                            title: Text(illust.title),
                            subtitle: isFileExist == null
                                ? Text(I18n.of(context).Unsaved)
                                : Text(
                                    '${I18n.of(context).Already_Saved} ${isFileExist.toString()}'),
                            trailing: isFileExist == null
                                ? Icon(Icons.info)
                                : Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                          )
                        : Container(),
                    illust.metaPages.isNotEmpty
                        ? ListTile(
                            title: Text(I18n.of(context).Muti_Choice_save),
                            leading: Icon(
                              Icons.save,
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              List<bool> indexs = List(illust.metaPages.length);
                              bool allOn = false;
                              for (int i = 0;
                                  i < illust.metaPages.length;
                                  i++) {
                                indexs[i] = false;
                              }
                              final result = await showDialog(
                                context: context,
                                child: StatefulBuilder(
                                    builder: (context, setDialogState) {
                                  return AlertDialog(
                                    title: Text(I18n.of(context).Muti_Choice_save),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context, "OK");
                                        },
                                        child: Text(I18n.of(context).OK),
                                      ),
                                      FlatButton(
                                        child: Text(I18n.of(context).Cancel),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                    content: Container(
                                      width: double.maxFinite,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) =>
                                            index == 0
                                                ? ListTile(
                                                    title: Text(
                                                        I18n.of(context).All),
                                                    trailing: Checkbox(
                                                        value: allOn,
                                                        onChanged: (ischeck) {
                                                          setDialogState(() {
                                                            allOn = ischeck;
                                                            if (ischeck)
                                                              for (int i = 0;
                                                                  i <
                                                                      indexs
                                                                          .length;
                                                                  i++) {
                                                                indexs[i] =
                                                                    true;
                                                              } //这真不是我要这么写的，谁知道这个格式化缩进这么奇怪
                                                            else {
                                                              for (int i = 0;
                                                                  i <
                                                                      indexs
                                                                          .length;
                                                                  i++) {
                                                                indexs[i] =
                                                                    false;
                                                              }
                                                            }
                                                          });
                                                        }),
                                                  )
                                                : ListTile(
                                                    title: Text(
                                                        (index - 1).toString()),
                                                    trailing: Checkbox(
                                                        value:
                                                            indexs[index - 1],
                                                        onChanged: (ischeck) {
                                                          setDialogState(() {
                                                            indexs[index - 1] =
                                                                ischeck;
                                                          });
                                                        }),
                                                  ),
                                        itemCount: illust.metaPages.length + 1,
                                      ),
                                    ),
                                  );
                                }),
                              );
                              switch (result) {
                                case "OK":
                                  {
                                    saveStore.saveChoiceImage(illust, indexs);
                                  }
                              }
                            },
                          )
                        : Container(),
                    ListTile(
                      leading: Icon(Icons.save_alt),
                      onTap: () async {
                        Navigator.of(context).pop();
                        saveStore.saveImage(illust, index: index - 1);
                      },
                      title: Text(I18n.of(context).Save),
                    ),
                    ListTile(
                      leading: Icon(Icons.cancel),
                      onTap: () => Navigator.of(context).pop(),
                      title: Text(I18n.of(context).Cancel),
                    ),
                    Container(
                      height: MediaQuery.of(c1).padding.bottom,
                    )
                  ],
                ),
              );
            });
      },
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return PhotoViewerPage(
            index: index - 1,
            illusts: data,
          );
        }));
      },
    );
  }

  Widget buildPictures(BuildContext context, Illusts data, int index) {
    return (data.pageCount == 1)
        ? Hero(
            child: PixivImage(
              data.imageUrls.large,
              placeHolder: data.imageUrls.medium,
            ),
            tag: '${data.imageUrls.medium}${widget.heroString}',
          )
        : _buildIllustsItem(index - 1, data);
  }

  Widget _buildIllustsItem(int index, Illusts illust) => index == 0
      ? Hero(
          child: PixivImage(
            illust.metaPages[index].imageUrls.large,
            placeHolder: illust.metaPages[index].imageUrls.medium,
          ),
          tag: '${illust.imageUrls.medium}${widget.heroString}',
        )
      : PixivImage(
          illust.metaPages[index].imageUrls.large,
        );
}
