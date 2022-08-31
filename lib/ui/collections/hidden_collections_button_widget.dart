import 'package:flutter/material.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/db/files_db.dart';
import 'package:photos/models/magic_metadata.dart';
import 'package:photos/ui/viewer/gallery/hidden_page.dart';
import 'package:photos/utils/navigation_util.dart';

class HiddenCollectionsButtonWidget extends StatelessWidget {
  final TextStyle textStyle;

  const HiddenCollectionsButtonWidget(
    this.textStyle, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Theme.of(context).backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(0),
        side: BorderSide(
          width: 0.5,
          color: Theme.of(context).iconTheme.color.withOpacity(0.24),
        ),
      ),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.visibility_off,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const Padding(padding: EdgeInsets.all(6)),
                  FutureBuilder<int>(
                    future: FilesDB.instance.fileCountWithVisibility(
                      kVisibilityHidden,
                      Configuration.instance.getUserID(),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data > 0) {
                        return RichText(
                          text: TextSpan(
                            style: textStyle,
                            children: [
                              TextSpan(
                                text: "Hidden",
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              const TextSpan(text: "  \u2022  "),
                              TextSpan(
                                text: snapshot.data.toString(),
                              ),
                              //need to query in db and bring this value
                            ],
                          ),
                        );
                      } else {
                        return RichText(
                          text: TextSpan(
                            style: textStyle,
                            children: [
                              TextSpan(
                                text: "Hidden",
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              //need to query in db and bring this value
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ),
        ),
      ),
      onPressed: () async {
        routeToPage(
          context,
          HiddenPage(),
        );
      },
    );
  }
}
